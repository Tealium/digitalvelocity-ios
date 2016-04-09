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
    override func viewDidLoad() {
        
        eventDataType = EventDataType.Survey
        super.viewDidLoad()
        setupNavigationItemsForController()
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
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
        
        if (isSurveyCompleted(data) == true){
            cell.updateIconWithFontAwesome(unicode: "f046")
        } else {
            cell.updateIconWithFontAwesome(unicode: "f096")
        }
        
    }
    
    func isSurveyCompleted(data:CellData) -> Bool {
        
        let answers = surveyAnswers(data)
        
        if answers.count == 0 {
            return false
        }
        
        return true
        
    }
  
    // MARK:
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
            
            detail.surveyCellData = selectedItemData
            
        }
    }
    
//MARK:
//MARK: PERSISTENCE

    func surveyAnswers(data:CellData) -> [String: String]{
        
        guard let surveyID = data.objectId else{
            return [:]
        }
      
        guard let dictionary = NSUserDefaults.standardUserDefaults().objectForKey(SAVED_SURVEY_ANSWER_KEY)?.objectForKey(surveyID) else {
            return [:]
        }
        
        return dictionary as! [ String : String]

    }
}

