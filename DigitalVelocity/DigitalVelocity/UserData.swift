//
//  UserData.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 3/30/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import Foundation

// Parse property keys
let userDataKey_parse_colorBrightness = "colorBrightness"
let userDataKey_parse_colorHue = "colorHue"
let userDataKey_parse_colorSaturation = "colorSaturation"
let userDataKey_parse_email = "email"
let userDataKey_parse_image = "image"
let userDataKey_parse_music = "music"
let userDataKey_parse_name = "name"
let userDataKey_parse_video = "video"

// Final DataSource keys
let userDataKey_vip_colorBrightness = "vip_color_brightness"
let userDataKey_vip_colorHue = "vip_color_hue"
let userDataKey_vip_colorSaturation = "vip_color_saturation"
let userDataKey_vip_email = "vip_email"
let userDataKey_vip_image = "vip_image"
let userDataKey_vip_music = "vip_music"
let userDataKey_vip_name = "vip_name"
let userDataKey_vip_video = "vip_video"

class UserData {
        
    class func getVIPPreferences(completion:(preferences:[ NSObject : AnyObject]?, error: NSError?)->())->Void{
        
        guard let email = User.sharedInstance.email else {
            completion(preferences:nil, error:nil)
            return
        }
        
        EventDataStore.sharedInstance().fetchSpecificRecord(PARSE_CLASS_KEY_ATTENDEE, key: ph.keyEmail, value: email) { (dictionary, error) -> () in
            
            completion(preferences: dictionary, error: error)
        }
        
    }
    
}