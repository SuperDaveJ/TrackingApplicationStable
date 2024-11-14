//
//  TimeTracking.swift
//  locationServicesTest2
//
//  Created by Dave Johnson on 12/8/17.
//  Copyright © 2017 Paycom. All rights reserved.
//

import UIKit

//let mainView = UIApplication.shared.keyWindow?.rootViewController as? ViewController

protocol TimeTrackingDelegate: class {
    
    func timeTracking(_ controller: TimeTracking, didUpdate timeElapsed: String)
}

class TimeTracking {

    var seconds = 0
    var previousSeconds = 0
    var pausedTimer: Bool = false
    var timeTrack: Timer?
    weak var delegate: TimeTrackingDelegate?
    
    @objc func updateTimer() {
        if pausedTimer {
            seconds = previousSeconds
            pausedTimer = !pausedTimer
        }
        seconds += 1
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let second = Int(seconds) % 60
        let timeTraveled = String(format:"%02i:%02i:%02i", hours, minutes, second)
        
        delegate?.timeTracking(self, didUpdate: timeTraveled)
        
        //mainView?.elapsedTime = timeTraveled
    }
    
    func startTimer() {
        timeTrack = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    func restartTimer() {
        print("Restart Timing")
        seconds = 0
        startTimer()
    }
    
    func stopTimer() {
        
        timeTrack?.invalidate()
        timeTrack = nil
        print("Timer Stopped")
    }

    func pauseTimer() {
        pausedTimer = true
        previousSeconds = seconds
        timeTrack?.invalidate()
        timeTrack = nil
        print("Timer Paused")
    }
}
