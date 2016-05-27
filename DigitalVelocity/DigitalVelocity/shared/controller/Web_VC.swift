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
    
    
    var shouldShowErrorMessage : Bool = false
    var url: NSURL?
    let btn = UIButton()
    let errorLabel: UILabel = UILabel()

    
    // MARK: Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if progress.finishedLoading == false {
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
    
    func showErrorMessage(shouldShow: Bool)  {
        
        if (shouldShow == false) {
            errorLabel.hidden = true
            return
        }
        if errorLabel.text != nil && errorLabel.text !=  "" {
            errorLabel.hidden = false
            return
        }
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        
        errorLabel.frame = CGRectMake(20, screenHeight/3, screenWidth - 40, 40)
        errorLabel.textColor = UIColor.whiteColor()
        errorLabel.textAlignment = NSTextAlignment.Center
        errorLabel.text = "Please connect to the Internet"
        webView.opaque = false
        webView.backgroundColor = UIColor.blackColor()
        webView.addSubview(errorLabel)
        
        }
  
}



// MARK: WebView Delegate

extension Web_VC: UIWebViewDelegate {
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        self.showErrorMessage(true)
        TEALLog.logError(error)
        
        progress.finishedLoading = true
        
        }
    
    func webViewDidStartLoad(webView: UIWebView) {
        progress.startProgress()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
  
        showErrorMessage(false)
        
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