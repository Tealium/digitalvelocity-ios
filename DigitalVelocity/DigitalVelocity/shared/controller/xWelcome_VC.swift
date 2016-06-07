//
//  Welcome.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/12/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class Welcome_VC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var refreshButton : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: defaultImageName)
        
        navigationItem.titleView =  UIImageView(image: image)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newDataAvailable(_:)), name: notificationKeyConfigData, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(noDataYetAvailable(_:)), name: notificationKeyNoConfigDataYet, object: nil)

        newDataAvailable(nil)
        setupMenuNavigationForController()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.trackView(self)
    }
    
    @IBAction func refresh(){
        // TODO: Temp solution
        if ph.isLoaded == false{
            refreshButton.userInteractionEnabled = true
            refreshButton.alpha = 1.0
            ph.loadConfig()
//            EventDataStore.sharedInstance().loadRemoteData()
        } else {
            refreshButton.userInteractionEnabled = false
            refreshButton.alpha = 0.0
        }
    }
    
    func noDataYetAvailable(notification:NSNotification?){
        self.updateDescriptionWithText("Please go online to update content")

        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.titleLabel.alpha = 0.0
            self.descriptionLabel.alpha = 1.0
            self.subtitleLabel.alpha = 0.0
            }) { (finished) -> Void in
        }
    }
    
    func newDataAvailable(notification:NSNotification?){
        
        var canAnimate = false
        
        if self.titleLabel.text != ph.config.welcomeTitle{
            canAnimate = true
        }
        if self.descriptionLabel.text != ph.config.welcomeDescription{
            canAnimate = true
        }
        if self.subtitleLabel.text != ph.config.welcomeSubtitle{
            canAnimate = true
        }
        
        if canAnimate == true{
            // Fade out
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.titleLabel.alpha = 0.0
                self.descriptionLabel.alpha = 0.0
                self.subtitleLabel.alpha = 0.0
                
            }) { (finished) -> Void in
                self.titleLabel.text = ph.config.welcomeTitle
                self.updateDescriptionWithText(ph.config.welcomeDescription)
                self.subtitleLabel.text = ph.config.welcomeSubtitle
                
                // Fade back in
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.titleLabel.alpha = 1.0
                    self.descriptionLabel.alpha = 1.0
                    self.subtitleLabel.alpha = 1.0
                }, completion: { (success) -> Void in
                    // nothing else at the moment
                })
            }
        }

    }
    
    func updateDescriptionWithText(text:String) {
        
        let paragraphStyle:NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        
        paragraphStyle.alignment = NSTextAlignment.Center
        paragraphStyle.firstLineHeadIndent = 10
        paragraphStyle.headIndent = 10
        paragraphStyle.tailIndent = -10
        
        self.descriptionLabel.attributedText = NSAttributedString(string: text, attributes: [NSParagraphStyleAttributeName : paragraphStyle])
        
    }
}
