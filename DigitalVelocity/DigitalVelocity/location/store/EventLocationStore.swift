//
//  EventLocationStore.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/20/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

import Foundation

enum EventLocationType: Int {
    case Maps = 0
    case Layouts
}

private let _sharedInstance = EventLocationStore()

class EventLocationStore {

    var layouts:Array<LocationDataLayout> = []
    var maps:Array<LocationDataMap> = []
    
    var layoutData:Dictionary<String, NSData> = Dictionary()
    
    var loaded:Bool = false
    
    init() {

    }

    class func sharedInstance() -> EventLocationStore {
        return _sharedInstance
    }
    
    func numberOfItemsForLocationType(type:EventLocationType) -> Int {
        
        if type == EventLocationType.Maps {
            return maps.count
        } else {
            return layouts.count
        }
    }
    
    func arrayOfTitlesForLocationType(type:EventLocationType) -> Array<String> {
        
        var titles:Array<String> = []
        
        if type == EventLocationType.Maps {
            
            for xi:LocationDataMap in maps {
                titles.append(xi.title)
            }
        } else {
            for xi:LocationDataLayout in layouts {
                titles.append(xi.title)
            }
        }
        return titles
    }
    
    func layoutForIndex(idx:Int) -> LocationDataLayout? {
        
        if idx < layouts.count && idx >= 0 {
            return layouts[idx]
        }
        return nil
    }
    
    func mapForIndex(idx:Int) -> LocationDataMap? {
        
        if idx < maps.count && idx >= 0 {
            return maps[idx]
        }
        return nil
    }
    
    func viewTypeAndLocationIndexForLocationID(locationID:String) -> (viewType:EventLocationType, locationIndex:Int) {
        var viewType = EventLocationType.Maps
        var locationIndex = -1
        
        for xi in (0..<layouts.count) {
            if let layout = layoutForIndex(xi) {
                if layout.locationID == locationID {
                    viewType = EventLocationType.Layouts
                    locationIndex = xi
                    return (viewType, locationIndex)
                }
            }
        }
        
        for xi in (0..<maps.count) {
            if let map = mapForIndex(xi) {
                if map.locationID == locationID {
                    viewType = EventLocationType.Maps
                    locationIndex = xi
                    return (viewType, locationIndex)
                }
            }
        }
        
        return (viewType, locationIndex)
    }
    
    // MARK: Networking
    
    func loadRemoteData(completion:(() -> Void)?) {
        
        let parse = ParseHandler.sharedInstance

        if (loaded) {
            if let comp = completion {
                comp()
            }
            return
        }
        
        layouts.removeAll(keepCapacity: false)
        maps.removeAll(keepCapacity: false)
        
//        parse.queryClassForExistingKeys(parse.classKeyLocation, keys: []) { (pfObjects, error) -> () in
        let pfObjects = ph.pfoLocations
            for obj:PFObject in pfObjects as Array<PFObject> {

                if obj[parse.keyLatitude] != nil { // is Map
                    
                    if let map = self.mapFromParseObject(obj) {
                        self.maps.append(map)
                    }
                } else {

                    if let layout = self.layoutFromParseObject(obj) {
                        self.layouts.append(layout)
                    }
                }

            }
            
            self.loaded = (self.maps.count > 0 || self.layouts.count > 0)
            
            if let comp = completion {
                comp()
            }
//        }
    }
    
    func layoutFromParseObject(obj:PFObject) -> LocationDataLayout? {
        
        let parse = ParseHandler.sharedInstance
        
        let locationID = obj.objectId

        var title = ""
        
        if let t = obj[parse.keyTitle] as? String {
            title = t
        }

        if let imageFile = obj[ph.keyImageData] as? PFFile {
            
            imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
                    self.layoutData[locationID!] = data
                } else {
                    TEALLog.log("Problem fetching imageData for object: \(locationID)")
                }
            })
        }
        
        return LocationDataLayout(locationID: locationID!, title: title)
        
    }

    func imageDataForLayout(layout:LocationDataLayout) -> NSData? {

        return self.layoutData[layout.locationID]
    }
    
    func mapFromParseObject(obj:PFObject) -> LocationDataMap? {
        
        let parse = ParseHandler.sharedInstance
        
        let locationID = obj.objectId
        
        var title = ""
        
        if let t = obj[parse.keyTitle] as? String {
            title = t
        }

        var subtitle = ""
        
        if let st = obj[parse.keySubtitle] as? String {
            subtitle = st
        } else if let ad = obj[parse.keyAddress] as? String {
            subtitle = ad
        }

        var latitude:Double = 0
        
        if let rawLatitude = obj[parse.keyLatitude] as? NSNumber {
            latitude = rawLatitude.doubleValue
        }
        
        var longitude:Double = 0
        
        if let rawLongitude = obj[parse.keyLongitude] as? NSNumber {
            longitude = rawLongitude.doubleValue
        }

        return LocationDataMap( locationID: locationID!,
                                title: title,
                                subtitle: subtitle,
                                latitude: latitude,
                                longitude: longitude)
    }
}
