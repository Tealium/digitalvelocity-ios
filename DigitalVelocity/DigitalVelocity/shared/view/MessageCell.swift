//
//  MessageCell.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/27/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    convenience init(reuseIdentifier: String?) {

        self.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupWithMessage(message:String) {
        
        textLabel?.textAlignment = NSTextAlignment.Center
        textLabel?.text = "No Content Available"
        
    }
}
