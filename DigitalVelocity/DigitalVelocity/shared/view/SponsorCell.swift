//
//  SponsorCell.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/24/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class SponsorCell: DVBaseTableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.titleLabel.numberOfLines = 0

        self.subtitleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.subtitleLabel.numberOfLines = 0

        self.iconView.contentMode = UIViewContentMode.ScaleAspectFit
        
    }
 
}
