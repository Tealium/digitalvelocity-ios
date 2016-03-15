//
//  Demo_VC.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/17/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import UIKit

class Demo_VC: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var accountTextField: UITextField!{
        didSet{
            let bottomLine = CALayer()
            bottomLine.frame = CGRectMake(0.0, accountTextField.frame.height - 1, accountTextField.frame.width, 1.0)
            bottomLine.backgroundColor = UIColor.whiteColor().CGColor
            accountTextField.borderStyle = UITextBorderStyle.None
            accountTextField.layer.addSublayer(bottomLine)
            
            let str = NSAttributedString(string: "(Account)", attributes: [NSForegroundColorAttributeName:UIColor.lightGrayColor()])
            accountTextField.attributedPlaceholder = str
            accountTextField.accessibilityIdentifier = "Account Text Field"
        }
    }

    @IBOutlet weak var profileTextField: UITextField!{
        didSet{
            let bottomLine = CALayer()
            bottomLine.frame = CGRectMake(0.0, profileTextField.frame.height - 1, profileTextField.frame.width, 1.0)
            bottomLine.backgroundColor = UIColor.whiteColor().CGColor
            profileTextField.borderStyle = UITextBorderStyle.None
            profileTextField.layer.addSublayer(bottomLine)
            let str = NSAttributedString(string: "(Profile)", attributes: [NSForegroundColorAttributeName:UIColor.lightGrayColor()])
            profileTextField.attributedPlaceholder = str
            profileTextField.accessibilityIdentifier = "Profile Text Field"
            
        }
    }
    
    @IBOutlet weak var environmentTextField: UITextField!{
        didSet{
            let bottomLine = CALayer()
            bottomLine.frame = CGRectMake(0.0, environmentTextField.frame.height - 1, environmentTextField.frame.width, 1.0)
            bottomLine.backgroundColor = UIColor.whiteColor().CGColor
            environmentTextField.borderStyle = UITextBorderStyle.None
            environmentTextField.layer.addSublayer(bottomLine)
            let str = NSAttributedString(string: "(Environment)", attributes: [NSForegroundColorAttributeName:UIColor.lightGrayColor()])
            environmentTextField.attributedPlaceholder = str
            environmentTextField.accessibilityIdentifier = "Environment Text Field"
            
        }
    }
    
    @IBOutlet weak var audienceStreamView: UIView!{
        didSet{
            audienceStreamView.layer.borderWidth = 1
            audienceStreamView.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
   
    @IBOutlet weak var audienceStreamTextField: UITextField!{
        didSet{
            let bottomLine = CALayer()
            bottomLine.frame = CGRectMake(0.0, audienceStreamTextField.frame.height - 1, audienceStreamTextField.frame.width, 1.0)
            bottomLine.backgroundColor = UIColor.whiteColor().CGColor
            audienceStreamTextField.borderStyle = UITextBorderStyle.None
            audienceStreamTextField.layer.addSublayer(bottomLine)
            let str = NSAttributedString(string: "(Audience Stream)", attributes: [NSForegroundColorAttributeName:UIColor.lightGrayColor()])
            audienceStreamTextField.attributedPlaceholder = str
            audienceStreamTextField.accessibilityIdentifier = "Audience Stream View"
        }
    }
    @IBOutlet weak var saveButton: UIButton!{
        didSet{
            saveButton.layer.borderWidth = 1
            saveButton.layer.borderColor = UIColor.whiteColor().CGColor
            saveButton.accessibilityIdentifier = "Save Button"
            
        }
    }
    
    //MARK: LIFECYCLE
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountTextField.delegate = self
        profileTextField.delegate = self
        environmentTextField.delegate = self
        audienceStreamTextField.delegate = self
        
        accountTextField.becomeFirstResponder()
        
        setupMenuNavigationForController()
        self.prepopulateTextFields()
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clearColor()
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            //blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            self.backgroundImageView.addSubview(blurEffectView)
            self.view.sendSubviewToBack(self.backgroundImageView)
        }
        else {
            self.view.backgroundColor = UIColor.blackColor()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        Analytics.trackView(self, data: nil)
    }
    
    //MARK: Private Methods
    func prepopulateTextFields(){
        
        guard let config = Analytics.currentDemoConfig() else{
            TEALLog.log("no saved configDictionay")
            return
        }
        
        if let account = config[tealiumAccountKey] as? String {
            self.accountTextField.text = account
        }
        
        if let profile = config[tealiumProfileKey] as? String {
            self.profileTextField.text = profile
        }
        
        if let environment = config[tealiumEnvironmentKey] as? String {
            self.environmentTextField.text = environment
        }
        
        if let traceID = Analytics.currentTraceId() {
            self.audienceStreamTextField.text = traceID
        }
    }

    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        
        self.accountTextField.backgroundColor = UIColor.clearColor()
        self.profileTextField.backgroundColor = UIColor.clearColor()
        self.environmentTextField.backgroundColor = UIColor.clearColor()
        
        guard let accountEntryTemp = self.accountTextField.text else{
            return
        }
        
        guard let profileEntryTemp = self.profileTextField.text else{
            return
        }
        
        guard let environmentEntryTemp = self.environmentTextField.text else{
            return
        }
        
        if (self.audienceStreamTextField.text != "" &&
            !accountEntryTemp.isEmpty &&
            !profileEntryTemp.isEmpty &&
            !environmentEntryTemp.isEmpty) {
            self.presentAudienceStreamAlert()
            return
        }
        
        if (self.audienceStreamTextField.text != "" &&
            accountEntryTemp.isEmpty ||
            profileEntryTemp.isEmpty ||
            environmentEntryTemp.isEmpty){
            self.presentAudienceStreamAlertFailure()
            return
        }
        
        //checking for empty strings
        if accountEntryTemp.isEmpty {
            self.accountTextField.backgroundColor = UIColor.redColor()
            self.presentEmptyFieldAlert()
            return
        }
        
        if profileEntryTemp.isEmpty{
            self.profileTextField.backgroundColor = UIColor.redColor()
            self.presentEmptyFieldAlert()
            return
        }
        
        if environmentEntryTemp.isEmpty{
            self.environmentTextField.backgroundColor = UIColor.redColor()
            self.presentEmptyFieldAlert()
            return
        }
        
        self.presentSuccessAlert()
        
        Analytics.updateTealiumDemoInstance(accountEntryTemp , profile: profileEntryTemp, environment: environmentEntryTemp)
        
        Analytics.updateDemoTraceId(self.audienceStreamTextField.text)
        
        Analytics.trackEvent("Demo Save Button Tapped")
        
        print(environmentEntryTemp)
        
    }


    
    //MARK: AlertController Methods
    
    func presentEmptyFieldAlert(){
        let alertController = UIAlertController(title: "Unable to Update Your Account", message: "You must fill in all fields in order to save", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentSuccessAlert(){
        let alertController = UIAlertController(title: "Success", message: "Demo account updated", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentAudienceStreamAlert(){
        let alertController = UIAlertController(title: "Success", message: "Your traceID has been updated", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
   
    
    func presentAudienceStreamAlertFailure(){
        let alertController = UIAlertController(title: "Unable to Update Your Account", message: "Your traceID must be associated with an Account, Profile, and Environment", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

extension Demo_VC : UITextFieldDelegate{

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.accountTextField{
            self.profileTextField.becomeFirstResponder()
        }
        if textField == self.profileTextField{
            self.environmentTextField.becomeFirstResponder()
        }
        else{
            textField.resignFirstResponder()
        }
        
        return true
    }



}
