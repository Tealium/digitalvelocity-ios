//
//  SubmitButtonCell.swift
//  DigitalVelocity
//
//  Created by Merritt Tidwell on 4/1/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import UIKit

class SubmitButtonCell: DVBaseTableViewCell {

    @IBOutlet weak var submitButton: UIButton! {
        didSet{
            submitButton.layer.borderWidth = 2
            submitButton.layer.borderColor = UIColor_TealiumBlue.CGColor
            submitButton.accessibilityIdentifier = "Save Button"

        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
