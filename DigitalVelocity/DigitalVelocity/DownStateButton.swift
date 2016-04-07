//
//  DownStateButton.swift
//  DigitalVelocity
//
//  Created by Merritt Tidwell on 4/7/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import UIKit

class DownStateButton : UIButton {
    
    var myAlternateButton:Array<DownStateButton>?
    
    var downStateImage:String? = "weapon.png"{
        
        didSet{
            
            if downStateImage != nil {
                
                self.setImage(UIImage(named: downStateImage!), forState: UIControlState.Selected)
            }
        }
    }
    
    func unselectAlternateButtons(){
        
        if myAlternateButton != nil {
            
            self.selected = true
            
            for aButton:DownStateButton in myAlternateButton! {
                
                aButton.selected = false
            }
            
        }else{
            
            toggleButton()
        }
    }
    
    override func touchesBegan (touches:Set<UITouch>, withEvent event:UIEvent?){
        
        unselectAlternateButtons()
        super.touchesBegan(touches, withEvent: event)
    }
    
    func toggleButton(){
        
        if self.selected==false{
            
            self.selected = true
        }else {
            
            self.selected = false
        }
    }
}

