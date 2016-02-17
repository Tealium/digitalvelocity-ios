//
//  DVViewController.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 5/13/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class DVViewController: UIViewController {

    override func viewDidAppear(animated:Bool){
        
            Analytics.trackView(self, data: nil)
    
    }

}