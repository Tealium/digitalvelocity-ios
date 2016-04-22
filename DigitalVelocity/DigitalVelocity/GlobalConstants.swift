//
//  GlobalConstants.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 3/12/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

public let defaultImageName = "DV_Icon_40x40"
public let defaultTransparentImageName = "DV_Icon_t_180x180"

public let defaultImagePath = NSBundle.mainBundle().pathForResource(defaultImageName, ofType: "png")
public let defaultTransparentImagePath = NSBundle.mainBundle().pathForResource(defaultTransparentImageName, ofType: "png")
public let notificationKeyConfigData = "com.tealium.digitalvelocity.newconfig"
public let notificationKeyNoConfigDataYet = "com.tealium.digitalvelocity.noconfig"

private let iosVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
public let iOS8 = iosVersion >= 8.0
public let iOS7 = iosVersion >= 7.0 && iosVersion < 8.0

let ph = ParseHandler.sharedInstance

public let DefaultTransparentImageData:NSData = NSData(contentsOfFile:defaultTransparentImagePath!)!