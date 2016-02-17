//
//  NotificationsDataSource.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 5/18/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

protocol NotificationsDelegate{
    func notificationWasRecieved()
}

private let _keyNotificationsArray = "com.tealium.digitalvelocity.notifications"

class Notifications {
    
    private var notifications : [Notification] = [Notification]()
    var delegate : NotificationsDelegate?
    
    init(){
        self.load()
    }
    
    func load(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedFavorites = defaults.objectForKey(_keyNotificationsArray) as? NSArray{
            
            for notificationObject in savedFavorites{
                let notificationData: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(notificationObject as! NSData)
                if let notification = notificationData as? Notification{
                    notifications.append(notification)
                }
            }
            TEALLog.log("Successfully loaded notifications: \(notifications)")
        } else {
            TEALLog.log("No previous notifications found.")
        }
    }
    
    func all()->[Notification]{
        return self.notifications
    }
    
    func save(){
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let nArray = NSMutableArray(capacity: notifications.count)
        for notification in notifications{
            
            let data = NSKeyedArchiver.archivedDataWithRootObject(notification)
            nArray.addObject(data)
        }
        defaults.setObject(nArray, forKey: _keyNotificationsArray)
        defaults.synchronize()
    }
    
    func addNotification(message: String?){
        if let m = message{
            let newNotification = Notification(message: m)
            if isDuplicateNotification(newNotification) == false{
                TEALLog.log("Notifiction added: \(newNotification.description)")
                self.notifications.append(newNotification)
                delegate?.notificationWasRecieved()
                self.save()
            }
        }
    }
    
    func isDuplicateNotification(notification:Notification)->Bool{
        
        for receivedNotification in self.notifications{
            if receivedNotification.isEqualTo(notification){
                return true
            }
        }
        return false
    }
}

class Notification : NSObject, NSCoding{
    var timestamp : NSDate!
    var message : NSString!
    override var description : String{
        return "Notification message: \(self.message), recieved: \(self.timestamp)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init()
        
        timestamp = aDecoder.decodeObjectForKey("timestamp") as! NSDate
        message = aDecoder.decodeObjectForKey("message") as! NSString
        
    }
    
    init(message: String){
        self.message = message
        self.timestamp = NSDate()
        super.init()
    }
    
    func isEqualTo(notification: Notification)->Bool{
        if notification.message == self.message{
            let unix = notification.timestamp.timeIntervalSince1970
            let unixE = unix - 1
            let unixA = unix + 1
            let unixS = self.timestamp.timeIntervalSince1970
            
            // 1 second spread in either direction
            if unixS >= unixE && unixS <= unixA{
                return true
            }
        }
        return false
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(timestamp, forKey:"timestamp")
        aCoder.encodeObject(message, forKey:"message")
    }

}