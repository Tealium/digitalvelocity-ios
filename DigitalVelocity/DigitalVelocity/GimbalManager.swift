//
//  GimbalManager.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 5/12/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class GimbalManager: NSObject {
    
    var placeManager: GMBLPlaceManager!
    var commManager: GMBLCommunicationManager!
   
    override init() {
        super.init()
        // Gimbal
        Gimbal.setAPIKey("a958f73f-ff06-4e87-a0e2-9c6e3f870516", options: nil)

    }
    
    func start(application:UIApplication?, launchOptions:[NSObject:AnyObject]?){
        placeManager = GMBLPlaceManager()
        commManager = GMBLCommunicationManager()
        placeManager.delegate = self
        commManager.delegate = self
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        TEALLog.log("User notifications enabled.")
        
        if (!GMBLPlaceManager.isMonitoring()){
            GMBLPlaceManager.startMonitoring()
            TEALLog.log("GMBLPlaceManager start monitoring called.")
        }
        GMBLCommunicationManager.startReceivingCommunications()
    }
}

extension GimbalManager: GMBLPlaceManagerDelegate, GMBLCommunicationManagerDelegate{
    
    // GMBLPlaceManager
    func placeManager(manager: GMBLPlaceManager!, didBeginVisit visit: GMBLVisit!) {
        let atts = visit.place.attributes as GMBLAttributes
        let attKeys = atts.allKeys()
        
        for attKey in attKeys{
            TEALLog.log("\(attKey): \(atts.stringForKey(attKey as! String))")
        }
    }
    
    func placeManager(manager: GMBLPlaceManager!, didEndVisit visit: GMBLVisit!) {
        TEALLog.log("Placename:\(visit.place.name), at:\(visit.departureDate)")
    }
    
    // GMBLCommunicationManager
    func communicationManager(manager: GMBLCommunicationManager!, presentLocalNotificationsForCommunications communications: [AnyObject]!, forVisit visit: GMBLVisit!) -> [AnyObject]! {
        if communications is [GMBLCommunication]{
            for comm in communications{
                TEALLog.log("comm title: \(comm.title), description:\(comm.description)")
            }
        }
        
        return communications
    }

}