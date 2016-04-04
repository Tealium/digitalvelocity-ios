//
//  CellData.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 3/24/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

protocol CellDataFavoriteDelegate{
    func cellDataFavoriteToggled(originObject: AnyObject?)
}

private let timeFormatter = NSDateFormatter()

class CellData : NSObject {

    var categoryId: String?
    var createdAt : NSDate = NSDate()
    var data :[ String : AnyObject ]?    // Generic data container
    var endDate: NSDate?
    var fontAwesomeValue: String?
    var imageData: NSData = DefaultTransparentImageData
    dynamic var imageDataReady : Bool = false
    var indexPath: NSIndexPath?
    var locationId: String?
    var objectId: String?
    var roomName: String?
    var start: Int?
    var startDate: NSDate?
    var subtitle: String?
    var targetDescription: String?  // Don't want to override default object description
    var timeRange: String?
    var title: String?
    var url: NSURL?
    var areObserveringForImageDataReady : Bool = false
    
    var delegate : CellDataFavoriteDelegate?
    
    weak var imageDataReadyObserver : NSObject?
    
    let favorites = EventDataStore.sharedInstance().favorites
    
    
    func cellTrackingData(additionalData : [ String : AnyObject]?) -> [ String : AnyObject] {
        
        var data = [ String : AnyObject]()
        
        if let roomName = roomName {
            data["agenda_roomname"] = roomName
        }
        
        if let subtitle = subtitle {
            data["agenda_subtitle"] = subtitle
        }
        
        if let title = title {
            data["agenda_title"] = title
        }
        
        if let objectId = objectId {
            data["agenda_objectid"] = objectId
        }
        
        if let additionalData = additionalData {
            data.addEntriesFrom(additionalData)
        }
        
        return data
    
    }
    
    override var description : String{
        return "CellData: title:\(title) subtitle:\(subtitle) description:\(targetDescription) url:\(url) locationId:\(locationId) indexPath:\(indexPath) fontAwesomeValue:\(fontAwesomeValue) localFavorite:\(isLocalFavorite) createdAt:\(createdAt)"
    }
    
    deinit {
        removeImageDataReadyObserver()
    }
    
    func removeImageDataReadyObserver() {
        if areObserveringForImageDataReady{
            if let observer = imageDataReadyObserver{
                self.removeObserver(observer, forKeyPath: "imageDataReady")
                areObserveringForImageDataReady = false
            }
        }
    }
    
    func observeForImageDataReady(observer: NSObject, context: UnsafeMutablePointer<Void>){
        
        if areObserveringForImageDataReady == false{
            self.addObserver(observer, forKeyPath: "imageDataReady", options: NSKeyValueObservingOptions.New, context: context)
            imageDataReadyObserver = observer
            areObserveringForImageDataReady = true
        }
    }
    
    func locationInfoString() -> String {
        
        var info = timeRangeString()
        
        if let room = self.roomName {
            info += " | \(room)"
        }
        return info
    }
    
    func timeRangeString()->String{
        if startDate != nil && endDate != nil{
            timeFormatter.dateStyle = NSDateFormatterStyle.NoStyle
            timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            timeFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
            let start = timeFormatter.stringFromDate(startDate!)
            let end = timeFormatter.stringFromDate(endDate!)
            return "\(start) - \(end)"
        }
        
        // Legacy fallback
        if let tr = timeRange{
            return tr
        }
        
        return ""
    }
    
    func timeReceivedString()->String{
        // Mainly for notifications
        if startDate != nil{
            timeFormatter.dateStyle = NSDateFormatterStyle.NoStyle
            timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            timeFormatter.timeZone = NSTimeZone.localTimeZone()
            
            let time = timeFormatter.stringFromDate(startDate!)
            
            // Not efficient but supports 12 & 24 hour time
            let dayFormatter = NSDateFormatter()
            dayFormatter.dateFormat = "EEEE"
            let day = dayFormatter.stringFromDate(startDate!)
            
            return "\(day) - \(time)"
        }
        return ""
    }
    
    func toggleFavorite(originObject: AnyObject?){
        if isLocalFavorite(){
            TEALLog.log("Favorites: \(favorites)")
            favorites.removeFavoriteObject(objectId)
            let data = self.cellTrackingData(["agenda_favorite" : "false"])
            Analytics.track("agenda_favorite_toggled", isView: false, data: data)
            delegate?.cellDataFavoriteToggled(originObject)
        } else {
            favorites.addFavoriteObject(objectId)
            let data = self.cellTrackingData(["favorite" : "true"])
            Analytics.track("agenda_favorite_toggled", isView: false, data: data)
            delegate?.cellDataFavoriteToggled(originObject)
        }
    }
    
    func isLocalFavorite()->Bool{
        if let oid = self.objectId{
            return favorites.isAFavorite(oid)
        }
        return false
    }
    
}
