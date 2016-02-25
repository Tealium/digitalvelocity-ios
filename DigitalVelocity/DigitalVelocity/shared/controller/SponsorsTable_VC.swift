//
//  SponsorsTable_VC.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/24/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class SponsorsTable_VC: Table_VC {

    var sponsorCellReuseID: String = "SponsorCell"

    override func viewDidLoad() {
        eventDataType = EventDataType.Sponsors
        super.viewDidLoad()
    }
    
    // MARK: UITableViewDatasource Methods

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let sponsor = cellDataForTableView(tableView, indexPath: indexPath)
        
        if sponsor.title != nil {

            let cell:SponsorCell = tableView.dequeueReusableCellWithIdentifier(sponsorCellReuseID) as! SponsorCell

            configureCell(cell, data: sponsor)

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
        
        if data.url != nil{
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }

        cell.titleLabel.sizeToFit()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        if selectedItemData?.url != nil{
            performSegueWithIdentifier(menuOptions.web.storyboardId, sender: self)
        }
    }
}

