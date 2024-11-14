//
//  ViewController.swift
//  guage2
//
//  Created by Dave Johnson on 12/6/17.
//  Copyright © 2017 Paycom. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var speedView: SpeedView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speedView.curValue = 3.5
        
        let when = DispatchTime.now() + 5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.speedView.curValue = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

