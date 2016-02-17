//
//  TEALCredentials.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/17/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import Foundation

let TEALCredentialsLoggingIsEnabled = false
let TEALCredentialsErrorLoggingIsEnabled = true

let TealiumAccount = "tealium_account"
let TealiumProfile = "tealium_profile"
let TealiumEnv = "tealium_env"
let ParseAppId = "parse_app_id"
let ParseClientId = "parse_client_id"
let DonkyApiId = "donky_api_id"

class TEALCredentials {
    
    
    class func log(string: String) {
        if TEALCredentialsLoggingIsEnabled == false {
            return
        }
        print(string)
    }
    
    class func logError(string: String) {
        if TEALCredentialsErrorLoggingIsEnabled == false {
            return
        }
        print(string)
    }
    
    class func idFor(key:String) -> String {
        
        let credentials = self.credentials()
        
        guard let account = credentials[key] else {
            self.logError("No credential value for key: \(key)")
            return ""
        }
                
        return account
        
    }
    
    private class func credentials() -> [String: String] {
    
        var credentials = [String:String]()
        guard let path = NSBundle.mainBundle().pathForResource("credentials", ofType: "json") else {
            
            self.logError("No credentials.json file found in project bundle.")
            
            return credentials
        }
        
        let fileManager = NSFileManager.defaultManager()

        if fileManager.fileExistsAtPath(path) == false{
            
            self.logError("Credentials.json file not found in project bundle.")

            return credentials
        }
        
        guard let data = fileManager.contentsAtPath(path) else {
            
            self.logError("No data found in credentials.json at path: \(path).")

            return credentials
        }
        
        
        do {
            let JSON = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments)
            guard let JSONDictionary = JSON as? [String: String] else {
                self.logError("Credentials.json did not parse into a Dictionary")
                // put in function
                return credentials
            }
            credentials = JSONDictionary
            self.log("Credentials processed: \(credentials)")
        }
        catch let JSONError as NSError {
            self.logError("Credentials.json parsing error: \(JSONError)")
        }
        
        return credentials
        
    }

    
}