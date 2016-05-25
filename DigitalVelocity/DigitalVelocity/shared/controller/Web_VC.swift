//
//  DVWebViewController.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/12/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class Web_VC: UIViewController {

    @IBOutlet weak var progress: TEALProgressView!
    @IBOutlet weak var webView: UIWebView!
    
    var url: NSURL?
    let btn = UIButton()
    
    // MARK: Setup
    
    override func viewDidLoad() {
        
        if progress.finishedLoading == false {
            print(" in Web VC")
            if let u = url {
                loadWebView(u)
            }
        }
    }
    
    func loadWebView(url:NSURL) {
        TEALLog.log("Loading:\(url)")
        let urlRequest = NSURLRequest(URL: url)
        webView.loadRequest(urlRequest)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        btn.frame = CGRectMake(-20, 0, 30, 30)
        btn.titleLabel?.font = FontAwesomeHelper.fontAwesomeForSize(30)
        btn.setTitle(FontAwesomeHelper.labelStringFromFontAwesome(unicode: "f104"), forState: UIControlState.Normal)
        btn.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0)
        btn.addTarget(self, action: #selector(Center_VC.back(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let left = UIBarButtonItem(customView: btn)
        self.navigationItem.leftBarButtonItem = left
        btn.hidden = true
        
        Analytics.trackView(self)
        
     }
    
    func back(sender: UIBarButtonItem) {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }

    // TODO: Replace with NSURLSession -> download content with actual progress-> load into webview when done
}



// MARK: WebView Delegate

extension Web_VC: UIWebViewDelegate {
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        TEALLog.logError(error)
        
        progress.finishedLoading = true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        progress.startProgress()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
  
        let cookie = NSHTTPCookie()
        let cookieJar : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in cookieJar.cookies! as [NSHTTPCookie]{
            if (cookie.name == "page_title") {
                self.title = cookie.value
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