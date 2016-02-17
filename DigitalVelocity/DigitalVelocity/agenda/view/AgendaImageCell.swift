//
//  AgendaCell.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/24/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class AgendaImageCell: AgendaBaseCell {
    
    @IBOutlet weak var iconView: UIImageView!

    override var cellType:AgendaCellType {
        get {
            return AgendaCellType.Image
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.iconView.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    

}
