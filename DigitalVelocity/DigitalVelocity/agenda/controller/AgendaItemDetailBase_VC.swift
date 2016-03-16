//
//  AgendaItemDetailBase_VC.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/17/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class AgendaItemDetailBase_VC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var favoriteButton : UIButton?

    var itemData:CellData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = itemData {
            setupViewWithData(data)
        }
        setupMenuNavigationForController()
        updateFavoriteButton()
        self.favoriteButton?.accessibilityIdentifier = "Favorite Button"
    }
    
    func setupViewWithData(data:CellData) {

        titleLabel.text     = data.title

        if let subtitle = data.subtitle {
            let paragraphStyle:NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            
            paragraphStyle.alignment            = NSTextAlignment.Left
            paragraphStyle.firstLineHeadIndent  = 8
            paragraphStyle.headIndent           = 8
            paragraphStyle.tailIndent           = -8
            paragraphStyle.lineHeightMultiple   = 1.25
            
            subtitleLabel.attributedText = NSAttributedString(string: subtitle, attributes: [NSParagraphStyleAttributeName : paragraphStyle])

            subtitleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            subtitleLabel.numberOfLines = 0

        } else {
            subtitleLabel.text = nil
        }
        
        // TODO: Setup star icon button here

        locationLabel.text  = data.locationInfoString()
        
        if let detailText = data.targetDescription {
            
            let paragraphStyle:NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            
            paragraphStyle.alignment            = NSTextAlignment.Left
            paragraphStyle.lineHeightMultiple   = 1.25
            
            let font = UIFont(name: "MyriadPro-Regular", size: 16)
            
            var attributes = [String:AnyObject]()
            
            attributes[NSParagraphStyleAttributeName]   = paragraphStyle
            attributes[NSFontAttributeName]             = font

            descriptionTextView.attributedText = NSAttributedString(string: detailText, attributes: attributes)
            descriptionTextView.scrollRangeToVisible(NSMakeRange(0, 1))
            
        }
    }
    
    @IBAction func toggleFavorite(sender: AnyObject) {
        self.itemData?.delegate = self
        self.itemData?.toggleFavorite(nil)
    }
    

    private func updateFavoriteButton(){
        var title : String
        if self.itemData?.isLocalFavorite() == true{
            title = FontAwesomeHelper.labelStringFromFontAwesome(unicode: "f005")
        } else {
            title = FontAwesomeHelper.labelStringFromFontAwesome(unicode: "f006")
        }
        
        favoriteButton?.titleLabel?.font = FontAwesomeHelper.fontAwesomeForSize(28)
        favoriteButton?.setTitle(title, forState: UIControlState.Normal)
        favoriteButton?.accessibilityIdentifier = "Favorite Button"
    }
}

extension AgendaItemDetailBase_VC : CellDataFavoriteDelegate{
    
    func cellDataFavoriteToggled(originObject: AnyObject?) {
        
        self.updateFavoriteButton()
    }
    
}
    