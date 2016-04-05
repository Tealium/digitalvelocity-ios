//
//  TEALBeaconsManager.swift
//  iBeaconTest
//
//  Created by Jason Koo on 1/28/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit
import CoreLocation

/**
This class provides convenience methods to configure and manage Core Location for the purposes of monitoring and reporting iBeacons. 

Beacon UUIDs must be registered as a target beacon to range for. If found they will be listed in the foundBeacons property.  If the device has left a beacon's range or otherwise lost the beacon, an async_after call, of the timeout lengh, is made to see if the beacon is still not found.  If so, that beacon is sent to the leftBeacon closure.

:Notes:  "ranging" here is synonmous with "looking for"
*/

class TEALBeaconsManager: CLLocationManager {
   
    var areAuthorized : Bool = false
    var areRanging : Bool = false
    var beaconsFoundCompletionHandler:((beacons:NSArray, region:CLBeaconRegion)->())?
    var bgTask: UIBackgroundTaskIdentifier?
    var bgTimer: NSTimer?
    var config: Config = Config()
    var configLoaded : Bool =               false
    var isBackgroundRangingEnabled =        true
    
    var imprintsAll : [String:TEALImprint] = [String:TEALImprint]()
    var imprintCurrent : TEALImprint?
    
    var lastRefreshedAt : NSDate?
    var locationManager =               CLLocationManager()
    var startMonitoring : Int =         5
    var stopMonitoring : Int =          17
    var targetBeacons =                 NSMutableDictionary()
    
    let inPOIRefreshCycle: Double =         10

    private let keyImprintCurrent = "com.tealium.digitalvelocity.ic"
    
    // MARK: SETUP
    override init() {
        super.init()
        locationManager.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateConfig:", name: notificationKeyConfigData, object: nil)
    }
    
    func start(application:UIApplication, launchOptions:[NSObject:AnyObject]?){
        self.addBeaconRegionForRanging("Estimote Beacons", uuidString: "b9407f30-f5f8-466e-aff9-25556b57fe6d")
        
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Active{
            self.startBackgroundRanging(nil)
        } else {
            self.startRanging(nil)
        }
    }
    
    func updateConfig(notification:NSNotification){
        if let newConfig = notification.object as? Config{
            self.config = newConfig
            TEALLog.log("Beacon Manager config updated.")
            self.startMonitoringRegions()
        }
    }
    
    // MARK: CLASS PUBLIC
    class func isBeaconDetectionDisabled()->Bool{
        
        switch(CLLocationManager.authorizationStatus()){
        case .AuthorizedAlways:
            fallthrough
        case .AuthorizedWhenInUse:
            fallthrough
        case .NotDetermined:
            return false
            
        case .Denied:
            fallthrough
        case .Restricted:
            return true
        }
        
    }
    
    // MARK: PUBLIC
    func addBeaconRegionForRanging(name:NSString, uuidString:NSString){
        let uuid: NSUUID = NSUUID(UUIDString: uuidString as String)!
        let region: CLBeaconRegion = CLBeaconRegion(proximityUUID:uuid, identifier: name as String)
        region.notifyEntryStateOnDisplay = true
        region.notifyOnEntry = true
        region.notifyOnExit = true
        self.targetBeacons[region] = NSArray()
        self.startMonitoringRegions()
        TEALLog.log("Added beacon with id:\(uuid) to targetBeacons:\(self.targetBeacons)")
    }
    
    func enableBackgroundRanging(){
        isBackgroundRangingEnabled = true
    }
    
    func disableBackgroundRanging(){
        isBackgroundRangingEnabled = false
    }
    
    func startMonitoringRegions(){
        if canMonitor() == false{
            return
        }
        
        if isAuthorized() == false{
            permissionsChange()
            return
        }
        
        for beaconRegion in self.targetBeacons.allKeys {

            locationManager.startMonitoringForRegion(beaconRegion as! CLRegion)
            
        }
        
        TEALLog.log("Now monitoring beacon regions")

    }
    
    func startRanging(timer: NSTimer?){
        if TEALBeaconsManager.isBeaconDetectionDisabled() == true{
            if bgTimer != nil{
                self.stopBackgroundRanging(nil)
            }
            return
        }
        
        if isAuthorized() == false{
            permissionsChange()
            return
        }
        
        for beaconRegion in self.targetBeacons.allKeys {
            
            if let beaconRegion = beaconRegion as? CLBeaconRegion{
                locationManager.startRangingBeaconsInRegion(beaconRegion)
            }

        }
        
        areRanging = true
        
    }
    
