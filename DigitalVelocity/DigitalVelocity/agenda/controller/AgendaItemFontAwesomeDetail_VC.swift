//
//  AgendaItemFontAwesomeDetail_VC.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/29/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class AgendaItemFontAwesomeDetail_VC: AgendaItemDetailBase_VC {

    @IBOutlet weak var iconLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconLabel.font = FontAwesomeHelper.fontAwesomeForSize(80)
    }
    override func setupViewWithData(data: CellData) {
        
        super.setupViewWithData(data)

        if let fontAwesome = itemData?.fontAwesomeValue {
            iconLabel.text = FontAwesomeHelper.labelStringFromFontAwesome(unicode: fontAwesome)
            iconLabel.lineBreakMode = NSLineBreakMode.ByClipping

        }
    }
}
