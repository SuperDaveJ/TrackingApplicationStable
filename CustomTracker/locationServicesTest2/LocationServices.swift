//
//  LocationServices.swift
//  locationServicesTest2
//
//  Created by Dave Johnson on 11/30/17.
//  Copyright © 2017 Paycom. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

protocol locationServiceDelegate: class {
    
    func locationService(_ controller: LocationService, didStart locationCoords: String, using locationAddress: String)
    func locationService(_ controller: LocationService, didUpdate locationCoords: String, using locationAddress: String, didUpdate speed: CLLocationSpeed, didUpdate distanceTotal: String)
    func locationService(_ controller: LocationService, didStop locationCoords: String, using locationAddress: String)
    func locationService(_ controller: LocationService, didRestart locationCoords: String, using locationAddress: String)
    func locationService(_ controller: LocationService, speedUpdate speed: CLLocationSpeed)
}


class LocationService: NSObject, CLLocationManagerDelegate{
    
    static let shared = LocationService()
    var locationManager = CLLocationManager()
    var significatLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var bgTask = UIBackgroundTaskInvalid
    var geocoder: CLGeocoder?
    var startingAddress: String = ""
    var endingAddress: String = ""
    var traveledDistance: Double = 0
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var startDate: Date!
    static var paused: Bool = false
    static var resumed: Bool = false
    var currentAddress: LocationAddress?
    var speedTimer: Timer?
    weak var delegate: locationServiceDelegate?
    
    func startUpdatingLocation() {
        
        traveledDistance = 0
        lastLocation = currentLocation
        locationManager.requestAlwaysAuthorization()
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = 5
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .automotiveNavigation
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        if geocoder == nil {
            geocoder = CLGeocoder()
        }
    }
    
    func stopUpdatingLocation() {
        
        locationManager.stopUpdatingLocation()
        
        let locationObj = locationManager.location
        let coord = locationObj?.coordinate
        let longitude = coord?.longitude
        let latitude = coord?.latitude
        let addressLocation = CLLocation(latitude: latitude!, longitude: longitude!)
        geocoder?.reverseGeocodeLocation(addressLocation) {
            [weak self] placemarks, error in
            if let lastPlacemark = placemarks?.last {
                do {
                    self?.currentAddress = try LocationAddress(placemark: lastPlacemark)
                    self?.delegate?.locationService(self!, didStop: "\(latitude!) \(longitude!)", using: self!.currentAddress!.addressString())
                    
                } catch {
                    print("Error: \(error), \(error.localizedDescription)")
                }
            }
        }
    }
    
    func restartUpdatingLocation() {
        locationManager.stopMonitoringSignificantLocationChanges()
        startUpdatingLocation()
        
        self.delegate?.locationService(self, didRestart: " ", using: " ")
        
        let locationObj = locationManager.location
        let coord = locationObj?.coordinate
        let longitude = coord?.longitude
        let latitude = coord?.latitude
        let addressLocation = CLLocation(latitude: latitude!, longitude: longitude!)
        geocoder?.reverseGeocodeLocation(addressLocation) {
            [weak self] placemarks, error in
            if let lastPlacemark = placemarks?.last {
                do {
                    self?.currentAddress = try LocationAddress(placemark: lastPlacemark)
                    
                    self?.delegate?.locationService(self!, didRestart: "\(latitude!) \(longitude!)", using: self!.currentAddress!.addressString())
                    
                } catch {
                    print("Error: \(error), \(error.localizedDescription)")
                }
            }
        }
    }
    
    func startMonitoringLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    @objc func changeLocationAccuracy(){
        switch locationManager.desiredAccuracy {
        case kCLLocationAccuracyBest:
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.distanceFilter = 99999
        case kCLLocationAccuracyThreeKilometers:
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.distanceFilter = kCLDistanceFilterNone
        default: break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let speed = locationManager.location!.speed
        let locationObj = locations.last!
        let coord = locationObj.coordinate
        let longitude = coord.longitude
        let latitude = coord.latitude
        let addressLocation = CLLocation(latitude: latitude, longitude: longitude)
        var totalDistance: String = ""
        
        if LocationService.resumed {
            lastLocation = locations.last
            LocationService.resumed = false
        }
        
        if !LocationService.paused {
            
           geocoder?.reverseGeocodeLocation(addressLocation) {
                [weak self] placemarks, error in
                if let lastPlacemark = placemarks?.last {
                    do {
                        
                        if let location = locations.last {
                            self?.traveledDistance += self?.lastLocation?.distance(from: location) ?? 0.0
                            totalDistance = String(format: "%.2f", (self?.traveledDistance)!*0.000621371)
                        }
                        
                        self?.currentAddress = try LocationAddress(placemark: lastPlacemark)
                        
                        if self!.startingAddress == "" {
                            
                            self?.delegate?.locationService(self!, didStart: "\(latitude) \(longitude)", using: self!.currentAddress!.addressString())
                            self?.startingAddress = "Set"
                        } else {
                            
                             self?.delegate?.locationService(self!, didUpdate: "\(latitude) \(longitude)", using: self!.currentAddress!.addressString(), didUpdate: speed, didUpdate: totalDistance)
                        }
                       
                        self?.currentLocation = locations.last!
                        self?.lastLocation = locations.last
                        
                    } catch {
                        print("Error: \(error), \(error.localizedDescription)")
                    }
                }
            }
        }
    
        // Launch Notification
        //mainView?.showTrackingNotification(title: "Location Update Fired", subtitle: "Motion Detected", body: locationSent)
    }
    
    @objc func refreshSpeed() {
        delegate?.locationService(self, speedUpdate: locationManager.location!.speed)
    }
    
    
    func startSpeedTimer() {
        speedTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,   selector: (#selector(refreshSpeed)), userInfo: nil, repeats: true)
    }
}


