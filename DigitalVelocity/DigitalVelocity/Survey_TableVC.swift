//
//  Survey_TableVC.swift
//  DigitalVelocity
//
//  Created by Merritt Tidwell on 3/29/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import UIKit

class SurveyTable_VC: Table_VC {
    
    let surveyReuseID: String = "SurveyCell"
    var isSurveyCompleted = false
    override func viewDidLoad() {
        
        eventDataType = EventDataType.Survey
        super.viewDidLoad()
        setupNavigationItemsForController()
        isSurveyCompleted = true
    
    }
   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let survey = cellDataForTableView(tableView, indexPath: indexPath)
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
        cell.questionID = data.objectId
        
        if (isSurveyCompleted == true){
            cell.updateIconWithFontAwesome(unicode: "f046")
        }
        cell.updateIconWithFontAwesome(unicode: "f096")
        
    }
  
    // MARK: HELPERS
    func surveyCellData()-> CellData? {
        let index = NSIndexPath(forRow: 0, inSection: 0)
        if let cellData = self.itemData[index] {
            return cellData
        }
        return nil
    }

  
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        guard let _ = selectedItemData?.data else  {

            TEALLog.log("No survey detail data associated with cell at index: \(indexPath)")
            
            return
        }
        
        performSegueWithIdentifier(menuOptions.surveyDetail.storyboardId, sender: self)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let selectedItemData = selectedItemData else {
            
            TEALLog.log("No survey detail data associated with cell tapped.")
            
            return
        }
        
        // Need to format detail cell data into <indexpath, cellData> for detail view
        
        if let detail = segue.destinationViewController as? SurveyDetail_TVC{
            
            detail.itemData = [ NSIndexPath.init(forRow: 0, inSection: 0) : selectedItemData]
        }
    }
//MARK
//Persistence
    let savedSurveyAnswerKey = "com.digitalvelocity.surveyanswers"

    func loadSurveyAnswers() -> [String: String]{
        guard let surveyID = self.surveyCellData()?.objectId else{
            return [:]
        }
      
        if let dictionary = NSUserDefaults.standardUserDefaults().objectForKey(savedSurveyAnswerKey)?.objectForKey(surveyID) {
            isSurveyCompleted = true
            return dictionary as! [String: String]
        }
        return [:]
    }
}

