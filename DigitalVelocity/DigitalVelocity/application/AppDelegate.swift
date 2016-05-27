//
//  AppDelegate.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/4/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var beaconManager: TEALBeaconsManager = TEALBeaconsManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        #if DEBUG
            TEALLog.enableLogs(true)
        #endif
        
        // Begin Audience Stream + Parse
        Analytics.launch(application, launchOptions: launchOptions)
        Content.launch()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(restartBGAnalytics(_:)), name: notificationKeyConfigData, object: nil)
        
        // Crashlytics
        Fabric.with([Crashlytics()])
        
        // Style
        application.statusBarStyle = UIStatusBarStyle.LightContent
        
        // Load Data 
        EventLocationStore.sharedInstance().loadRemoteData(){ }
        
        // Beacons
        beaconManager.start(application, launchOptions: launchOptions)

        // Push notifications - needs to be called well after Analytics has started
        Push.start(application, launchOptions: launchOptions)

        // Login?
        if User.sharedInstance.isLoggedIn() || User.sharedInstance.skipCount > 2{
            
            var targetMenuOption : MenuOption?
            if let remoteUserInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject:AnyObject]{
                Push.application(application, didReceiveRemoteNotification: remoteUserInfo)
                targetMenuOption = MenuOption(title: menuOptions.notifications.title, storyboardId: menuOptions.notifications.storyboardId)
            }
            showApp(targetMenuOption)
        } else {
            showLogin()
        }
        
        return true
    }
    
    func restartBGAnalytics(notification: NSNotification) {
        
        guard let config = notification.object as? Config else {
            // notification did not have required object
            return
        }
        
        guard let oa = config.overrideAccount else {
            return
        }
        
        guard let op = config.overrideProfile else {
            return
        }
        
        guard let oe = config.overrideEnv else {
            return
        }
        
        Analytics.restartTealiumBGInstance(oa, profile: op, env: oe)

    }
    
    func showLogin(){
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let signIn = mainStoryboard.instantiateViewControllerWithIdentifier("Sign In") 
        window!.rootViewController = signIn
        window!.makeKeyAndVisible()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showApp", name: loginSuccessfulNotification, object: nil)
    }
    
    func showApp(){
        /*
            Work around as NSNotifcationCenter selector argument will not call the showApp(targetView:String?) correctly, even with @objec prefix
        */
        showApp(nil)
    }
    
    func showApp(targetMenuOption: MenuOption?){
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let containerViewController = Container_VC()
        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()
        if let c = targetMenuOption{
            containerViewController.centerViewController.menuOptionSelected(c)
        }
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        TEALLog.log("url:\(url.absoluteString)")
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        TEALLog.log("url:\(url.absoluteString)")
        return true
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        Analytics.sleep()
        Content.sleep()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        Analytics.wake(application)
        Content.wake()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Push.didRegisterRemoteNotificationDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        TEALLog.log("notification received:\(userInfo.description)")
        Push.application(application, didReceiveRemoteNotification: userInfo)
        showNotificationAlert(userInfo)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        TEALLog.log("notification with FetchHandler received:\(userInfo.description)")
        Push.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        showNotificationAlert(userInfo)
    }
    
    
    func showNotificationAlert(userInfo: [NSObject : AnyObject]){
        
        guard let aps = userInfo["aps"] as? NSDictionary else {
            
            TEALLog.log("Push notification did not have expected aps key:\(userInfo)")
            return
            
        }
        
        guard let alert = aps["alert"] as? String else{
            
            TEALLog.log("Push notification did not have expexted alerty key:\(userInfo)")
            return
        }
        
        let alertController = UIAlertController(title: "Digital Velocity", message: alert, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
        }))
        
        self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(3.0 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        TEALLog.log("Failed to register for remote notifications:\(error.localizedDescription)")
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        Push.application(application, performFetchWithCompletionHandler: completionHandler)
    }
}

