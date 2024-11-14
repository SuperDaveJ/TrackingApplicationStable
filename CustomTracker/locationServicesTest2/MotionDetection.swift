//
//  MotionDetection.swift
//  locationServicesTest2
//
//  Created by Dave Johnson on 12/12/17.
//  Copyright © 2017 Paycom. All rights reserved.
//

import Foundation
import CoreMotion

protocol MotionIdentificationDelegate: class {
    
    func motionIdentification(_ controller: IdentifyMotion, didUpdate motionType: motionType)
}

enum motionType {
    case stationary
    case walking
    case running
    case auto
}

class IdentifyMotion {
    
    let activityManager = CMMotionActivityManager()
    let pedoMeter = CMPedometer()
    var motionDetection = Timer()
    var motionIdentified = motionType.stationary
    weak var motionTypeDelegate: MotionIdentificationDelegate?
    
    func updateMotion() {
        
        if(CMMotionActivityManager.isActivityAvailable()){
            self.activityManager.startActivityUpdates(to: OperationQueue.main) { data in
                if let data = data {
                    DispatchQueue.main.async() {
                        if(data.stationary == true){
                            self.motionTypeDelegate?.motionIdentification(self, didUpdate: motionType.stationary)
                        } else if (data.walking == true){
                            self.motionTypeDelegate?.motionIdentification(self, didUpdate: motionType.walking)
                        } else if (data.running == true){
                            self.motionTypeDelegate?.motionIdentification(self, didUpdate: motionType.running)
                        } else if (data.automotive == true){
                            self.motionTypeDelegate?.motionIdentification(self, didUpdate: motionType.auto)
                        }
                    }
                }
            }
        }
    }
}
