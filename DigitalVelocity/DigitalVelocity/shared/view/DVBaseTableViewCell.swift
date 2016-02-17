//
//  DVBaseTableViewCell.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/24/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

protocol DVTableViewCellDelegate {
    
    func tableViewCellAccessoryTapped(tableViewCell:DVBaseTableViewCell)
    func tableViewCellFavoriteTapped(tableViewCell:DVBaseTableViewCell)
}

class DVBaseTableViewCell: UITableViewCell {

    @IBOutlet weak var favoriteStatus: UIButton?

    var delegate: DVTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.textLabel?.numberOfLines = 3

        self.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        favoriteStatus?.titleLabel?.font = FontAwesomeHelper.fontAwesomeForSize(16)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func addMapAccessoryIcon() {
        
        if self.accessoryView == nil {
            self.accessoryView = mapIconAccessoryView()
        }
    }
    
    @IBAction func favoriteTapped(sender:AnyObject){
        
        delegate?.tableViewCellFavoriteTapped(self)
    }

    func accessoryTapped(sender:AnyObject) {
        
        delegate?.tableViewCellAccessoryTapped(self)
    }
    
    func removeMapAccessoryIcon() {
        
        if accessoryView != nil {
            accessoryView?.removeFromSuperview()
            accessoryView = nil
        }
    }
    
    func mapIconAccessoryView() -> UIView {

        let button = UIButton(frame: CGRectMake(0, 0, 24, 24))

        button.backgroundColor  = UIColor_TealiumBlue
        button.titleLabel?.font = FontAwesomeHelper.fontAwesomeForSize(16)

        button.setTitle("\u{f041}", forState: UIControlState.Normal)
        button.addTarget(self, action: "accessoryTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        button.layer.cornerRadius = CGRectGetMidY(button.frame)
        
        return button

    }
    
    func updateFavoriteStatus(isFavorite:Bool){
        if let favoriteStatus = favoriteStatus{
            var title : String
            if isFavorite{
                title = FontAwesomeHelper.labelStringFromFontAwesome(unicode: "f005")
            } else {
                title = "" //FontAwesomeHelper.labelStringFromFontAwesome(unicode: "f006")
            }
            
            favoriteStatus.titleLabel?.font = FontAwesomeHelper.fontAwesomeForSize(16)
            favoriteStatus.setTitle(title, forState: UIControlState.Normal)
        }
    }
}
