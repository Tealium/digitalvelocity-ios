//
//  SignIn.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/12/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

public let loginSuccessfulNotification = "loginSuccessful"

class SignIn_VC: UIViewController {

    @IBOutlet weak var emailTextField:UITextField! {
        didSet{
            let bottomLine = CALayer()
            bottomLine.frame = CGRectMake(0.0, emailTextField.frame.height - 1, emailTextField.frame.width, 1.0)
            bottomLine.backgroundColor = UIColor.whiteColor().CGColor
            emailTextField.borderStyle = UITextBorderStyle.None
            emailTextField.layer.addSublayer(bottomLine)
            
            let str = NSAttributedString(string: "(Account)", attributes: [NSForegroundColorAttributeName:UIColor.lightGrayColor()])
            emailTextField.attributedPlaceholder = str
        }
    }
    
    @IBOutlet weak var enterButton: UIButton!{
        didSet{
            enterButton.layer.borderColor = UIColor.whiteColor().CGColor
            enterButton.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var skipButton: UIButton!{
        didSet{
            skipButton.layer.borderWidth = 1
            skipButton.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        if User.sharedInstance.email != nil{
            login()
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
        
        Analytics.trackView(self)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return UIStatusBarStyle.LightContent
    }

    @IBAction func done(){
        // Validate email string entry
        if let emailString = emailTextField.text?.lowercaseString{
            User.sharedInstance.email = emailString
            if User.sharedInstance.isValidEmail(emailString){
                login()
            } else {
                let alert = UIAlertView(title: "Invalid Email Address", message: nil, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }
    
    @IBAction func skip(){
        User.sharedInstance.skipCount++
        emailTextField.resignFirstResponder()
        login()
    }
    
    private func login(){
        NSNotificationCenter.defaultCenter().postNotificationName(loginSuccessfulNotification, object: nil)
    }
    
    
}

extension SignIn_VC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let text = textField.text {
            textField.text = text.lowercaseString
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
    
        done()
        return true;
    }
}
