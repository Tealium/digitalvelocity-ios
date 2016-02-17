//
//  DVHeaderTableViewCell.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/24/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class DVHeaderTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.teal_colorWithHexString("#53585D")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(title: String) {
        
        if let label = textLabel {
            label.text = title
            label.textColor = UIColor.whiteColor()
            label.textAlignment = NSTextAlignment.Center
        }
    }

}
