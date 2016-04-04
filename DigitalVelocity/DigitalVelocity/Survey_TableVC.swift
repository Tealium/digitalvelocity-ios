//
//  Survey_TableVC.swift
//  DigitalVelocity
//
//  Created by Merritt Tidwell on 3/29/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import UIKit

class SurveyTable_VC: Table_VC {
    
    var surveyReuseID: String = "SurveyCell"
    
    override func viewDidLoad() {
        eventDataType = EventDataType.Survey
        super.viewDidLoad()

    }
   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let survey = cellDataForTableView(tableView, indexPath: indexPath)
        print(survey)
        if survey.title != nil {
            let cell: SurveyBaseCell  = tableView.dequeueReusableCellWithIdentifier(surveyReuseID) as! SurveyBaseCell
            configureCell(cell, data: survey)
            return cell
        } else{
            let cell = MessageCell(reuseIdentifier: "blank")
            cell.setupWithMessage("No Content Available")
            return cell
        }
    }
    
    func configureCell(cell:SurveyBaseCell, data:CellData) {
        
        cell.titleLabel.text  = data.title
        cell.delegate = self
        cell.titleLabel.sizeToFit()
        cell.updateIconWithFontAwesome(unicode: "f096")
        
    }
  
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let data = selectedItemData?.cellTrackingData([ String : AnyObject]())
        Analytics.track("surveydetail_selected", isView: false, data: data)
    
        performSegueWithIdentifier(menuOptions.surveyDetail.storyboardId, sender: self)
    }
        
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let detail = segue.destinationViewController as? SurveyDetail_TVC{
//           // detail.itemData = selectedItemData
//        }
//    }
}

