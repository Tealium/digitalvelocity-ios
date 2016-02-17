//
//  Content.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/22/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import Foundation

class Content {
    
    class func launch() {
        ph.launchOrWake()
    }
    
    class func wake() {
        ph.launchOrWake()
    }
    
    class func sleep() {
        ph.sleep()
    }
    
}