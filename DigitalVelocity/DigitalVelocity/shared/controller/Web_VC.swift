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
    
    // MARK: Setup
    
    override func viewDidLoad() {
        
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
        
        Analytics.trackView(self)
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
        progress.finishedLoading = true
    }
}