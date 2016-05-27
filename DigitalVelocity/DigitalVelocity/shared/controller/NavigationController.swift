//
//  NavigationController.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/30/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

protocol NavigationControllerMenuDelegate {
    func menuToggleRequested()
}

protocol NavigationControllerFilterDelegate{
    func filterOn()
    func filterOff()
}

var _menuButton : UIBarButtonItem?

class NavigationController: UINavigationController {

    var menuDelegate:NavigationControllerMenuDelegate?
    var filterDelegate:NavigationControllerFilterDelegate?
    var _filterButton : UIBarButtonItem?
    var isFilterOn: Bool = false
    
    func addMenuButtonToViewController(viewController:UIViewController) {
        
        viewController.navigationItem.rightBarButtonItem = self.menuButton()
        
    }
    
    func addNavigationButtonsToViewController(viewController: UIViewController) {
        
        viewController.navigationItem.setRightBarButtonItems([self.menuButton(), self.filterButton()], animated: true);
    }
    
    private func menuButton()->UIBarButtonItem{
        
        if _menuButton == nil{
            _menuButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleMenuButton(_:)))
            
            let font = FontAwesomeHelper.fontAwesomeForSize(28)
            let attributes  = NSDictionary(object: font, forKey: NSFontAttributeName)
            _menuButton!.accessibilityIdentifier = "Menu Button"
            
            if let attributes = attributes as? [String : AnyObject]{
            
                _menuButton!.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
                
            }
        }
        return _menuButton!
    }
    
    private func filterButton()->UIBarButtonItem{
        
        if _filterButton == nil {
            _filterButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "handleFilterButton:")
            
            let font = FontAwesomeHelper.fontAwesomeForSize(28)
            let attributes  = NSDictionary(object: font, forKey: NSFontAttributeName)
            self.filterButton().accessibilityIdentifier = "Filter Button"
            
            if let attributes = attributes as? [String: AnyObject]{
                
                _filterButton!.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
                
            }
        }
        resetFilterButton()
        return _filterButton!
    }
    
    func handleMenuButton(sender: AnyObject) {
        
        menuDelegate?.menuToggleRequested()
    }
    
    func resetFilterButton(){
        _filterButton!.title = ""
        isFilterOn = false
        filterDelegate?.filterOff()
    }
    
    func handleFilterButton(sender: AnyObject) {
        
        if isFilterOn {
            _filterButton!.title = ""
            isFilterOn = false
            filterDelegate?.filterOff()
        } else {
            _filterButton!.title = ""
            isFilterOn = true
            filterDelegate?.filterOn()
        }
    }
    
}
