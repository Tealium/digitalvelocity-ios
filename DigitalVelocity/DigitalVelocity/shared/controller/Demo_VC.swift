//
//  Demo_VC.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/17/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import UIKit

class Demo_VC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var profileTextField: UITextField!
    @IBOutlet weak var environmentTextField: UITextField!
    @IBOutlet weak var audienceStreamTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!{
        didSet{
            saveButton.layer.borderWidth = 1
            saveButton.layer.borderColor = UIColor.whiteColor().CGColor
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountTextField.delegate = self
        profileTextField.delegate = self
        environmentTextField.delegate = self
        audienceStreamTextField.delegate = self
        
        setupMenuNavigationForController()
        self.prepopulateTextFields()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        Analytics.trackView(self, data: nil)
    }
    
    
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
        
        guard let accountEntryTemp = self.accountTextField.text else{
            return
        }
        
        guard let profileEntryTemp = self.profileTextField.text else{
            return
        }

        guard let environmentEntryTemp = self.environmentTextField.text else{
            return
        }
        
        Analytics.updateTealiumDemoInstance(accountEntryTemp , profile: profileEntryTemp, environment: environmentEntryTemp)
        
        Analytics.updateDemoTraceId(self.audienceStreamTextField.text)
        
        Analytics.trackEvent("Demo Save Button Tapped")
        
        print(accountEntryTemp)
       
    }
    

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        accountTextField.resignFirstResponder()
        profileTextField.resignFirstResponder()
        environmentTextField.resignFirstResponder()
        audienceStreamTextField.resignFirstResponder()

        return true
    }
    
}