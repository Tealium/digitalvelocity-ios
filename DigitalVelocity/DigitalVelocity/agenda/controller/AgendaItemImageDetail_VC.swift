//
//  AgendaItemImageDetail_VC.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/29/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class AgendaItemImageDetail_VC: AgendaItemDetailBase_VC {

    @IBOutlet weak var imageView: UIImageView!

    override func setupViewWithData(data: CellData) {
        
        super.setupViewWithData(data)

        imageView.contentMode = UIViewContentMode.ScaleAspectFit

        imageView.image = UIImage(data: data.imageData)
    
    }
    
}
