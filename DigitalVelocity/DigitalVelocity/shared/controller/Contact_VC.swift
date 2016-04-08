//
//  ContactViewController.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/12/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit
import MessageUI
import CoreTelephony

class Contact_VC: UIViewController {
    
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    
    var contactData = [ NSObject : AnyObject]()
    
    private let twitterURLPrefix = "twitter://search?query=%23"
    private let twitterEventId = "digitalvelocity2016"
    private let facebookURLPrefix = "fb://events/"
    private let facebookEventId = "479789605497021"
    private let callNumber = "8587791344"
    
    // MARK:
    // MARK: SETUP
    override func viewDidLoad(){
        super.viewDidLoad()
        
        twitterButton.titleLabel?.font = FontAwesomeHelper.fontAwesomeForSize(64)
        facebookButton.titleLabel?.font = FontAwesomeHelper.fontAwesomeForSize(66)
        emailButton.titleLabel?.font = FontAwesomeHelper.fontAwesomeForSize(62)
        callButton.titleLabel?.font = FontAwesomeHelper.fontAwesomeForSize(72)

        makeRoundedButton(twitterButton)
        makeRoundedButton(facebookButton)
        makeRoundedButton(emailButton)
        makeRoundedButton(callButton)
        
        setupMenuNavigationForController()
        
        getContactInfo()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
      
        if canOpenURL(twitterURL()){
            enableButton(twitterButton)
        }
        
        if canOpenURL(facebookURL()){
            enableButton(facebookButton)
        }
        
    // Bug in iOS8 prevents this check from working - use CTTelphony instead
//        if canOpenURL(callURL){
//            enableButton(callButton)
//        }
        
        if (CTTelephonyNetworkInfo().subscriberCellularProvider != nil){
            enableButton(callButton)
        }
        
        if MFMailComposeViewController.canSendMail() {
            enableButton(emailButton)
        }
        
        Analytics.trackView(self)
    }

    func getContactInfo() {
        ph.fetchSpecificRecord("Contact", key: "location", value: "SD") { (dictionary, error) -> () in
            
            if let _ = error {
                TEALLog.log("Error getting contact info: \(error)")
                // Use defaults
            }
            
            self.contactData.addEntriesFrom(dictionary)
        }
    }
    
    func disableButton(button:UIButton){
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            button.backgroundColor  = UIColor.grayColor()
            }) { (success) -> Void in
                button.userInteractionEnabled = false
        }
    }
    
    func enableButton(button:UIButton){
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            button.backgroundColor  = UIColor_TealiumBlue
        }) { (success) -> Void in
            button.userInteractionEnabled = true
        }
    }
    
    func makeRoundedButton(button: UIButton){
        button.layer.cornerRadius = button.frame.size.width/2
    }
    
    // MARK:
    // MARK: ACTIONS
    @IBAction func twitter() {

        Analytics.trackEvent("Contact Twitter Button Tapped")
        requestOpenURLWithString(twitterURL())
    }
    
    @IBAction func facebook() {
        
        Analytics.trackEvent("Contact Facebook Button Tapped")
        requestOpenURLWithString(facebookURL())
    }
    
    @IBAction func email() {
        
        Analytics.trackEvent("Contact Email Button Tapped")
        
        if MFMailComposeViewController.canSendMail() {

            let emailSubject = self.contactData[ph.keyEmailHeader] as? String ?? "Digital Velocity Question"
            
            let emailAddress = self.contactData[ph.keyEmail] as? String ?? "digitalvelocity@tealium.com"
           
            let emailBody = self.contactData[ph.keyEmailMessage] as? String ?? ""
            
            let mc = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(emailSubject)
            mc.setMessageBody(emailBody, isHTML: false)
            mc.setToRecipients([emailAddress])
            
            self.presentViewController(mc, animated: true, completion: nil)
        }
    }
    
    @IBAction func call() {
        
        Analytics.trackEvent("Contact Call Button Tapped")
        
        let number = self.contactData["phoneNumber"] as? String ?? callNumber
        let actual = "tel://" + number
        
        requestOpenURLWithString(actual)
    }
    
    
    // MARK:
    // MARK: HELPERS
    func canOpenURL(urlString:String)->Bool{
        if let url = NSURL(string: urlString) {
            
            let application = UIApplication.sharedApplication()
            
            if application.canOpenURL(url) {
                return true
            }
        }
        return false
    }
    
    func requestOpenURLWithString(urlString:String){
        
        if canOpenURL(urlString){
            if let url = NSURL(string: urlString){
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    func facebookURL() -> String {
        
        let facebook = self.contactData["facebook"] as? String ?? facebookEventId
        let actual = facebookURLPrefix + facebook
        return actual
        
    }
    
    func twitterURL() -> String {
        
        let twitter = self.contactData["twitter"] as? String ?? twitterEventId
        let actual = twitterURLPrefix + twitter
        return actual
        
    }
}

// MARK:
// MARK: MFMailComposerVC Delegate
extension Contact_VC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        
        switch result.rawValue {
        
        case MFMailComposeResultCancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Mail saved")
        case MFMailComposeResultSent.rawValue:
            print("Mail sent")
        case MFMailComposeResultFailed.rawValue:
            if let error = error {
                print("Mail sent failure: \(error.localizedDescription)")
            } else {
                print("Mail sent failure.")
            }
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}