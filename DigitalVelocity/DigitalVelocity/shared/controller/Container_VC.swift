//
//  ContainerViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Modified by Jason Koo on 02/12/2015
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
  case BothCollapsed
  case RightPanelExpanded
}

/**
This is the container class to manage to the slideouts and primary center view
*/
class Container_VC: UIViewController {
    var centerNavigationController: NavigationController!
    var centerViewController: Center_VC!
    
    var currentState: SlideOutState = SlideOutState.BothCollapsed {
        didSet {
            let shouldShowShadow = currentState != SlideOutState.BothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    var rightViewController: SidePanel_VC?
    
    let centerPanelExpandedOffset: CGFloat = 120
    
    override func viewDidLoad() {
        super.viewDidLoad()

        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = NavigationController(rootViewController: centerViewController)

        centerNavigationController.menuDelegate = self
        centerNavigationController.delegate = self
        
        centerNavigationController.navigationItem.hidesBackButton = true
        
        centerNavigationController.navigationBar.tintColor      = UIColor.grayColor()
        centerNavigationController.navigationBar.barStyle       = UIBarStyle.Black
        centerNavigationController.navigationBar.translucent    = false
        
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMoveToParentViewController(self)
                
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)) )
        
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    func addRightPanelViewController() {
        if (rightViewController == nil) {
            rightViewController = UIStoryboard.rightViewController()
            addChildSidePanelController(rightViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: SidePanel_VC) {
        sidePanelController.delegate = centerViewController
        
        view.insertSubview(sidePanelController.view, atIndex: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func animateRightPanel(shouldExpand shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = SlideOutState.RightPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: -CGRectGetWidth(centerNavigationController.view.frame) + centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { _ in
                self.currentState = SlideOutState.BothCollapsed
                if let rvc = self.rightViewController{
                    rvc.view.removeFromSuperview()
                    self.rightViewController = nil;
                }
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
//        if (shouldShowShadow) {
//            centerNavigationController.view.layer.shadowOpacity = 0.8
//        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
//        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {

        return UIStatusBarStyle.LightContent
    }

}

// MARK: UINavigationControllerDelegates
extension Container_VC: UINavigationControllerDelegate, NavigationControllerMenuDelegate{
    
    func menuToggleRequested() {
        self.view.endEditing(true)
        toggleRightPanel()
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        
        collapseSidePanels()
    }
}

// MARK: Center_VC Delegate
extension Container_VC: Center_VC_Delegate{
    func toggleRightPanel() {
        let notAlreadyExpanded = (currentState != SlideOutState.RightPanelExpanded)
        
        if notAlreadyExpanded {
            addRightPanelViewController()
        }
        
        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func collapseSidePanels() {
        switch (currentState) {
        case .RightPanelExpanded:
            toggleRightPanel()
        default:
            break
        }
    }
}

// MARK: Gesture recognizer
extension Container_VC: UIGestureRecognizerDelegate{
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        // we could determine whether the user is revealing the left or right panel by looking at the velocity of the gesture. But in the .Changed option, we're going to limit how far right the centerNavigationController can go - as we're not currently using a left side slideout
        
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch(recognizer.state) {
        case .Began:
            if (currentState == .BothCollapsed) {
                // If the user starts panning, and neither panel is visible
                // then show the correct panel based on the pan direction
                
                if (!gestureIsDraggingFromLeftToRight) {
                    addRightPanelViewController()
                }
                
                showShadowForCenterViewController(true)
            }
        case .Changed:
            // If the user is already panning, translate the center view controller's
            // view by the amount that the user has panned
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            
            // limit pan
            let mainScreen = UIScreen.mainScreen()
            if recognizer.view!.frame.origin.x > mainScreen.bounds.origin.x {
                recognizer.view!.center.x = mainScreen.bounds.width * 0.5
            }
            
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            // When the pan ends, check whether the left or right view controller is visible
            if (rightViewController != nil) {
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
                animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }
    
}

// MARK: Convenience
private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func rightViewController() -> SidePanel_VC? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("RightViewController") as? SidePanel_VC
    }
    
    class func centerViewController() -> Center_VC? {
    return mainStoryboard().instantiateViewControllerWithIdentifier("CenterViewController") as? Center_VC
  }
}