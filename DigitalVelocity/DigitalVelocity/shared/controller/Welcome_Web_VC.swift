//
//  Welcome_Web_VC.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 5/28/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class Welcome_Web_VC : Web_VC{
    
    // MARK: Setup
    func defaultPage()->NSURL{
        
        var baseURLString = "http://dv15eu.s3-website-eu-west-1.amazonaws.com/index"
        
        if let userEmail = User.sharedInstance.email {
            baseURLString += "?uid=\(userEmail)"
        }
        
        let encodedURLString = baseURLString.stringByRemovingPercentEncoding
        
//        let encodedURLString = baseURLString.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        let url = NSURL(string: encodedURLString!)
        
        return url!
    }
    
    override func viewDidLoad() {
        
        if let email =  User.sharedInstance.email {
            saveEmailCookie(email)
          //  saveVisitorIDCookie()
        }else{
            //saveVisitorIDCookie()
        }
        
        if progress.finishedLoading == false {
            if let u = url {
                loadWebView(u)
            } else {
                self.setupMenuNavigationForController()
                loadWebView(self.defaultPage())
            }
        }
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if let tealium = Tealium.instanceForKey(tealiumBGInstanceID){
            saveVisitorIDCookie()
        }else {
            print("Tealium instance does not exist")
        }
    }
    
    func saveEmailCookie(email: String){
        let cookieProperties =  [
            NSHTTPCookieDomain: "digitalvelocity.tealium.com",
            NSHTTPCookiePath: "/",
            NSHTTPCookieName: "user_email",
            NSHTTPCookieValue: email,
            NSHTTPCookieSecure: "TRUE",
            ]
        
        let cookie = NSHTTPCookie(properties: cookieProperties)
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie!)

    }
}

    func saveVisitorIDCookie() {
        let tealium = Tealium.instanceForKey(tealiumBGInstanceID)
        print (tealium)
        let cookieProperties =  [
            NSHTTPCookieDomain: "digitalvelocity.tealium.com",
            NSHTTPCookiePath: "/",
            NSHTTPCookieName: "visitor_id",
            NSHTTPCookieValue: tealium?.visitorIDCopy() as! AnyObject ,
            NSHTTPCookieSecure: "TRUE",
            ]
        
        let cookie = NSHTTPCookie(properties: cookieProperties)
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie!)
        
    }

