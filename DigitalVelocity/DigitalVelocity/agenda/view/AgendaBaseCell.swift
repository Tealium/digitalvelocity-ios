//
//  AgendaBaseCell.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/28/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

enum AgendaCellType: Int {
    case Image = 0
    case FontAwesome
}

class AgendaBaseCell: DVBaseTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    var cellType:AgendaCellType {
        get {
            return AgendaCellType.Image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.titleLabel.numberOfLines = 3
    }
    
}