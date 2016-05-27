//
//  TEALProgressView.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 3/9/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class TEALProgressView: UIProgressView {
    
    var finishedLoading: Bool = false
    var timer: NSTimer?
    
    func startProgress() {
        self.hidden = false
        self.progress = 0.0
        finishedLoading = false
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)

    }
    
    func timerCallback() {
        if finishedLoading == true {
            if self.progress >= 1 {
                self.hidden = true
                if let t = timer{
                    t.invalidate()
                }
            } else {
                self.progress += 0.1
            }
        } else {
            self.progress += 0.01
            if self.progress >= 0.95 {
                self.progress = 0.95
            }
        }
    }
}
