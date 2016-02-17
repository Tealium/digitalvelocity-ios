//
//  FavoritesDataSource.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 5/13/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import Foundation

let keyFavoritesArray = "com.tealium.digitalvelocity.favorites"

class Favorites {
    var favorites : NSMutableSet = NSMutableSet()
    
    init(){
        self.load()
    }
    
    func load(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedFavorites = defaults.objectForKey(keyFavoritesArray) as? NSArray{
            favorites.addObjectsFromArray(savedFavorites as [AnyObject])
        }
        
        if favorites.count > 0 {
            TEALLog.log("Favorites loaded")
        }
    }
    
    func save(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let saveArray = favorites.allObjects
        defaults.setObject(saveArray, forKey: keyFavoritesArray)
        defaults.synchronize()
    }
    
    func addFavoriteObject(objectId: String?){
        if let oid = objectId {
            favorites.addObject(oid)
            save()
        }
    }
    
    func removeFavoriteObject(objectId: String?){
        if let oid = objectId{
            favorites.removeObject(oid)
            save()
        }
    }
    
    func isAFavorite(objectId:String?)->Bool{
        if let oid = objectId{
            if self.favorites.containsObject(oid){
                return true
            }
        }
        return false
    }
}