    func stopMonitoringRegions(){
        
        for beaconRegion in self.targetBeacons.allKeys {

            if let beaconRegion = beaconRegion as? CLRegion{
                locationManager.stopMonitoringForRegion(beaconRegion)
            }
        }
    }
    
    func stopRanging(){
        if areRanging == true{
            
            for beaconRegion in self.targetBeacons.allKeys {

                if let beaconRegion = beaconRegion as? CLBeaconRegion{
                    locationManager.stopRangingBeaconsInRegion(beaconRegion)
                    TEALLog.log("No longer listening for beacon region:\(beaconRegion.description) current delegate:\(locationManager.delegate)")
                }
            }
        }
        areRanging = false
    }
    
    func startBackgroundRanging(notification:NSNotification?){
        if canMonitor(){
            if TEALBeaconsManager.isBeaconDetectionDisabled(){
                return
            }
            
            self.bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in            
                UIApplication.sharedApplication().endBackgroundTask(self.bgTask!)
                self.bgTask = UIBackgroundTaskInvalid
            })
            bgTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:"startRanging:", userInfo: nil, repeats: true)
        }
    }
    
    func stopBackgroundRanging(notification:NSNotification?){
        // Only stop backgrounding timer, continue ranging
        if bgTimer != nil{
            if bgTask != nil{
                UIApplication.sharedApplication().endBackgroundTask(bgTask!)
                bgTask = UIBackgroundTaskInvalid
                bgTimer?.invalidate()
                TEALLog.log("No longer listening for nearby beacons in background mode")
            }
            stopRanging()
        }
    }
    
    // MARK: INTERNAL
    
    private func permissionsChange(){
        switch(CLLocationManager.authorizationStatus()){
        case .AuthorizedAlways:
            TEALLog.log("Location manager authorized")
            fallthrough
        case .AuthorizedWhenInUse:
            startMonitoringRegions()
            break;
        case .Denied:
            TEALLog.log("Location services denied for app.")
            break;
        case .NotDetermined:
            if areAuthorized != true{
                TEALLog.log("Requesting location services authorization.")
                if iOS8{
                    if #available(iOS 8.0, *) {
                        locationManager.requestAlwaysAuthorization()
                    } else {
                        // Fallback on earlier versions
                    }
                }
                areAuthorized = true
            }
            break;
        case .Restricted:
            TEALLog.log("Location services restricted for app.")
            break;
        }
    }
    
    private func isAuthorized()->Bool{
        if #available(iOS 8.0, *) {
            if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
                return true
            }
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 8.0, *) {
            if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse{
                return true
            }
        } else {
            // Fallback on earlier versions
        }
        return false
    }
    
    private func canRefresh()->Bool{
        // Clunky
        if let lrd = lastRefreshedAt{
            if NSDate().timeIntervalSinceDate(lrd) < config.scanRate{
                return false
            }
        }
        lastRefreshedAt = NSDate()
        return true
    }
    
    private func canMonitor()->Bool{
        
        #if DEBUG
            return true
        #endif
        
        // Are we within the allowed monitoring date and time range?
        let now = NSDate()
        let nowInterval = now.timeIntervalSince1970
        if nowInterval < config.startMonitoringDate.timeIntervalSince1970 || nowInterval > config.stopMonitoringDate.timeIntervalSince1970{
            TEALLog.log("Can not monitor, outside of monitoring dates of \(config.startMonitoringDate.timeIntervalSince1970) and \(config.stopMonitoringDate.timeIntervalSince1970), now:\(nowInterval)")
            return false
        }
        
        // Are we within the allowed daily start and end times?
        let cal = NSCalendar.currentCalendar()
        let nowComponents = cal.components(NSCalendarUnit.Hour, fromDate: now)
        let nowHour = nowComponents.hour
        
        if nowHour < config.startMonitoring || nowHour > config.stopMonitoring{
            TEALLog.log("Can not monitor, outside of monitoring hours.")
            return false
        }
        
        return true
    }

    private func updateFoundBeacons(beacons:[AnyObject]!){

        if let n = nearestFilteredBeacon(beacons){
            
            // Load or create imprint for associated beacon
            let ifn = imprintForBeacon(n)
            ifn.update(n)

//            TEALLog.log("Imprint for nearest beacon:\(ifn)")
            
            let ni = nearestImprint(ifn)
            
            // Load imprintCurrent if unavailable
            if imprintCurrent == nil{
                imprintCurrent = loadImprintCurrent()
                deleteSavedImprintCurrent()
            }
            
            if ni.isEqualToImprint(imprintCurrent) == false{
                if UIApplication.sharedApplication().applicationState == UIApplicationState.Active{
                    if ni.passThreshold(config.enterThreshold){
                        if imprintSupercedesCurrent(ni){
                            confirmNewNearestImprint(ni)
                        }
                    }
                }
                else {
                    confirmNewNearestImprint(ni)
                }
            }
        } else {
            noBeaconsFound()
        }
    }
    
    private func noBeaconsFound(){
        if let ic = imprintCurrent{
            self.resetImprintsExceptFor(ic)
            if ic.lastFoundAtPassedThreshold(config.exitThreshold){
                confirmedLeftImprint(ic)
            }
        }
    }
    
    private func imprintSupercedesCurrent(imprint:TEALImprint)->Bool{
        if let ic = imprintCurrent{
            // Checking current imprints pool for the currently tracked imprint
            if let current = imprintsAll[ic.beaconId]{
                
                if imprint.beaconRssi > current.beaconRssi{
                    // New imprint is now closer, but it may be a blip
                    // Contesting with current imprint with lower rssi - wait for more definitive data (current disappears or duration with newer imprint duration substantially exceeds duration with current
//                    if (imprint.durationInRangeOf() - current.durationInRangeOf()) < config.enterThreshold{
                        return false
//                    }
                }
            }
        }
        return true
    }
    
    private func imprintForBeacon(beacon:CLBeacon)->TEALImprint{

        // Grabs existing imprint
        if let targetImprint = imprintsAll[beacon.compositeId()]{
            return targetImprint
        }
        
        // create new imprint
        else {
            let newImprint = TEALImprint(beacon: beacon)
            imprintsAll.updateValue(newImprint, forKey: newImprint.beaconId)
            return newImprint
        }
    }
    
    private func resetImprintsExceptFor(imprintToKeep:TEALImprint?){
        let all = imprintsAll
        
        for key in all.keys {

            if key != imprintToKeep?.beaconId{
                imprintsAll.removeValueForKey(key)
            }
        }
    }
    
    private func confirmNewNearestImprint(imprint:TEALImprint){
        
        if let current = imprintCurrent{
            confirmedLeftImprint(current)
        }
        
        confirmedNewNearestImprint(imprint)
        resetImprintsExceptFor(imprint)
    }
    
    private func confirmedNewNearestImprint(imprint:TEALImprint){
        setNewImprintCurrent(imprint)
        
        let data = [asKeyEventName : asValueEnterPOI, asKeyBeaconId:imprint.beaconId, asKeyBeaconRssi:String(imprint.beaconRssi)]
        
        self.trackDataWithVIPInfo(asValueEnterPOI, data: data)
    
        TEALLog.log("FOUND imprint:\(imprint.description)\n\n")
        checkFutureInImprint(imprint)
    }
    
    private func setNewImprintCurrent(imprint:TEALImprint){
        imprint.foundAt = NSDate().timeIntervalSince1970
        imprint.lastFoundAt = imprint.foundAt
        imprintCurrent = imprint
        saveImprintCurrent()
    }
    
    func checkFutureInImprint(imprint:TEALImprint){
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(inPOIRefreshCycle * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.confirmStillInImprint(imprint)
        }
    }
    
    func trackDataWithVIPInfo(title: String, data: [NSObject:AnyObject]){
        
        var finalData = [ NSObject : AnyObject]()
        
        finalData.addEntriesFrom(User.sharedInstance.vipData)
        
        finalData.addEntriesFrom(data)
        
        Analytics.track(title, isView: false, data: finalData)
        
    }
    
    func confirmStillInImprint(imprint:TEALImprint){
        if imprint == imprintCurrent{
            if imprint.lastFoundAtPassedThreshold(config.exitThreshold){
                confirmedLeftImprint(imprint)
            } else if canMonitor() {
                
                let data = [asKeyEventName : asValueInPOI, asKeyBeaconId:imprint.beaconId, asKeyBeaconRssi:String(imprint.beaconRssi)]
                
                self.trackDataWithVIPInfo(asValueInPOI, data: data)
                
                checkFutureInImprint(imprint)
            }
        }
    }
    
    private func confirmedLeftImprint(imprint:TEALImprint){
        imprintCurrent = nil
        deleteSavedImprintCurrent()
        let data = [asKeyEventName : asValueExitPOI ,
            asKeyBeaconId:imprint.beaconId,
            asKeyBeaconRssi:String(imprint.beaconRssi)]
        
        self.trackDataWithVIPInfo(asValueExitPOI, data: data)
        
        TEALLog.log("LEFT imprint:\(imprint.description)")
    }
    
    private func nearestImprint(newImprint:TEALImprint)->TEALImprint{
        // Adds new imprint then returns the nearest of all
        imprintsAll.updateValue(newImprint, forKey: newImprint.beaconId)
        
        // Compare against any existing
        if imprintsAll.count > 1{
            let firstImprintKey = ([String](imprintsAll.keys))[0]
            if var nearest: TEALImprint = imprintsAll[firstImprintKey]{
                
                for imprint in imprintsAll.values{
//                for (key, imprint): (String, TEALImprint) in imprintsAll{
                    
                    if imprint.beaconProximity != CLProximity.Unknown{
                        if imprint.beaconRssi > nearest.beaconRssi{
                            nearest = imprint
                        }
                    }
                }
                return nearest
            }
        }
        
        // Return new imprint if no other imprints available
        return newImprint
    }
    
    private func nearestFilteredBeacon(foundBeacons: [AnyObject]) -> CLBeacon?{
        
        var nearest = nearestBeacon(foundBeacons)
        
//        TEALLog.log("Nearest beacon now: \(nearest)")

        // Filtering for unknown status beacons
        if nearest?.proximity == CLProximity.Unknown{
            nearest = nil
        }
        
        // Filtering out low rssi
        if nearest?.rssi < config.rssiThreshold{
            nearest = nil
        }
        
        return nearest
    }
    
    private func nearestBeacon(foundBeacons: [AnyObject]) -> CLBeacon?{

        if foundBeacons.count > 0{
            if var nearest = foundBeacons[0] as? CLBeacon{
                for beacon in foundBeacons{
                    if let b = beacon as? CLBeacon{

                        if b.proximity != CLProximity.Unknown{
                            if b.rssi < nearest.rssi{
                                nearest = b
                            }
                        }
                    }
                }
                return nearest
            }
        }
        return nil
    }
    
    
    private func saveImprintCurrent(){
        if let ic = imprintCurrent{
            let dict = TEALImprint.serialize(ic)
            save(dict, key:keyImprintCurrent)
        }
    }

    private func deleteSavedImprintCurrent(){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(keyImprintCurrent)
    }

    
    private func save(value:NSDictionary, key:String){
        let defaults = NSUserDefaults.standardUserDefaults()
        let savedValue = defaults.objectForKey(key) as? NSDictionary
        if savedValue?.isEqualToDictionary(value as [NSObject : AnyObject]) == false{
            defaults.setObject(value, forKey: key)
            defaults.synchronize()
        }
    }
    
    private func loadImprintCurrent()->TEALImprint?{
        let defaults = NSUserDefaults.standardUserDefaults()
        if let imprint = defaults.objectForKey(keyImprintCurrent) as? NSDictionary{
            if let ic = TEALImprint.deserialize(imprint){
                return ic
            }
        }
        return nil
    }
    
    /*
        NOTE: Save config handled by ParseHandler
    **/
    private func loadConfig(){
        
        // This method did not do anything - commented out to suppress warnings
        
//        if self.configLoaded == false{
//            let defaults = NSUserDefaults.standardUserDefaults()
//            if let config = defaults.objectForKey(keyConfigDict) as? NSDictionary{
////                self.configRSSIThresholh = config[]
//            }
//        }
    }

}

