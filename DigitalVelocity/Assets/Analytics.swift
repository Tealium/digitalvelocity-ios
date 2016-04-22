//
//  Analytics.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/22/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import Foundation
import TealiumIOS

public let asKeyAppName = "app_name"
public let asKeyIsAppActive = "is_app_active"
public let asKeyEventName = "event_name"
public let asKeyEmail = "email"
public let asKeyBeaconId = "beacon_id"
public let asKeyBeaconRssi = "beacon_rssi"
public let asKeyBeaconDetectionDisabled = "beacon_detection_disabled"
public let asKeyParseChannel = "parse_channel"
public let asKeyScreenTitle = "screen_title"
public let asValueEnterPOI = "enter_poi"
public let asValueExitPOI = "exit_poi"
public let asValueInPOI = "in_poi"
public let asValueLaunch = "m_launch"
public let asValueSleep = "m_sleep"
public let asValueTap = "m_tap"
public let asValueWake = "m_wake"
public let asValueViewChange = "m_view"
public let asValueChatSent = "chat_sent"

public let tealiumBGInstanceID = "tealium"
public let tealiumDemoInstanceID = "demo"
public let tealiumDemoUserDefaultsConfigKey = "com.tealium.demo.config"

public let tealiumAccountKey = "account"
public let tealiumProfileKey = "profile"
public let tealiumEnvironmentKey = "environment"
public let tealiumDemoTraceIdKey = "com.tealium.demo.traceId"

class Analytics {
    
    class func vid()->String?{
        
        let tealium = Tealium.instanceForKey(tealiumBGInstanceID)
        
        guard let uuid = tealium?.persistentDataSourcesCopy()[TEALDataSourceKey_VisitorID] as? String else {
            
            TEALLog.log("Problem retrieving UUID from tealium persistence copy: \(tealium?.persistentDataSourcesCopy())")
            return nil
        }
        
        return uuid
    }
    
    class func updateTealiumDemoInstance(account: String?, profile: String?, environment: String?) -> Bool{
        
        // Enable, disable or update Demo Instance
        var submissionDict  = [ String : String ]()
        
        if let account = account {
            submissionDict[tealiumAccountKey] = account
        }
        if let profile = profile {
            submissionDict[tealiumProfileKey] = profile
        }
        if let env = environment {
            submissionDict[tealiumEnvironmentKey] = env
        }
        
        // Save new demo settings
        var savedConfig = [String: AnyObject]()
        
        savedConfig[tealiumDemoUserDefaultsConfigKey] = submissionDict
        
        NSUserDefaults.standardUserDefaults().setValuesForKeysWithDictionary(savedConfig)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Reset demo instance
        Tealium.destroyInstanceForKey(tealiumDemoInstanceID)
        
        setupTealiumDemoInstance()
        
        print(currentDemoConfig)
        
        return true
        
    }
    
    class func updateDemoTraceId(traceId: String?) -> Bool {
        
        // Convert nil to empty string, if needed
        var traceString = ""
        if let traceId = traceId {
            traceString = traceId
        }
        
        // Enable or disable Trace
        if traceString != ""  {
            Analytics.startTrace(traceString)
            print("Trace started for: \(traceString)")
            
        } else{
            print("Trace stopped.")
            Analytics.stopTrace()
        }
        
        // Save update to persistence
        NSUserDefaults.standardUserDefaults().setValue(traceString, forKey: tealiumDemoTraceIdKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        return true
    }
    
    
    // MARK: LIFECYCLE
    
    class func wake(application:UIApplication){
        
        Analytics.track(asValueWake, isView: false, data: nil)
    }
    
    class func sleep(){

        Analytics.track(asValueSleep, isView: false, data: nil)
    }
    
    class func launch(application: UIApplication, launchOptions:[NSObject: AnyObject]?){
        
        // TRACKING
        if (User.sharedInstance.optInTracking){
            
            Analytics.setupTealium()
            
        }
        
        // Kick up prior trace
        if let tid = Analytics.currentTraceId(){
            Analytics.startTrace(tid)
        } else {
            Analytics.stopTrace()
        }
    }
    
    
    // MARK: INIT
    
    class private func setupTealium() {
        
        self.setupTealiumBGInstance()
        self.setupTealiumDemoInstance()
        
    }
    
    private class func setupTealiumBGInstance() {
        
        let account = TEALCredentials.idFor(TealiumAccount)
        let profile = TEALCredentials.idFor(TealiumProfile)
        let env = TEALCredentials.idFor(TealiumEnv)
        
        let config = TEALConfiguration.init(account: account, profile: profile, environment: env)
        
        Tealium.newInstanceForKey(tealiumBGInstanceID, configuration: config)
    }
    
    private class func setupTealiumDemoInstance() {
        
