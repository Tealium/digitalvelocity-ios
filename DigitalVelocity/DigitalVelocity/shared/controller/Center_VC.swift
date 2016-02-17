//
//  CenterViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Modified by Jason Koo on 02/12/2015
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit

@objc
protocol Center_VC_Delegate {
  optional func toggleRightPanel()
  optional func collapseSidePanels()
}

class Center_VC: Welcome_Web_VC {

    var delegate: Center_VC_Delegate?
    var selectedOption : MenuOption?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        setupMenuNavigationForController()

        menuOptionSelected(MenuOption.allOptions()[0])
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC: AnyObject = segue.destinationViewController
        if let navItem = destinationVC.navigationItem {
            navItem.hidesBackButton = true
            if let so = selectedOption{
                navItem.title = so.title
            }
        }
    }

}

// MARK: SidePanel Delegate
extension Center_VC: SidePanel_VC_Delegate{
    func menuOptionSelected(menuOption: MenuOption){
    
        delegate?.collapseSidePanels?()
        
        // Welcome
        if menuOption.storyboardId == menuOptions.welcome.storyboardId{
            self.navigationController?.popToRootViewControllerAnimated(true)

            Analytics.track("Welcome", isView: true, data: nil)
            
            return
        }
        
        // Chat
        if menuOption.storyboardId == menuOptions.chat.storyboardId{
            if  User.sharedInstance.isPresenter(){
                loadCustomPresenterChatView()
            } else {
                loadCustomChatView()
            }
            return
        }
        
        // Other Primary menu navigation
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let targetVC = mainStoryboard.instantiateViewControllerWithIdentifier(menuOption.storyboardId) as UIViewController
        
        targetVC.navigationItem.hidesBackButton = true
        self.selectedOption = menuOption
        self.performSegueWithIdentifier(menuOption.storyboardId, sender: self)
        
    }
    
    
    func loadCustomPresenterChatView () {
        
        // TODO: replace with new chat system
    }

    
    func loadCustomChatView () {
        
        // TODO: replace with new chat system
        
    }
    
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

class FadeSegue: UIStoryboardSegue {
    
    override func perform() {
        let sourceVC = self.sourceViewController 
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        let navC: UINavigationController = sourceVC.navigationController!
        navC.view.layer.addAnimation(transition, forKey: kCATransition)
        navC.popToRootViewControllerAnimated(false)
        navC.pushViewController(destinationViewController , animated: false)

    }
}