// MARK: CLLocation Manager Delegate
extension TEALBeaconsManager: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        permissionsChange()
    }
    
    // This is the method called by location manager when new beacons are discovered
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if canMonitor(){
            if canRefresh(){
                self.updateFoundBeacons(beacons)
                self.beaconsFoundCompletionHandler?(beacons: beacons, region: region)
            }
        } else {
            stopRanging()
        }
    }
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        TEALLog.log("Ranging Beacons failed for beacon region: \(region.description) error: \(error.localizedDescription)")
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        TEALLog.log("Entered beacon region: \(region.description)")

        if canMonitor(){
            if UIApplication.sharedApplication().applicationState == UIApplicationState.Active{
                startRanging(nil)
            }
            else {
                startBackgroundRanging(nil)
            }
        } else {
            stopBackgroundRanging(nil)
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        TEALLog.log("Exited beacon region: \(region.description)")
        
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Active{
            stopRanging()
        }
        
        else {
            stopBackgroundRanging(nil)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        TEALLog.log("Location manger failed:\(error.localizedDescription)")
        TEALLog.log(error.localizedDescription)
    }
}

extension CLBeacon{
    func compositeId()-> String{
        return "\(self.proximityUUID.UUIDString).\(self.major).\(self.minor)"
    }
    
    func isEqualToBeacon(beacon:CLBeacon) -> Bool{
        if beacon.compositeId() != self.compositeId(){
            return false
        }
        return true
    }
}

