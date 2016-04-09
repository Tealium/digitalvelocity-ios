//
//  SponsorsTable_VC.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/24/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit
import MessageUI

class SponsorsTable_VC: Table_VC {

    var sponsorCellReuseID: String = "SponsorCell"

    override func viewDidLoad() {
        eventDataType = EventDataType.Sponsors
        super.viewDidLoad()
    }
    
    // MARK:
    // MARK: UITableViewDatasource Methods

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let sponsor = cellDataForTableView(tableView, indexPath: indexPath)
        
        if sponsor.title != nil {

            let cell:SponsorCell = tableView.dequeueReusableCellWithIdentifier(sponsorCellReuseID) as! SponsorCell

            // TODO: unify this setup
            configureCell(cell, data: sponsor)
            cell.setup(indexPath)
            
            return cell
        } else {
            let cell = MessageCell(reuseIdentifier: "blank")
            cell.setupWithMessage("No Content Available")
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
        
    }

    func configureCell(cell:SponsorCell, data:CellData) {

        cell.titleLabel.text    = data.title
        cell.subtitleLabel.text = data.subtitle
        cell.iconView.image     = UIImage(data: data.imageData)
        cell.delegate = self
        cell.sponsorDelegate = self
        
        if data.url != nil{
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }

        cell.titleLabel.sizeToFit()
        
        // If no email data we're going to hide the request demo button
        if let email = data.data[ph.keyEmail] as? String where email != ""{
            cell.requestDemoButton.hidden = false
        } else {
            cell.requestDemoButton.hidden = true
        }

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        if selectedItemData?.url != nil{
            performSegueWithIdentifier(menuOptions.web.storyboardId, sender: self)
            
        }
    }
    
    func openEmail(email:String, header:String?, message:String?){
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            
            if let header = header {
                mail.setSubject(header)
            }
            
            if let message = message {
                mail.setMessageBody(message, isHTML: false)
            }
            
            presentViewController(mail, animated: true, completion: nil)
        } else {
            // show failure alert
            TEALLog.log("MFMailComposer can not send mail.")
        }
        
    }
}

// MARK:
// MARK: DELEGATES
extension SponsorsTable_VC : SponsorCellDelegate {
    
    func sponsorCellDemoRequested(index: NSIndexPath) {
        
        let cellData = cellDataForTableView(self.tableView, indexPath: index)
        
        // Pass the email info to the button cell
        guard let email = cellData.data[ph.keyEmail] as? String else {
            TEALLog.log("Email address missing from demo requested data: \(cellData)")
            return
        }
        
        self.openEmail(email, header:cellData.data[ph.keyEmailHeader] as? String, message: cellData.data[ph.keyEmailMessage] as? String)
        
    }
    
}

extension SponsorsTable_VC : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        controller.dismissViewControllerAnimated(true, completion: nil)

        
    }
}