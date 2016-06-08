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
                
        let url = NSURL(string: encodedURLString!)
        
        return url!
    }
    
    override func viewDidLoad() {
                
        if let email =  User.sharedInstance.email {
            saveEmailCookie(email)
            saveVisitorIDCookie()
        }else{
            saveVisitorIDCookie()
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
        saveVisitorIDCookie()
    }
    
    func saveEmailCookie(email: String){
        let cookieProperties =  [
            NSHTTPCookiePath: "/",
            NSHTTPCookieDomain: "digitalvelocity.tealium.com",
            NSHTTPCookieName: "user_email",
            NSHTTPCookieValue: email,
            NSHTTPCookieSecure: "TRUE",
            ]
        
        let cookie = NSHTTPCookie(properties: cookieProperties)
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie!)

    }

    func saveVisitorIDCookie() {
        
        guard let visitorId = Tealium.instanceForKey(tealiumBGInstanceID)?.visitorIDCopy() else{
            // visitor id not available.
            return
        }
        
        let cookieProperties =  [
            NSHTTPCookiePath: "/",
            NSHTTPCookieDomain: "digitalvelocity.tealium.com",
            NSHTTPCookieName: "visitor_id",
            NSHTTPCookieValue: visitorId ,
            NSHTTPCookieSecure: "TRUE",
            ]
        
        let cookie = NSHTTPCookie(properties: cookieProperties)
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie!)
        
    }
    
    override func webViewDidFinishLoad(webView: UIWebView) {
        
        showErrorMessage(false)
        
        let cookieJar : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in cookieJar.cookies! as [NSHTTPCookie]{
            
            if (cookie.name == "page_title") {
                self.title = cookie.value
                print("Cookie: \(cookie)")
            }
        }
        
        if webView.canGoBack {
            btn.hidden = false
        }else {
            btn.hidden = true
        }
        progress.finishedLoading = true
        
    }

}

