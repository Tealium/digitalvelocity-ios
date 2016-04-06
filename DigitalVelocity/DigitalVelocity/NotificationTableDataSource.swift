//
//  DVTableData.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/25/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//
//  BRIEF: Intermediary between the various table views and the Parse backend

import UIKit

class NotificationTableDataSource: TableDataSource {
    
    var notifications : Notifications = Notifications()
    
    override func forceRefresh(completion: (successful: Bool, error: NSError?) -> ()) {
        
        self.refresh(completion)
        
    }
    
    override func refresh(completion:(successful:Bool, error:NSError?) ->())->Void{
        let na = notifications.all()
        if na.isEmpty{
            self.sortedCategories = [Category]()
            TEALLog.log("No prior saved notifications")
        } else {
            self.sortedCategories = convertNotificationsToCategories(na)
        }
        isLoaded = true
        completion(successful: true, error: nil)
    }
    
    func convertNotificationsToCategories(notifications: [Notification])->[Category]{
        // Take notifications and create simple [Category] for self.categories
        
        let newCat = Category()
        newCat.cellDataSortAscending = false
        var newCells = [CellData]()

        for index in (notifications.count-1).stride(through: 0, by: -1){
            let newCellData = CellData()
            let notification = notifications[index]
            newCellData.title = String(notification.message)
            newCellData.startDate = notification.timestamp
            newCells.append(newCellData)
        }
        
        newCat.cellData = newCells
        
        var catArray = [Category]()
        catArray.append(newCat)
        return catArray
    }
    
}