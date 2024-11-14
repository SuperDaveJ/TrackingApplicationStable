//
//  ViewController.swift
//  locationServicesTest2
//
//  Created by Dave Johnson on 11/30/17.
//  Copyright © 2017 Paycom. All rights reserved.
//

import UIKit
import UserNotifications
import CoreGraphics
import CoreLocation

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    var previousSpeed: Double = 0
    static var isGrantedNotificationAccess:Bool = false
    var isPaused = false
    var autoPlay = false
    var currentlyTracking = false
    let timeTracker = TimeTracking()
    let identifyMotion = IdentifyMotion()
    
    @IBOutlet weak var speedView: SpeedView!
    @IBOutlet weak var startLongitudeLabel: UILabel!
    @IBOutlet weak var startLatitudeLabel: UILabel!
    @IBOutlet weak var endLongitudeLabel: UILabel!
    @IBOutlet weak var endLatitudeLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var distanceTraveledLabel: UILabel!
    @IBOutlet weak var trackingButton: UIButton!
    @IBOutlet weak var autoTrackingButton: UIButton!
    @IBOutlet weak var motionIdentityImage: UIImageView!
    
    @IBAction func playPressed(_ sender: UIButton) {
        
        self.isPaused = !self.isPaused
        if self.isPaused {
            UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve, animations: {
                sender.setImage(UIImage(named: "play2"), for: .normal)
            }, completion: nil)
            LocationService.paused = true
            timeTracker.pauseTimer()
        } else {
            UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve, animations: {
                sender.setImage(UIImage(named: "pause2"), for: .normal)
            }, completion: nil)
            LocationService.paused = false
            LocationService.resumed = true
            timeTracker.startTimer()
        }
    }
    
    @IBAction func startActiveTracking(_ sender: UIButton) {
        
        self.currentlyTracking = !self.currentlyTracking
        if self.currentlyTracking {
            UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve, animations: {
                sender.setImage(UIImage(named: "track-started-1"), for: .normal)
            }, completion: nil)
            
            UIView.animate(withDuration: 1.0, animations: {
                self.playButton.alpha = 1.0
            })
            
            timeTracker.restartTimer()
            LocationService.shared.restartUpdatingLocation()
        } else {
            UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve, animations: {
                sender.setImage(UIImage(named: "track-stopped-1"), for: .normal)
            }, completion: nil)
            
            UIView.animate(withDuration: 1.0, animations: {
                self.playButton.alpha = 0.0
            })
            
            timeTracker.stopTimer()
            LocationService.shared.stopUpdatingLocation()
        }
    }
    
    @IBAction func startAutoTracking(_ sender: UIButton) {
        
        self.autoPlay = !self.autoPlay
        if self.autoPlay {
            
            UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve, animations: {
                sender.setImage(UIImage(named: "auto-on-1"), for: .normal)
            }, completion: nil)
            
            // Actions here
        } else {
            UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve, animations: {
                sender.setImage(UIImage(named: "auto-off-1"), for: .normal)
            }, completion: nil)
            
            // Actions here
        }
    }
    
    var currentSpeed: Double = 000 {
        
        didSet {
            if currentSpeed < 0 {
                currentSpeed = 0
            }
            let mphSpeed = Int(currentSpeed * 2.23694)
            //let kmhSpeed = Int(currentSpeed * 3.6)
            
            speedView.curValue = CGFloat((currentSpeed * 2.23694)/10)
            
            speedLabel.text = String(mphSpeed)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        LocationService.shared.delegate = self
        timeTracker.delegate = self
        identifyMotion.motionTypeDelegate = self
        
       
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                ViewController.isGrantedNotificationAccess = granted
            }
        )
        
        //LocationService.shared.startUpdatingLocation()
        //timeTracker.startTimer()
        LocationService.shared.startSpeedTimer()
        
    }
}

//Alert and Notification Extension
extension UIViewController {
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showTrackingNotification(title: String, subtitle: String, body: String){
        if ViewController.isGrantedNotificationAccess{
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.body = body
            content.categoryIdentifier = "Category"
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 0.1,
                repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "Motion Alert Message",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(
                request, withCompletionHandler: nil)
        }
    }
    
    //for displaying notification when app is in foreground
    @objc(userNotificationCenter:willPresentNotification:withCompletionHandler:) func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
       completionHandler([.alert,.badge])
    }
   
}

extension ViewController: locationServiceDelegate {
    
    func locationService(_ controller: LocationService, didStart locationCoords: String, using locationAddress: String) {
        startLatitudeLabel.text = locationCoords
        startLongitudeLabel.text = locationAddress
    }
    
    func locationService(_ controller: LocationService, didUpdate locationCoords: String, using locationAddress: String, didUpdate speed: CLLocationSpeed, didUpdate distanceTotal: String) {
        
        currentLocationLabel.text = locationCoords
        currentSpeed = Double(speed)
        distanceTraveledLabel.text = distanceTotal
        identifyMotion.updateMotion()
    }
    
    func locationService(_ controller: LocationService, didStop locationCoords: String, using locationAddress: String) {
        
        endLatitudeLabel.text = locationCoords
        endLongitudeLabel.text = locationAddress
        
    }
    
    func locationService(_ controller: LocationService, didRestart locationCoords: String, using locationAddress: String) {
        
        startLatitudeLabel.text = locationCoords
        startLongitudeLabel.text = locationAddress
        endLatitudeLabel.text = ""
        endLongitudeLabel.text = ""
    }
    
    func locationService(_ controller: LocationService, speedUpdate speed: CLLocationSpeed) {
        currentSpeed = Double(speed)
        identifyMotion.updateMotion()
    }
}

extension ViewController: TimeTrackingDelegate {
    
    func timeTracking(_ controller: TimeTracking, didUpdate timeElapsed: String) {
        timeElapsedLabel.text = timeElapsed
    }
}

extension ViewController: MotionIdentificationDelegate {
    
    func motionIdentification(_ controller: IdentifyMotion, didUpdate motionType: motionType) {
        switch motionType {
            case .running:
                motionIdentityImage.image = UIImage(named: "motion-run")
            print("Running")
            case .stationary:
                motionIdentityImage.image = UIImage(named: "motion-stationary")
            print("Stationary")
            case .walking:
                motionIdentityImage.image = UIImage(named: "motion-walk")
            print("Walking")
            case .auto:
                motionIdentityImage.image = UIImage(named: "motion-car")
            print("Auto")
        }
    }
}



    



