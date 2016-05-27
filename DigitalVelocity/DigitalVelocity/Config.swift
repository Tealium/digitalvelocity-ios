//
//  Config.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 3/24/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//


public let keyConfigDict = "com.tealium.digitalvelocity.config"
public let keyConfigEnterThreshold = "enterThreshold"
public let keyConfigExitThreshold = "exitThreshold"
public let keyConfigWelcomeTitle = "welcomeTitle"
public let keyConfigWelcomeDescription = "welcomeDescription"
public let keyConfigWelcomeSubtitle = "welcomeSubtitle"
public let keyConfigOverrideAccount = "accountOverride"
public let keyConfigOverrideProfile = "profileOverride"
public let keyConfigOverrideEnv = "envOverride"
public let keyConfigPOIRefreshCycle = "poiRefreshCycle"
public let keyConfigPurge = "purge"
public let keyConfigRssi = "rssiThreshold"
public let keyConfigScanRate = "scanCycle" // for controlling how often new ranging data is accepted
public let keyConfigSyncRate = "syncRate" // for checking for new config data
public let keyConfigStartMonitoringHour = "startMonitoring"
public let keyConfigStopMonitoringHour = "stopMonitoring"
public let keyConfigStartMonitoringDate = "startMonitoringDate"
public let keyConfigStopMonitoringDate = "stopMonitoringDate"
public let keyConfigUpdatedAt = "updatedAt"

class Config{
    var enterThreshold : Double = 5.0
    var exitThreshold : Double = 10.0
    var isDefault : Bool = true
    var overrideAccount : String?
    var overrideProfile : String?
    var overrideEnv : String?
    var poiRefreshCycle : Double = 10.0 // seconds before sending a in_poi message
    var rssiThreshold: Int = -250
    var shouldPurge: Bool = false
    var scanRate: Double = 3        // seconds to allow new ranging data
    var syncRate: Double = 60       // 1 minute default
    var startMonitoring : Int = 5   // 5am
    var stopMonitoring: Int =   20  // 10pm
    var startMonitoringDate: NSDate = NSDate().dateByAddingTimeInterval(-86400)    // default yesterday to enable
    var stopMonitoringDate: NSDate = NSDate().dateByAddingTimeInterval(+3600)     // default later today to enable
    var welcomeDescription : String = ""
    var welcomeTitle: String = ""
    var welcomeSubtitle: String = ""
    var updatedAt: NSDate = NSDate()
    
    init(){
        
    }
    func description()-> String{
        return "isDefault:\(isDefault), enterThreshold:\(enterThreshold), exitThreshold:\(exitThreshold), poiRefreshCycle:\(poiRefreshCycle), rssi:\(rssiThreshold), purge:\(shouldPurge), scanRate:\(scanRate), syncRate:\(syncRate), startMonitoring:\(startMonitoring), startMonitoringDate:\(startMonitoringDate), stopMonitoring:\(stopMonitoring), stopMonitoringDate:\(stopMonitoringDate), welcomeTitle:\(welcomeTitle), welcomeDescription:\(welcomeDescription), welcomeSubtitle:\(welcomeSubtitle), updatedAt:\(updatedAt), accountOverride:\(overrideAccount), profileOverride:\(overrideProfile), envOverride:\(overrideEnv)"
    }
    
    func isEqualToConfig(otherConfig:Config)->Bool{
        return updatedAt.isEqualToDate(otherConfig.updatedAt)
    }
    
    func serialize()-> [String:AnyObject]{
        var dict = [
            keyConfigEnterThreshold : enterThreshold,
            keyConfigExitThreshold : exitThreshold,
            keyConfigRssi : rssiThreshold,
            keyConfigPOIRefreshCycle : poiRefreshCycle,
            keyConfigPurge : shouldPurge,
            keyConfigScanRate : scanRate,
            keyConfigStartMonitoringHour : startMonitoring,
            keyConfigStartMonitoringDate : startMonitoringDate,
            keyConfigStopMonitoringHour : stopMonitoring,
            keyConfigStopMonitoringDate : stopMonitoringDate,
            keyConfigSyncRate : syncRate,
            keyConfigWelcomeDescription : welcomeDescription,
            keyConfigWelcomeSubtitle : welcomeSubtitle,
            keyConfigWelcomeTitle : welcomeTitle,
        ] as [String:AnyObject]
        
        // Optional overrides
        if let oa = overrideAccount {
            if let op = overrideProfile {
                if let oe = overrideEnv {
                    dict[keyConfigOverrideAccount] = oa
                    dict[keyConfigOverrideProfile] = op
                    dict[keyConfigOverrideEnv] = oe
                }
            }
        }
        
        return dict
    }
    
    func save(){
        let serializedConfig = self.serialize()
        save(serializedConfig, key: keyConfigDict)
    }
    
    class func loadConfig() -> Config{
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedConfigDict = defaults.objectForKey(keyConfigDict) as? [String: AnyObject]{
            if let loadedConfig = Config.deserialize(savedConfigDict){
                return loadedConfig
            }
        }
        return Config()
    }
    
    class func deserialize(dictionary:[String:AnyObject])->Config?{
        let config = Config()
        
        // TODO: add error handling?
        
        if let ent = dictionary[keyConfigEnterThreshold] as? Double{
            config.enterThreshold = ent
        }
        
        if let ext = dictionary[keyConfigExitThreshold] as? Double{
            config.exitThreshold = ext
        }
        
        if let r = dictionary[keyConfigRssi] as? Int{
            config.rssiThreshold = r
        }
        
        if let prc = dictionary[keyConfigPOIRefreshCycle] as? Double{
            config.poiRefreshCycle = prc
        }
        
        if let p = dictionary[keyConfigPurge] as? Bool{
            config.shouldPurge = p
        }
        
        if let sr = dictionary[keyConfigScanRate] as? Double{
            config.scanRate = sr
        }
        
        if let x = dictionary[keyConfigStartMonitoringHour] as? Int{
            config.startMonitoring = x
        }
        
        if let x = dictionary[keyConfigStartMonitoringDate] as? NSDate{
            config.startMonitoringDate = x
        }
        
        if let x = dictionary[keyConfigStopMonitoringHour] as? Int{
            config.stopMonitoring = x
        }
        
        if let x = dictionary[keyConfigStopMonitoringDate] as? NSDate{
            config.stopMonitoringDate = x
        }
        
        if let x = dictionary[keyConfigSyncRate] as? Double{
            config.syncRate = x
        }
        
        if let x = dictionary[keyConfigWelcomeTitle] as? String{
            config.welcomeTitle = x
        }
        
        if let x = dictionary[keyConfigWelcomeSubtitle] as? String{
            config.welcomeSubtitle = x
        }
        
        if let x = dictionary[keyConfigWelcomeDescription] as? String{
            config.welcomeDescription = x
        }
        
        if let x = dictionary[keyConfigUpdatedAt] as? NSDate{
            config.updatedAt = x
        }
        
        if let x = dictionary[keyConfigOverrideAccount] as? String {
            config.overrideAccount = x
        }
        
        if let x = dictionary[keyConfigOverrideProfile] as? String {
            config.overrideProfile = x
        }
        
        if let x = dictionary[keyConfigOverrideEnv] as? String {
            config.overrideEnv = x
        }
        
        return config
    }
    
    private func save(value:AnyObject?, key:String){
        if value != nil{
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(value, forKey: key)
            defaults.synchronize()
        }
    }
}
