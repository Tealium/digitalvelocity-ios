//
//  User.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/13/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import Foundation


private let _sharedInstance = User()

/**
    Singleton representing the current app user
*/
class User: NSObject {

    class var sharedInstance: User{
        return _sharedInstance
    }
    
    var email: String?{
        didSet{
            // lowercasing here seems to not work
            save(email?.lowercaseString, key:userEmailKey)
        }
    }
    var traceId: String?{
        didSet{
            save(traceId, key:userTraceId)
        }
    }
    
    var skipCount : Int = 0{
        didSet{
            save(String(skipCount), key:skipCountKey)
        }
    }
    
    var optInTracking : Bool = true{
        didSet{
            save(optInTracking.toString(), key:optInTrackingKey)
        }
    }
    
    let userEmailKey = "DV2015_RE"
    let userTraceId = "DV2015_TI"
    let skipCountKey = "DV2015_SC"
    let optInTrackingKey = "DV2015_OIT"
    
    
    override init() {
        super.init()
        load()
    }
    
    func isLoggedIn()->Bool{
        if let e = self.email{
            if isValidEmail(e){
                return true
            }
        }
        return false
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)        
    }
    
    func isPresenter() -> Bool {
        if email == "digitalvelocity@tealium.com"{
            return true
        }
    
        if email == "presenter@tealium.com"{
            return true
        }
        return false
    }
    
    private func save(value:String?, key:String){
        if value != nil{
            let defaults = NSUserDefaults.standardUserDefaults()
            let savedValue: String? = defaults.objectForKey(key) as? String
            if savedValue != value{
                defaults.setObject(value, forKey: key)
                defaults.synchronize()
            }
            
        }
    }
    
    private func load(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedEmail = defaults.objectForKey(userEmailKey) as? String{
            self.email = savedEmail
        }
        if let savedTraceId = defaults.objectForKey(userTraceId) as? String{
            self.traceId = savedTraceId
        }
        if let savedSkipCount = defaults.objectForKey(skipCountKey) as? String {
            if let ssc = Int(savedSkipCount){
                self.skipCount = ssc
            }
        }
        if let savedOptInTracking = defaults.objectForKey(optInTrackingKey) as? String{
            if let opt = savedOptInTracking.toBool(){
                self.optInTracking = opt
            }
        }
    }
}