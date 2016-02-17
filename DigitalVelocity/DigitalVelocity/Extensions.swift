//
//  Extensions.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 3/10/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

/**
 Extension to any Apple objects
 
*/
extension UIViewController {

    func setupMenuNavigationForController() {
        // Adds just menu icon
        if let navController = self.navigationController as? NavigationController {
            navController.addMenuButtonToViewController(self)
        }
    }
    
    func setupNavigationItemsForController() {
        // Adds menu icon + search icon
        if let navController = self.navigationController as? NavigationController {
            navController.addNavigationButtonsToViewController(self)
        }
    }
}

extension Bool{
    func toString()->String{
        if (self == true){
            return "true"
        } else {
            return "false"
        }
    }
}

extension String{
    func toBool()->Bool?{
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

extension Dictionary {
    mutating func addEntriesFrom(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}