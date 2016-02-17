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
        
        
        // Begin Audience Stream + Parse
        Analytics.launch(application, launchOptions: launchOptions)
        Content.launch()
        
        // Crashlytics
        Fabric.with([Crashlytics()])
        
        // Style
        application.statusBarStyle = UIStatusBarStyle.LightContent
        
        // Load Data 
        EventDataStore.sharedInstance().loadRemoteData()
        EventLocationStore.sharedInstance().loadRemoteData(){ }
        
        // Beacons
        beaconManager.start(application, launchOptions: launchOptions)
        
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
//        beaconManager.startBackgroundRanging(nil)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        Analytics.wake(application)
        Content.wake()
//        beaconManager.stopBackgroundRanging(nil)
//        beaconManager.startRanging(nil)
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
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        TEALLog.log("notification with FetchHandler received:\(userInfo.description)")
        Push.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        TEALLog.log("Failed to register for remote notifications:\(error.localizedDescription)")
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        Push.application(application, performFetchWithCompletionHandler: completionHandler)
    }
}

