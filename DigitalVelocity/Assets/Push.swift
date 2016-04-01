//
//  Push.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/22/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import Foundation

class Push {
    
    // MARK: APP DELEGATE
    
    class func didRegisterRemoteNotificationDeviceToken(deviceToken:NSData){
        ph.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }
    
    class func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        processRemoteNotificationForParse(userInfo)
        
    }
    
    class func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        processRemoteNotificationForParse(userInfo)
        
    }
    
    class func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
    }
    
    // MARK: NOTIFICATIONS
    
    class func processRemoteNotificationForParse(userInfo: [NSObject:AnyObject]){
        if let aps = userInfo["aps"] as? NSDictionary{
            if let alert = aps["alert"] as? String{
                EventDataStore.sharedInstance().notificationsDatasource().notifications.addNotification(alert)
            }
        }
    }
    
}