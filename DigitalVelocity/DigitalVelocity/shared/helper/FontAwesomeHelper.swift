//
//  FontAwesomeHelper.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/29/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import Foundation

var uiFontAwesomeSize16 : UIFont?
var fontAwesomes : [Double : UIFont] = [Double: UIFont]()

class FontAwesomeHelper {

    // TODO: Consider using an NSCache instead
    class func fontAwesomeForSize(size : Double)-> UIFont{
        if let font = fontAwesomes[size]{
            return font
        } else {
            let sizeCG : CGFloat = CGFloat(size)
            let newFont = UIFont(name: "fontAwesome", size: sizeCG)
            fontAwesomes[size] = newFont
            return newFont!
        }
    }
    
    class func labelStringFromFontAwesome(unicode unicode: String) -> String {
        
        let scanner = NSScanner(string: unicode)
        
        var _unicode : UInt32 = 0
        
        if scanner.scanHexInt(&_unicode) {
            return "\(UnicodeScalar(_unicode))"
        } else {
            return "\(unicode)"
        }
        
    }
}
