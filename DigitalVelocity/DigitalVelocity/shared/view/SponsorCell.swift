//
//  SponsorCell.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/24/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

protocol SponsorCellDelegate {

    func sponsorCellDemoRequested(index:NSIndexPath)
    
}

let SponsorCellKey_EmailAddress = "email"
let SponsorCellKey_EmailMessage = "message"

class SponsorCell: DVBaseTableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var requestDemoButton: UIButton!
    
    var sponsorDelegate : SponsorCellDelegate?
    var index : NSIndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.titleLabel.numberOfLines = 0
        self.subtitleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.subtitleLabel.sizeToFit()
        self.iconView.contentMode = UIViewContentMode.ScaleAspectFit
        self.requestDemoButton.titleLabel?.textAlignment = .Center
        self.requestDemoButton.layer.borderWidth = 1
        self.requestDemoButton.layer.borderColor = UIColor(red:0/255, green: 168/255, blue: 182/255, alpha: 1.0).CGColor

    }
 
    func setup(index:NSIndexPath){
        self.index = index
    }
    
    @IBAction func launchDemo(sender: UIButton){
        print("demo pressed")
        
        guard let index = self.index else {
            TEALLog.log("No indexPath for cell, was setup() called?")
            return
        }
        
        self.sponsorDelegate?.sponsorCellDemoRequested(index)
        
    }
}
