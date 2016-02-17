//
//  NotificationsViewController.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/13/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit
import CoreFoundation
import CoreGraphics

class NotificationsViewController: UITableViewController {
    
    let reuseId = "cell"
    var notifications: Array<DVNotification> = []

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getNotifications()
    }
    
    func getNotifications(){
        DataStore.sharedInstance.notifications { (array, error) -> Void in
            self.notifications = array
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: indexPath) as NotificationCell
//        let notification = notifications[indexPath.row] as DVNotification
//        cell.configureCell(notification)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}

class NotificationCell: UITableViewCell{
    
    func configureCell(notification:DVNotification){
        self.textLabel?.textColor = UIColor.whiteColor()
        self.textLabel?.text = notification.title
        
        // convert timestamp to something more pleasant
        let formatter = NSDateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("ddd - HH:MM")
        self.detailTextLabel?.text = formatter.stringFromDate(notification.date)
    }
}