class TEALImprint: NSObject{
    var beaconId: String!
    var beaconRssi: Int!
    var beaconProximity: CLProximity!
    var foundAt: NSTimeInterval = NSDate().timeIntervalSince1970
    var lastFoundAt: NSTimeInterval!

    init(beacon:CLBeacon){
        super.init()
        beaconId = beacon.compositeId()
        beaconRssi = beacon.rssi
        beaconProximity = beacon.proximity
        lastFoundAt = foundAt
    }
    
    init(beaconId: String, rssi: Int, proximity: CLProximity, foundAt: NSTimeInterval, lastFoundAt: NSTimeInterval){
        super.init()
        self.beaconId = beaconId
        self.beaconRssi = rssi
        self.beaconProximity = proximity
        self.foundAt = foundAt
        self.lastFoundAt = lastFoundAt
    }
    
    func update(beacon:CLBeacon){
        if (beacon.compositeId() == beaconId){
            beaconRssi = beacon.rssi
            beaconProximity = beacon.proximity
            lastFoundAt = NSDate().timeIntervalSince1970
        }
    }
    
    override var description : String{
        return "Beacon:\(beaconId),rssi:\(beaconRssi),duration:\(durationInRangeOf()),foundAt:\(foundAt),lastFoundAt:\(lastFoundAt)"
    }
    
