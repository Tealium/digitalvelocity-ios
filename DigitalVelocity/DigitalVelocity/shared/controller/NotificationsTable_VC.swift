//
//  NotificationsTable_VC.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/24/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import Foundation


class NotificationsTable_VC: Table_VC {
    
    override func viewDidLoad() {
        eventDataType = EventDataType.Notifications
        super.viewDidLoad()
    }
    
    // TODO: Remove once callback to eventDataStore working
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        store.notificationsDatasource.notifications.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
//    func sendTestParseNotification(){
//        let userInfo = [ "aps" : [ "alert" : "testMessage"]]
//        Push.sharedInstance().didRecieveRemoteNotification(userInfo)
//    }
    
    override func saveLastPosition() {
        // Do nothing
    }
    
    override func restoreLastPosition() {
        // Do nothing - causes crash with Notifications
    }

    // MARK: UITableViewDatasource Methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if let cell:DVBaseTableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIDBaseCell) as? DVBaseTableViewCell {
            
            let notification = cellDataForTableView(tableView, indexPath: indexPath)

            if notification.title != nil && notification.title != ""{
                cell.textLabel?.text = notification.title
                cell.detailTextLabel?.text = notification.timeReceivedString()
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.delegate = self

            return cell
        } else {
            return UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "blank")
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
        
    }

}

extension NotificationsTable_VC : NotificationsDelegate{
    func notificationWasRecieved() {
        refresh()
    }
}
