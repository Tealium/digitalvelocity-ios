//
//  ViewControllerLazyLoader.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/12/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

// Localizable titles

private let _signIn : String = NSLocalizedString("Sign In", tableName: nil, bundle: NSBundle.mainBundle(), value: "Sign In", comment: "Sign In")
private let _welcome : String = NSLocalizedString("Welcome", tableName: nil, bundle: NSBundle.mainBundle(), value: "Welcome", comment: "Welcome")
private let _agenda : String = NSLocalizedString("Agenda", tableName: nil, bundle: NSBundle.mainBundle(), value: "Agenda", comment: "Agenda")
private let _location : String = NSLocalizedString("Event Location", tableName: nil, bundle: NSBundle.mainBundle(), value: "Event Location", comment: "Event Location")
private let _notifications : String = NSLocalizedString("Notifications", tableName: nil, bundle: NSBundle.mainBundle(), value: "Notifications", comment: "Notifications")
private let _sponsors : String = NSLocalizedString("Sponsors", tableName: nil, bundle: NSBundle.mainBundle(), value: "Sponsors", comment: "Sponsors")
private let _contact : String = NSLocalizedString("Contact", tableName: nil, bundle: NSBundle.mainBundle(), value: "Contact", comment: "Contact")
private let _chat : String = NSLocalizedString("Chat", tableName: nil, bundle: NSBundle.mainBundle(), value: "Chat", comment: "Chat")
private let _demo : String = NSLocalizedString("Demo", tableName: nil, bundle: NSBundle.mainBundle(), value: "Demo", comment: "Demo")

enum menuOptions{
    case signIn
    case welcome
    case agenda
    case agendaDetailImage
    case agendaDetailIconLabel
    case location
    case notifications
    case sponsors
    case contact
    case demo
    case settings
    case chat
    case web
    case unknown
    
    // TODO: finish localizing

    var title: String{
        switch(self){
        case .signIn:                   return _signIn
        case .welcome:                  return _welcome
        case .agenda:                   return _agenda
        case .agendaDetailImage:        return "AgendaDetailImage"
        case .agendaDetailIconLabel:    return "AgendaDetailIcon"
        case .location:                 return _location
        case .notifications:            return _notifications
        case .sponsors:                 return _sponsors
        case .contact:                  return _contact
        case .demo:                     return _demo
        case .settings:                 return "Settings"
        case .web:                      return "Web"
        case .chat :                    return _chat
        default:                        return "(unknown)"
        }
    }
    
    var storyboardId: String{
        switch(self){
        case .signIn:                   return "Sign In"
        case .welcome:                  return "Welcome"
        case .agenda:                   return "Agenda"
        case .agendaDetailImage:        return "AgendaDetailImage"
        case .agendaDetailIconLabel:    return "AgendaDetailIcon"
        case .location:                 return "Event Location"
        case .notifications:            return "Notifications"
        case .sponsors:                 return "Sponsors"
        case .contact:                  return "Contact"
        case .demo:                     return "Demo"
        case .settings:                 return "Settings"
        case .web:                      return "Web"
        case .chat:                     return "Chat"
        default:                        return "(unknown)"
        }
    }
    
    func toEnum(title:String?)-> menuOptions{
        if let validString = title{
            switch validString{
            case _signIn:               return .signIn
            case _welcome:              return .welcome
            case _agenda:               return .agenda
            case "AgendaDetailImage":   return .agendaDetailImage
            case "AgendaDetailIcon":    return .agendaDetailIconLabel
            case _location:             return .location
            case _notifications:        return .notifications
            case _sponsors:             return .sponsors
            case _contact:              return .contact
            case _demo:                 return .demo
            case "Settings":            return .settings
            case "Web":                 return .web
            case _chat:                 return .chat
            default:                    return .unknown
            }
        } else {
            return .unknown
        }
    }
    
    
}

private var _menuOptions : [MenuOption] = [MenuOption]()

/**
 This class permits view titles to be separated from storyboard Ids, allowing localization of titles

 */
class MenuOption{
    
    var title : String!
    var storyboardId : String!

    init(title: String, storyboardId: String){
        self.title = title
        self.storyboardId = storyboardId
        
    }
    
    func isEqualTo(menuOption: MenuOption)->Bool{
        if self.title == menuOption.title && self.storyboardId == menuOption.storyboardId  {
            return true
        }
        return false
    }
    
    class func allOptions() -> [MenuOption]{
        if _menuOptions.isEmpty{
            let option1 = MenuOption(title: menuOptions.welcome.title, storyboardId: menuOptions.welcome.storyboardId)
            let option2 = MenuOption(title: menuOptions.agenda.title, storyboardId: menuOptions.agenda.storyboardId)
            let option3 = MenuOption(title: menuOptions.location.title, storyboardId: menuOptions.location.storyboardId)
            let option4 = MenuOption(title: menuOptions.notifications.title, storyboardId: menuOptions.notifications.storyboardId)
            let option5 = MenuOption(title: menuOptions.sponsors.title, storyboardId: menuOptions.sponsors.storyboardId)
            let option6 = MenuOption(title: menuOptions.contact.title, storyboardId: menuOptions.contact.storyboardId)
//            let option7 = MenuOption(title: menuOptions.chat.title, storyboardId: menuOptions.chat.storyboardId)
            let option8 = MenuOption(title: menuOptions.demo.title, storyboardId: menuOptions.demo.storyboardId)
            _menuOptions = [option1, option2, option3, option4, option5, option6, option8]
        }
        return _menuOptions
    }
}
