//
//  TEALLog.swift
//  iBeaconTest
//
//  Created by Jason Koo on 1/28/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import Foundation

var canLog = true

/**
 Convenience logger that can entirely shut down by changing the canLog property
 */
class TEALLog {
    
    class func enableLogs(canEnable: Bool) {

        canLog = canEnable
    
    }
    
    class func logError(error: NSError?,
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int = __LINE__) {
            

            if let error = error {
                
                if (canLog){
                    print("[Function:\(function), line \(line)] \(error.localizedDescription) - \(error.localizedFailureReason) - \(error.localizedRecoverySuggestion))")
                }
                
            }
    }
    
    class func log(message: String,
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int = __LINE__) {
            
            if (canLog){
                print("[Function:\(function), line \(line)] \(message)")
            }
    }
}