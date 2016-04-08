//
//  ParseHandler.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/13/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import Foundation


let PARSE_CLASS_KEY_ATTENDEE = "Attendee"
let PARSE_CLASS_KEY_CATEGORY = "Category"
let PARSE_CLASS_KEY_COMPANY = "Company"
let PARSE_CLASS_KEY_CONFIG = "Config"
let PARSE_CLASS_KEY_EVENT = "Event"
let PARSE_CLASS_KEY_LOCATION = "Location"
let PARSE_CLASS_KEY_NOTIFICATION = "Notification"
let PARSE_CLASS_KEY_QUESTION = "Question"
let PARSE_CLASS_KEY_SURVEY = "Survey"

private let _sharedInstance = ParseHandler()

class ParseHandler: NSObject {
    
    var parseObjects = [ String : AnyObject ]()
    
    var areRegisteredForPush = false
    var categories: [Category] = [Category]()
    var config : Config = Config()
    var isLoaded : Bool = false //TODO: Remove when proper reachability connected
    var userParseChannel: String = ""
    
    let keyAddress = "address"
    let keyAnswers = "answers"
    let keyCategoryId = "categoryId"
    let keyCreatedAt = "createdAt"
    let keyDescription = "description"
    let keyEmail = "email"
    let keyEmailMessage = "emailMessage"
    let keyEnd = "end"
    let keyEndDate = "endDate"
    let keyEveryone = "everyone"
    let keyEventDate = "eventDate"
    let keyImageData = "imageData"
    let keyImageFontAwesome = "imageFontAwesome"
    let keyLastUpdatedDict = "com.tealium.digitalvelocity.lastupdatedat"
    let keyLatitude = "latitude"
    let keyLocationId = "locationId"
    let keyLongitude = "longitude"
    let keyObjectId = "objectId"
    let keyPriority = "priority"
    let keyQuestionIds = "questionIds"
    let keyRoomName = "roomName"
    let keyStart = "start"
    let keyStartDate = "startDate"
    let keySubtitle = "subTitle"
    let keyTitle = "title"
    let keyUpdatedAt = "updatedAt"
    let keyUrl = "url"
    let keyVisible = "visible"
    let classKeyUser = "User"
    let classKeyNotification = "Notification"   // local only
    let classKeyFavorites = "Favorites"         // local only
    
    let userLastUsedAppKey = "DV2015_LU"
    
    class var sharedInstance: ParseHandler{
        return _sharedInstance
    }
    
    // MARK: SETUP
    override init() {
        super.init()
        Parse.enableLocalDatastore()
        
        let appID = TEALCredentials.idFor(ParseAppId)
        
        let clientKey = TEALCredentials.idFor(ParseClientId)
        
        Parse.setApplicationId(appID, clientKey: clientKey)
    }
    
