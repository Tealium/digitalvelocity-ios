//
//  SurveyBaseCell.swift
//  DigitalVelocity
//
//  Created by Merritt Tidwell on 3/30/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import UIKit

class SurveyBaseCell: DVBaseTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    var questionID: String!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.titleLabel.numberOfLines = 0

        iconLabel.font = FontAwesomeHelper.fontAwesomeForSize(50)
        
        iconLabel.textColor = UIColor.grayColor()
        
        iconLabel.lineBreakMode = NSLineBreakMode.ByClipping
    }
  
    func updateIconWithFontAwesome(unicode unicode: String) {
        
        iconLabel.text = FontAwesomeHelper.labelStringFromFontAwesome(unicode: unicode)
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
