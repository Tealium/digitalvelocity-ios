//
//  SettingsViewController.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/13/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class Settings_VC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!{
        didSet{
            let bottomLine = CALayer()
            bottomLine.frame = CGRectMake(0.0, emailTextField.frame.height - 1, emailTextField.frame.width, 1.0)
            bottomLine.backgroundColor = UIColor.whiteColor().CGColor
            emailTextField.borderStyle = UITextBorderStyle.None
            emailTextField.layer.addSublayer(bottomLine)
            let str = NSAttributedString(string: "(Registration Email)", attributes: [NSForegroundColorAttributeName:UIColor.lightGrayColor()])
            emailTextField.attributedPlaceholder = str
            
        }

    }
   
    
    @IBOutlet weak var disableTrackingSwitch: UISwitch!
    @IBOutlet weak var trackingStatusLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupMenuNavigationForController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let email = User.sharedInstance.email{
            emailTextField.text = email
        }
        self.updateSwitch()
        Analytics.trackView(self)
    }
    
    func updateSwitch(){
        if (User.sharedInstance.optInTracking){
            disableTrackingSwitch.setOn(false, animated: false)
        } else {
            disableTrackingSwitch.setOn(true, animated: false)
        }
        self.updateSwitchLabel()
    }
    
    func updateSwitchLabel(){
        if (disableTrackingSwitch.on){
            trackingStatusLabel.text = "Tracking: OFF"
        } else {
            trackingStatusLabel.text = "Tracking: ON"
        }
    }
    
    @IBAction func clearFirstResponder(sender:AnyObject?){
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func audienceStreamTrace(sender:AnyObject?){
//        self.performSegueWithIdentifier(menuOptions.web.storyboardId, sender: self)
    }
    
    
    @IBAction func toggleTracking(sender: UISwitch) {
        if (sender.on){
            User.sharedInstance.optInTracking = false
            TEALLog.log("Tracking has been disabled.")
        } else {
            User.sharedInstance.optInTracking = true
        }
        self.updateSwitchLabel()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == menuOptions.web.storyboardId{
            if let d = segue.destinationViewController as? Web_VC{
               d.url = NSURL(string: "http://tealium.com/products/data-distribution/audiencestream/")
            }
        }
    }
}

extension Settings_VC: UITextFieldDelegate{


    func textFieldDidEndEditing(textField: UITextField) {
        if textField == emailTextField{
            if let text = textField.text {
                textField.text = text.lowercaseString
                if textField.text != User.sharedInstance.email{
                    User.sharedInstance.email = textField.text
                }
            }
        }
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