    func isEqualToImprint(imprint: TEALImprint?)->Bool{
        if beaconId == imprint?.beaconId{
            return true
        }
        return false
    }
    
    func lastFoundAtPassedThreshold(timeout:NSTimeInterval)->Bool{
        let now = NSDate().timeIntervalSince1970
        if now > lastFoundAt{
            let elapsed = now - lastFoundAt
            if elapsed > timeout{
                return true
            }
        }
        return false
    }
    
    func passThreshold(timeout: NSTimeInterval)->Bool{
        if durationInRangeOf() > timeout{
            return true
        }
        return false
    }
    
    func durationInRangeOf()->NSTimeInterval{
        if lastFoundAt > foundAt{
            return lastFoundAt - foundAt
        }
        return 0
    }
  
    class func serialize(imprint: TEALImprint)-> NSDictionary{
        
        var dict = [String:AnyObject]()
        
        dict.updateValue(imprint.beaconId, forKey: "bi")
        dict.updateValue(imprint.beaconRssi, forKey: "br")
        dict.updateValue(imprint.beaconProximity.rawValue, forKey: "bp")
        dict.updateValue(imprint.foundAt, forKey:"bfa")
        dict.updateValue(imprint.lastFoundAt, forKey: "blfa")
        
        return dict
    }
    
    class func deserialize(serializedImprint:NSDictionary)->TEALImprint?{
        
        if let id = serializedImprint["bi"] as? String{
            if let rssi = serializedImprint["br"] as? Int{
                if let proximityRaw = serializedImprint["bp"] as? Int{
                    let proximity = CLProximity(rawValue: proximityRaw)
                    if let foundAt = serializedImprint["bfa"] as? NSTimeInterval{
                        if let lastFoundAt = serializedImprint["blfa"] as? NSTimeInterval{
                            let imprint = TEALImprint(beaconId: id, rssi: rssi, proximity: proximity!, foundAt: foundAt, lastFoundAt: lastFoundAt)
                            return imprint
                        }
                    }
                }
            }
        }
        TEALLog.log("Problem deserializing imprinte:\(serializedImprint)")
        return nil
    }

}
