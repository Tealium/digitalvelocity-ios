//
//  SurveyDetail_TVC.swift
//  DigitalVelocity
//
//  Created by Merritt Tidwell on 3/30/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import UIKit

class SurveyDetail_TVC: Table_VC {

    let QuestionCellReuseID: String = "SurveyQuestionCell"
    
    override func viewDidLoad() {
        
        eventDataType = EventDataType.Question
        super.viewDidLoad()
        
        setupNavigationItemsForController()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Clean up not calling on it's own so explicitly calling it here
        self.cleanupItemData()
        super.viewWillDisappear(animated)
    }
   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let surveyDetail = cellDataForTableView(tableView, indexPath: indexPath)
        
        if surveyDetail.title != nil {
            
            let cell:SurveyQuestionCell = tableView.dequeueReusableCellWithIdentifier(QuestionCellReuseID) as! SurveyQuestionCell
                
                configureCell(cell, data: surveyDetail)
                return cell
        } else {
            let cell = MessageCell(reuseIdentifier: "blank")
            cell.setupWithMessage("No Content Available")
            return cell
        }
        
    }
  
    func configureCell(cell:SurveyQuestionCell, data:CellData) {
    
            cell.titleLabel.text = "test"
      
        }
    
    //To do: pass in answers to questions
    
    func saveSurveyAnswers(answer: String){
        
            let mydictionary: Dictionary = [answer: "value"]
            NSUserDefaults.standardUserDefaults().setValuesForKeysWithDictionary(mydictionary)
        
            NSUserDefaults.standardUserDefaults().synchronize()

    }
    
}
