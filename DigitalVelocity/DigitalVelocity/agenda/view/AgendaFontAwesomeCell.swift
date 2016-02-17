//
//  AgendaFontAwesomeCell.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/28/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class AgendaFontAwesomeCell: AgendaBaseCell {

    @IBOutlet weak var iconLabel: UILabel!

    override var cellType:AgendaCellType {
        get {
            return AgendaCellType.FontAwesome
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    
        iconLabel.font = FontAwesomeHelper.fontAwesomeForSize(50)
        
        iconLabel.textColor = UIColor.grayColor()

        iconLabel.lineBreakMode = NSLineBreakMode.ByClipping
    }

    func updateIconWithFontAwesome(unicode unicode: String) {
        
        iconLabel.text = FontAwesomeHelper.labelStringFromFontAwesome(unicode: unicode)
    }
}
