//
//  Push.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/22/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import Foundation

class Push {
    
    class func start(application:UIApplication, launchOptions:[NSObject:AnyObject]?){
        
        let userNotificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
        
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    
    }
    
    class func register(id:String?){
        
        guard let id = id else {
            TEALLog.log("No vid set for Push.")
            return
        }
        
        let prefixed = "vid-" + id
        ph.registerForChannel(prefixed)
        ph.userParseChannel = prefixed
        
    }
    
    // MARK: APP DELEGATE
    
    class func didRegisterRemoteNotificationDeviceToken(deviceToken:NSData){
        
        ph.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken, completion:{ (successful, error) -> () in
           
            if successful == false  {
                TEALLog.log("Could not register for remote notifications. Error:\(error)")
                return
            }
            
            guard let vid = Analytics.vid() else {
                TEALLog.log("No vid in Push to register channel with.")
                return
            }
            
            self.register(vid)

        })
        
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