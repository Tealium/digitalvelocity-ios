//
//  DVTableData.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/25/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//
//  BRIEF: Intermediary between the various table views and the Parse backend

import UIKit

class ParseTableDataSource: TableDataSource {
    
    override func load() {
        self.refresh { (successful, error) -> () in
            // No return
        }
    }
    
    override func refresh(completion:(successful:Bool, error:NSError?) ->())->Void{
        
        ph.categoriesWithCellData(name, ascending:true, completion: { (success, sortedCategories, error) -> () in
            if error != nil{
                TEALLog.log("Problem refreshing: \(error?.localizedDescription)")
            }
            self.sortedCategories = sortedCategories!
            completion(successful: success, error: error)
        })
    }
    
}