        guard let demoConfig = self.currentDemoConfig()else{
            destroyDemoInstance()
            return
        }
        
        guard let account = demoConfig[tealiumAccountKey] as? String else {

            destroyDemoInstance()

            // TODO: error handling
            
            return
        }
        
        guard let profile = demoConfig[tealiumProfileKey] as? String else {
            
            destroyDemoInstance()

            // TODO: error handling
            
            return
        }
        
        guard let environment = demoConfig[tealiumEnvironmentKey] as? String else {
            
            destroyDemoInstance()

            // TODO: error handling
            
            return
        }
        
        let config = TEALConfiguration.init(account: account, profile: profile, environment: environment)
        
        Tealium.newInstanceForKey(tealiumDemoInstanceID, configuration: config)
        
        
    }

    
    // MARK: ACCESSORS
    
    
    class func currentDemoInstance() -> Tealium? {
        
        // For testing
        
        return Tealium.instanceForKey(tealiumDemoInstanceID)
        
    }
    
    
    class func currentDemoConfig()-> [NSObject: AnyObject]? {
        
        let userPreferences = NSUserDefaults.standardUserDefaults()
        
        guard let demoConfig = userPreferences.dictionaryForKey(tealiumDemoUserDefaultsConfigKey)  else {
            
            // TODO: error handling
            
            return nil
        }
        return demoConfig
    }
    
    class func currentTraceId() -> String? {
        
        let userPreferences = NSUserDefaults.standardUserDefaults()
        
        guard let traceId = userPreferences.valueForKey(tealiumDemoTraceIdKey) as? String else {
            
            // TODO: error handling
            
            return nil
        }
        return traceId
        
    }
    
    class func destroyDemoInstance() {
                
        Tealium.destroyInstanceForKey(tealiumDemoInstanceID)

        NSUserDefaults.standardUserDefaults().removeObjectForKey(tealiumDemoUserDefaultsConfigKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    // MARK: TRACE
    
    class func startTrace(traceId:String){
        guard let demoInstance = Tealium.instanceForKey(tealiumDemoInstanceID) else{
            return
        }
        
        demoInstance.joinTraceWithToken(traceId)
    }
    
    class func stopTrace(){
        guard let demoInstance = Tealium.instanceForKey(tealiumDemoInstanceID) else{
            return
        }
        demoInstance.leaveTrace()
    }
    
    
    // MARK: TRACKING
    
    class func trackView(viewController: UIViewController){
        Analytics.trackView(viewController, data: nil)
    }
    
    class func trackView(viewController: UIViewController, data: [NSObject : AnyObject]?){
        if let t = viewController.restorationIdentifier{
            Analytics.track(t, isView:  true, data: data)
        }
    }
    
    class func trackEvent(title: String) {
        Analytics.track(title, isView: false, data: nil)
    }
    
    class func track(title: String, isView: Bool, data: [NSObject: AnyObject]?) {
        
        // Stop check
        if (!User.sharedInstance.optInTracking){
            print("All tracking manually disabled.")
            return
        }
        
        var trackData = [NSObject : AnyObject]()
        
        if let data = data {
            trackData.addEntriesFrom(data)
        }
        
        trackData.addEntriesFrom(self.additionalTrackData())
        
        let tealiumInstance = Tealium.instanceForKey(tealiumDemoInstanceID);
        
        let tealiumBGInstance = Tealium.instanceForKey(tealiumBGInstanceID);
        
        if tealiumInstance == nil{
            
            // Will print too often
//            print("Tealium demo instance not found")
            
        }
        
        if tealiumBGInstance == nil{
            
            print("Tealium BG instance not found")
            
        }
        
        if isView == true {
            tealiumBGInstance?.trackViewWithTitle(title, dataSources: trackData)
            tealiumInstance?.trackViewWithTitle(title, dataSources: trackData)
        } else {
            tealiumBGInstance?.trackEventWithTitle(title, dataSources: trackData)
            tealiumInstance?.trackEventWithTitle(title, dataSources: trackData)
        }
        
    }
    
    private class func additionalTrackData() -> [NSObject : AnyObject] {
        
        var trackData = [ String: AnyObject]()
        
        if let email = User.sharedInstance.email{
            trackData.updateValue(email, forKey: asKeyEmail)
        }
        
        trackData.updateValue(ph.userParseChannel, forKey: asKeyParseChannel)
        
        trackData.updateValue("Digital Velocity", forKey: asKeyAppName)
        
        var state = "false"
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Active{
            state = "true"
        }
        trackData.updateValue(state, forKey: asKeyIsAppActive)
        
        if TEALBeaconsManager.isBeaconDetectionDisabled(){
            trackData.updateValue("true", forKey: asKeyBeaconDetectionDisabled)
        }
        
        return trackData
    }

    
}