    // MARK: PUSH
    
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken:NSData, completion:(successful: Bool, error:NSError?)->()){
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock { (successful, error) -> Void in
            
            if successful == true{
                self.areRegisteredForPush = true
                TEALLog.log("Registered for push with token:\(deviceToken)")
                self.registerForChannel(self.keyEveryone)
            }
            
            completion(successful:successful, error:error)

        }
    }
    
    func registerForChannel(channel: String){
        
        let ci = PFInstallation.currentInstallation()
        if let savedChannels = ci.channels{
            for savedChannel in savedChannels{
                if savedChannel as? NSString == channel{
                    TEALLog.log("Already registered to Parse channel:\(channel).")
                    return
                }
            }
        }
        
        ci.addUniqueObject(channel, forKey: "channels")
        ci.saveInBackgroundWithBlock({ (successful, error) -> Void in
            if error != nil{
                TEALLog.log("Problem saving push registeration data to Parse:\(error?.localizedDescription)")
            }
            
            TEALLog.log("Did register for Parse channel: \(channel): \(successful)")
            
        })
        
        
    }
    
    private func alreadyRegisteredChannel(channel:String)->Bool{
        
        if let subscribedChannels = PFInstallation.currentInstallation().channels{
            for subscribedChannel in subscribedChannels{
                if let c = subscribedChannel as? NSString{
                    if c == channel{
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func unregisterChannel(channel: String){
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.removeObject(channel, forKey: "channels")
        currentInstallation.saveInBackgroundWithBlock { (successful, error) -> Void in
            if error != nil{
                TEALLog.log("Problem unregistering for channel:\(channel)")
            }
        }
    }
    
    // MARK: PUBLIC
    
    func launchOrWake(){
        loadConfig()
    }
    
    func sleep(){
        save(NSDate().timeIntervalSince1970, key: userLastUsedAppKey)
    }
    
    func allCategories()->[Category]{
        return self.categories
    }
    
    func allCellData(className:String, completion:(success:Bool, category: [Category]?, error: NSError?)->()){
        
        let pfObjects = self.pfObjectsForClass(className)
        
        let convertedCellData = ParseConverter.cellDatasForPFObjects(pfObjects)
        
        var category = [Category]()
        
        let cat = Category()
        
        cat.cellData = convertedCellData
        
        category.append(cat)
        
        if convertedCellData.count == 0 {
            completion(success:false, category: category, error: nil)
        } else {
            completion(success:true, category:category, error: nil)
        }
    }
    
    func categoriesWithCellData(className:String, ascending:Bool, completion:(success:Bool, sortedCategories: [Category]?, error:NSError?)->()){
        
        // Exception
        if className == PARSE_CLASS_KEY_QUESTION {
            self.allCellData(className, completion: completion)
            return
        }
        
        var sortedCatCellData : [Category] = [Category]()

        let pfObjects = self.pfObjectsForClass(className)
        
        sortedCatCellData = ParseConverter.convertToCategoriesWithCellDataFor(pfObjects, ascending:ascending, categories: allCategories())
        
        if sortedCatCellData.count == 0 {
            completion(success: false, sortedCategories:sortedCatCellData, error:nil)
        } else {
            completion(success: true, sortedCategories:sortedCatCellData, error: nil)
        }        
    }
    
    func trackLaunch(application:UIApplication?, launchOptions:[NSObject:AnyObject]?){
        if let a = application{
            PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: { (success, error) -> Void in
            })
            enablePush(a)
        }
    }
    
    func trackEvent(title:String, dimensions:[NSObject:AnyObject]?){
        if let d = dimensions{
            PFAnalytics.trackEventInBackground(title, dimensions: d, block: nil)
        } else {
            PFAnalytics.trackEventInBackground(title, block: nil)
        }
    }
    
    // MARK: INTERNAL
    
    func loadConfig(){
        
        self.config = Config.loadConfig()
        fetch(PARSE_CLASS_KEY_CONFIG, lastUpdatedAt: nil, completion: { (pfObjects, error) -> () in
            if error != nil{
            }
            
            self.updateConfig(pfObjects)
            self.loadAll()
        })
    }
    
    private func isDuplicateNotification(pfo:PFObject, pfoArray:[PFObject])->Bool{
        var response = false
        if pfoArray.count > 0{
            let lastPfo = pfoArray.first
            let lastPfoTitle = lastPfo?.objectForKey(ph.keyTitle) as? String
            let currentPfoTitle = pfo.objectForKey(ph.keyTitle) as? String
            if currentPfoTitle == lastPfoTitle{
                response = true
            }
        }
        
        return response
    }
    
    // MARK: PRE FETCHING
    
    func fetchNewWithCompletion(className:String, completion:(success: Bool, error:NSError?)->())-> Void{
        
        self.fetch(className, lastUpdatedAt: nil) { (pfObjects, error) -> () in
            
            // Fetch error
            if error != nil{
                completion(success:false, error: error)
                return
            }
            
            // Remove old data from parse local
            PFObject.unpinAllInBackground(pfObjects, block: { (success, unPinError) -> Void in
                
                // Don't care if there's an error in unpinning
                
                // Update Parse local
                PFObject.pinAllInBackground(pfObjects, block: { (success, pinError) -> Void in
                    
                    // Don't care if there's an issue repinning
                    
                })
                
                self.update(className, pfObjects: pfObjects)
                completion(success:true, error: nil)
            })
            
        }
    }
    
    private func fetchNew(className:String, lastUpdatedAt:NSDate?){
        
        self.fetch(className, lastUpdatedAt: nil) { (pfObjects, error) -> () in
            if error != nil{
                TEALLog.log("Error retrieving \(className) from server:\(error?.localizedDescription)")
                return
            }
            PFObject.unpinAllInBackground(pfObjects, block: { (success, unPinError) -> Void in
                if unPinError != nil{
                    TEALLog.log("\(className) encountered unpinning error:\(unPinError?.localizedDescription)")
                }
                
                PFObject.pinAllInBackground(pfObjects, block: { (success, pinError) -> Void in
                    if pinError != nil{
                        TEALLog.log("\(className) encountered pinning error:\(pinError?.localizedDescription)")
                        return
                    }
                })
                self.update(className, pfObjects: pfObjects)
            })

        }
        
    }
    
    // Returns pfObject converted into a dictionary object
    func fetchSpecificRecord(className:String, key: String, value:String, completion:(dictionary:[NSObject:AnyObject], error:NSError?)->())->Void{
        
        let query = PFQuery(className:className)
        
        query.whereKey(keyVisible, equalTo: true)

        query.whereKey(key, equalTo:value)
        
        query.findObjectsInBackgroundWithBlock { (pfObjects, error) -> Void in
        
            var returnDictionary = [NSObject:AnyObject]()
            
            if let pfObjects = pfObjects {
                
                guard let pfObject = pfObjects[0] as? PFObject else {
                    // No object found
                    
                    let error = NSError.init(domain: "com.tealium", code: 400, userInfo:[ NSLocalizedDescriptionKey:"No PFObjects found for \(className):\(key):\(value)"])
                    
                    completion(dictionary:returnDictionary, error:error)
                    
                    return
                }
                
                let dictionaryObject = ParseConverter.dictionaryFromPFObject(pfObject)
                
                returnDictionary.addEntriesFrom(dictionaryObject)
                
            }
            
            completion(dictionary:returnDictionary, error:error)
        
        }
        
    }
    
    
    private func fetch(className:String, lastUpdatedAt:NSDate?, completion:(pfObjects:[PFObject], error:NSError?)->())-> Void{
        
        let query: PFQuery = PFQuery(className: className)
        
        if let lua = lastUpdatedAt{
            query.whereKey(keyUpdatedAt, greaterThan: lua)
        }
        
        query.whereKey(keyVisible, equalTo: true)
        
        query.findObjectsInBackgroundWithBlock { (pfObjects, error) -> Void in
            
            completion(pfObjects: self.verifiedPFObjectsArray(pfObjects), error: error)
            
        }
    }
    
    func pfObjectsForClass(className: String) -> [PFObject]{
    
        if let objects = self.parseObjects[className] as? [PFObject]{
            
            return objects
            
        }
        
        return [PFObject]()
    
    }
    
    private func update(className:String, pfObjects:[PFObject]){
        
        // Exception classes
        if className == PARSE_CLASS_KEY_CONFIG{
            self.updateConfig(pfObjects)
            return
        }
        
        if className == PARSE_CLASS_KEY_CATEGORY {
            self.updateCategories(pfObjects)
            return
        }
        
        // All other classes
        if pfObjects.count == 0 {
            TEALLog.log("No PFObjects provided to call for class: \(className)")
            return
        }
        
        self.parseObjects[className] = pfObjects
        
        self.saveLastUpdatedAtForClass(className, date: NSDate())
        
        TEALLog.log("Updated Parse objects for class: \(className): \(pfObjects)")

    }
    
    private func updateCategories(objects:[PFObject]){
        if objects.count == 0 {
            TEALLog.log("No PFObjects provided to call")
            return
        }
        
        self.categories = ParseConverter.categoriesFromPFObjects(objects)
        self.saveLastUpdatedAtForClass(PARSE_CLASS_KEY_CATEGORY, date: NSDate())
    }

    private func updateConfig(objects:[PFObject]){
        if objects.count == 0 {
            TEALLog.log("No PFObjects provided to updateConfig call")
            return
        }
        
        let newConfig = ParseConverter.configFromPFObject(objects[0])
        if self.config.isEqualToConfig(newConfig) == false{
            self.config = newConfig
            NSNotificationCenter.defaultCenter().postNotificationName(notificationKeyConfigData, object: self.config)
        }
        
        if (self.config.shouldPurge == true){
            purgeAll()
        } else {
            self.load(PARSE_CLASS_KEY_CATEGORY)
        }
    }
    
    private func load(className:String){

        queryClassDataStoreForExistingKeys(className, keys: []) { (pfObjects, error) -> () in
            if error != nil{
                TEALLog.log("Retrieval issue:\(error?.localizedDescription)")
                self.fetchNew(className, lastUpdatedAt: nil)
                return
            }
            
            if pfObjects.count == 0{
                TEALLog.log("Local data store empty for \(className), checking remote...")
                self.fetchNew(className, lastUpdatedAt: nil)
                return
            }
            
            if pfObjects.count > 0{
                
                // Check for any updates
                if let lua = self.lastUpdatedAtForClass(className){
                    self.fetchNew(className, lastUpdatedAt: lua)
                } else {
                    self.update(className, pfObjects: pfObjects)
                }
            }
        }
    }
    
    private func loadLocalOnly(className:String){
        queryClassDataStoreForExistingKeys(className, keys: []) { (pfObjects, error) -> () in
            if error != nil{
                TEALLog.log("Local only Retrieval issue:\(error?.localizedDescription)")
                return
            }
            if pfObjects.count > 0{
                self.update(className, pfObjects:pfObjects)
            }
        }
    }
    
    private func loadAll(){
        load(PARSE_CLASS_KEY_EVENT)
        load(PARSE_CLASS_KEY_COMPANY)
        load(PARSE_CLASS_KEY_LOCATION)
        load(PARSE_CLASS_KEY_QUESTION)
        load(PARSE_CLASS_KEY_SURVEY)
        isLoaded = true
    }
    
    // TODO: Need to fix and add back to update methods
    func updatePFObjectArray(array:[PFObject], updates:[PFObject])->[PFObject]{
        var mArray = array
        let pfObjects = array
        for update in updates{
            for (index,pfObject) in pfObjects.enumerate(){
                if update.objectId == pfObject.objectId{
                    mArray.removeAtIndex(index)
                    if index < pfObjects.count{
                        mArray.insert(update, atIndex: index)
                    } else {
                        mArray.append(update)
                    }
                }
            }
        }
        return mArray
    }
    
    private func enablePush(application:UIApplication){
        if areRegisteredForPush == false{
            if iOS8{
                let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]);
                
                let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            } else {

                let settings = UIUserNotificationSettings(forTypes: [.Badge], categories: nil)
                
                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                UIApplication.sharedApplication().registerForRemoteNotifications()
                
                // Swift 1.0
                //             UIApplication.sharedApplication().registerForRemoteNotificationTypes([UIRemoteNotificationType.Badge, UIRemoteNotificationType.Sound, UIRemoteNotificationType.Alert])

            }
        }
    }
    
    // TODO: Hook back up
    func isSyncRateExceeded()->Bool{
        if let la = lastAwake(){
            let elapsed = NSDate().timeIntervalSince1970 - la
            TEALLog.log("Current time since last wake:\(elapsed)")
            if elapsed < config.syncRate{
                return false
            }
        }
        return true
    }
    
    func shouldRefresh(className:String, compareDate:NSDate)->Bool{
        // Does the local date store for the class have anything newer than the compare date?
        
        let query = PFQuery(className: className)
        query.fromLocalDatastore()
        query.whereKey(keyUpdatedAt, greaterThan: compareDate)
        if let foundRecords = query.findObjects(){
            return foundRecords.isEmpty
        }
        return true
    }
    
    func purgeAll(){
        
        PFObject.unpinAllObjectsInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                TEALLog.log("Unpin error:\(error?.localizedDescription)")
            }
            self.load(PARSE_CLASS_KEY_CATEGORY)
        }
    }

    // MARK: PARSE COMMANDS
    
    private func queryClassDataStoreForExistingKeys(className:String, keys:Array<String>, completion:(pfObjects:[PFObject], error: NSError?)->())->Void{
        
        let query: PFQuery = PFQuery(className: className)
        query.fromLocalDatastore()
        for key in keys{
            query.whereKeyExists(key as String)
        }
        query.whereKey(keyVisible, equalTo: true)
            
        query.findObjectsInBackgroundWithBlock { (objs, error) -> Void in
            
            if error != nil{
                TEALLog.log("Data store Query failed for \(className): \(error?.localizedDescription)")
            }
            
            completion(pfObjects: self.verifiedPFObjectsArray(objs), error: error)
        }
    }
    
    private func verifiedPFObjectsArray(pfObjects:[AnyObject]!)->[PFObject]{
        // Returns empty array if failed
        if let pfos = pfObjects{
            var verifiedPfos : [PFObject] = [PFObject]()
            
            for pfo in pfos{
                if let verifiedPfo = pfo as? PFObject{
                    verifiedPfos.append(verifiedPfo)
                }
            }
            return verifiedPfos
        }
        return [PFObject]()
    }
    
    // MARK: PERSISTENCE
    
    private func saveLastUpdatedAtForClass(className:String, date: NSDate){
        
        // Adding to the lastUpdateAt dict
        let defaults = NSUserDefaults.standardUserDefaults()
        let lastUpdatedAtDict : NSMutableDictionary = NSMutableDictionary()
        
        // Using saved dict
        if let last = defaults.objectForKey(keyLastUpdatedDict) as? NSDictionary{
            lastUpdatedAtDict.addEntriesFromDictionary(last as [NSObject : AnyObject])
        }
        
        lastUpdatedAtDict.setValue(date, forKey: className)
        
        defaults.setObject(lastUpdatedAtDict, forKey: keyLastUpdatedDict)
        defaults.synchronize()
    }
    
    private func lastUpdatedAtForClass(className:String) -> NSDate?{
        let defaults = NSUserDefaults.standardUserDefaults()
        if let lastUpdatedAtDict = defaults.objectForKey(keyLastUpdatedDict) as? NSDictionary{
 
            if let date = lastUpdatedAtDict.objectForKey(className) as? NSDate{
                return date
            }
        }
        return nil
    }

    private func save(value:AnyObject?, key:String){
        if value != nil{
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(value, forKey: key)
            defaults.synchronize()
        }
    }
    
    private func lastAwake()->NSTimeInterval?{
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedLastUsed = defaults.objectForKey(userLastUsedAppKey) as? NSTimeInterval{
            return savedLastUsed
        }
        return nil
    }
        
}
