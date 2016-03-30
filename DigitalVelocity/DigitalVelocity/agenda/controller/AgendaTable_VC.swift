//
//  AgendaTable_VC.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/24/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

class AgendaTable_VC: Table_VC {

    var agendaImageCellReuseID: String = "AgendaImageCell"
    var agendaFontAwesomeCellReuseID: String = "AgendaFontAwesomeCell"
    
    override func viewDidLoad() {
        eventDataType = EventDataType.Agenda
        super.viewDidLoad()

        // HACK:
        // TODO: this should load inside a callback after parse loads .. so add a call back to the parse loader or put back in the old callbacks
        EventLocationStore.sharedInstance().loadRemoteData(){ }

        setupNavigationItemsForController()
        
        if let navigationController = self.navigationController as? NavigationController{
            navigationController.filterDelegate = self
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let agenda = cellDataForTableView(tableView, indexPath: indexPath)
        
        if agenda.title != nil {
            
            if agenda.fontAwesomeValue != nil {
                let cell:AgendaFontAwesomeCell = tableView.dequeueReusableCellWithIdentifier(agendaFontAwesomeCellReuseID) as! AgendaFontAwesomeCell
                
                configureCell(cell, data: agenda)
                return cell
                
            } else {
                let cell:AgendaImageCell = tableView.dequeueReusableCellWithIdentifier(agendaImageCellReuseID) as! AgendaImageCell

                configureCell(cell, data: agenda)
                
                return cell
            }
            
        } else if indexPath.section == 0 && indexPath.row == 0{
            let cell = MessageCell(reuseIdentifier: "blank")
            cell.setupWithMessage("No Content Available")
            return cell
        }
        return DVBaseTableViewCell()
    }

    func configureCell(cell:AgendaBaseCell, data:CellData) {
        
        cell.titleLabel.text = data.title
        cell.subtitleLabel.text = data.locationInfoString()
        
        if cell.cellType == AgendaCellType.Image {
        
            let imageCell = cell as! AgendaImageCell
            imageCell.iconView.image = UIImage(data: data.imageData)
            
        
        } else if let fontAwesome = data.fontAwesomeValue {

            let faCell = cell as! AgendaFontAwesomeCell
            faCell.updateIconWithFontAwesome(unicode: fontAwesome)
        }
        
        // Favorite handling
        cell.updateFavoriteStatus(data.isLocalFavorite())
        
        cell.delegate = self

        if data.locationId != nil{
            cell.addMapAccessoryIcon()
        } else {
            cell.removeMapAccessoryIcon()
        }

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let data = selectedItemData?.cellTrackingData([ String : AnyObject]())
        Analytics.track("agenda_selected", isView: false, data: data)
        
            if selectedItemData?.fontAwesomeValue != nil {
                performSegueWithIdentifier(menuOptions.agendaDetailIconLabel.storyboardId, sender: self)
            } else {
                performSegueWithIdentifier(menuOptions.agendaDetailImage.storyboardId, sender: self)
            }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let segueID = segue.identifier {
            
            switch segueID {
                
            case menuOptions.location.storyboardId:
                
                if let map = segue.destinationViewController as? EventLocation_VC {
                    if let target = selectedItemData?.locationId {
                        map.currentLocationID = target
                    }
                }
            case menuOptions.agendaDetailImage.storyboardId:
                
                if let detail = segue.destinationViewController as? AgendaItemImageDetail_VC {
                    detail.itemData = selectedItemData
                }
            case menuOptions.agendaDetailIconLabel.storyboardId:
                
                if let detail = segue.destinationViewController as? AgendaItemFontAwesomeDetail_VC {
                    detail.itemData = selectedItemData
                }
            default:
                
                super.prepareForSegue(segue, sender: sender)
            }
        }
    }
    
    func scrollToTop(){
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }

}

extension AgendaTable_VC: NavigationControllerFilterDelegate{
    func filterOn() {
        TEALLog.log("Filtering on")
        self.saveLastPosition()
        self.dataSource?.searchTerm = "_favorites"
        self.refreshLocal()
        self.scrollToTop()
    }
    
    func filterOff() {
        TEALLog.log("Filtering off")
        self.dataSource?.searchTerm = ""
        
        let cellData = CellData()
      
        guard let _ : String =  cellData.title else{
            TEALLog.log("cell data has no title")
            return
        }
        
        
        self.refreshLocal()
        self.restoreLastPosition()
    }
}
