//
//  ViewController.swift
//  CoreMotionTest
//
//  Created by Dave Johnson on 12/12/17.
//  Copyright © 2017 Paycom. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let activityManager = CMMotionActivityManager()
    let pedoMeter = CMPedometer()
    var motionDetection = Timer()
    
    @IBOutlet weak var activityState: UILabel!
    
    @objc func updateMotion() {
        
        if(CMMotionActivityManager.isActivityAvailable()){
            print("YES!")
            self.activityManager.startActivityUpdates(to: OperationQueue.main) { data in
                if let data = data {
                    DispatchQueue.main.async() {
                        if(data.stationary == true){
                            self.activityState.text = "Stationary"
                        } else if (data.walking == true){
                            self.activityState.text = "Walking"
                        } else if (data.running == true){
                            self.activityState.text = "Running"
                        } else if (data.automotive == true){
                            self.activityState.text = "Automotive"
                        }
                    }
                }
            }
        }
    }
    
    func startTimer() {
        motionDetection = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateMotion)), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startTimer()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

