//
//  SurveyDetail_TVC.swift
//  DigitalVelocity
//
//  Created by Merritt Tidwell on 3/30/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import UIKit

class SurveyDetail_TVC: Table_VC {
    
    //TODO: get buttons to be assicated with an answer than save the answer
    // UI feedback on buttons select and unselect
    // get submit to show with questions  (array.count + 1?)
    // save answers when sumbit button is pressed and update check box on original VC

    let QuestionCellReuseID: String = "SurveyQuestionCell"
    let SubmitButtonReuseID: String = "SubmitButtonCell"

    var selectionButton: UIButton = UIButton(frame: CGRectMake(0,0,0,0))
    let screen = UIScreen.mainScreen()
    var titleLabel: UILabel = UILabel(frame: CGRectMake(0,0,0,0))
    
    override func viewDidLoad() {
        
        eventDataType = EventDataType.Question
        super.viewDidLoad()
        setupNavigationItemsForController()
     
        
        if let surveryTitle = surveyCellData()?.title {
            navigationItem.title = surveryTitle
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.filterQuestions()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Clean up not calling on it's own so explicitly calling it here
        self.cleanupItemData()
        super.viewWillDisappear(animated)
    }
   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
   //     let surveyDetail = cellDataForTableView(tableView, indexPath: indexPath)
    
        //NEED A REFERENCE TO DATA SOURCE - arra
    
        
        if  let cell: SubmitButtonCell = tableView.dequeueReusableCellWithIdentifier(SubmitButtonReuseID) as? SubmitButtonCell {
        
//        if surveyDetail.title != nil {
//            
//            let cell:SurveyQuestionCell = tableView.dequeueReusableCellWithIdentifier(QuestionCellReuseID) as! SurveyQuestionCell
//                
//                configureCell(cell, data: surveyDetail)
                return cell
        } else {
            let cell = MessageCell(reuseIdentifier: "blank")
            cell.setupWithMessage("No Content Available")
            return cell
        }
        
    }
    

    
//    func isASurveyQuestion(cellData: CellData) -> Bool {
//        
//        // Display only question data matching the survey's question ids
//        let index = NSIndexPath(forRow: 0, inSection: 0)
//        
//        guard let surveyCellData = self.itemData[index] else {
//            
//            TEALLog.log("Survey cell data missing from survey detail tvc.")
//            
//            return false
//            
//        }
//        
//        guard let questionIds = surveyCellData.data?[ph.keyQuestionIds] as? [String] else {
//        
//            TEALLog.log("Question ids missing from survey data for survey: \(surveyCellData)")
//            
//            return false
//            
//        }
//        
//        for questionId in questionIds {
//            
//            if cellData.objectId == questionId {
//                return true
//            }
//            
//        }
//        
//        // Question is for another survey
//        
//        return false
//        
//    }
      func configureCell(cell:SurveyQuestionCell, data:CellData) {
        
        let question = data.title
        cell.titleLabel.text = question
        
        // For array of answer options to this question
        guard let answersArray = data.data?[ph.keyAnswers] else {
        
            TEALLog.log("No answers available for question: \(question)")
            
            return
        }
        
        TEALLog.log("Answers for question: \(question): \(answersArray)")
    
        for var i = 0; i < answersArray.count; i++ {
            let answerString: String = answersArray[i] as! String
            let height = CGFloat(i*60) + 50
            let answerView: UIView = buildAnswersView(CGRectMake(5, height, screen.bounds.width, 50), answer: answerString)
            answerView.tag = i
            cell.contentView.addSubview(answerView)
        }
    }
    
    func buildAnswersView(frameView : CGRect, answer: String) -> UIView {
       
        let answerLabel = UILabel(frame: CGRectMake(50, 15, 300.0, 40.0))
        answerLabel.backgroundColor = UIColor.redColor()
        answerLabel.text = answer
        
        selectionButton = UIButton(frame: CGRectMake(5, 10, 40, 40))
        selectionButton.setTitle("\u{f118}", forState: UIControlState.Normal)
        selectionButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        selectionButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 40)
        selectionButton.addTarget(self, action: "selectionButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        let answerView: UIView = UIView(frame: frameView)
        answerView.addSubview(selectionButton)
        answerView.addSubview(answerLabel)
        
        return answerView
    }
    
    func selectionButtonPressed() {
        
        selectionButton.setTitle("\u{f207}", forState: UIControlState.Selected)
        selectionButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        selectionButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 40)
    }
    
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        //TODO-// add save functionality, get a reference to the buttons clicked....
    
        
        
    }
    func saveSurveyAnswers(answer: String){
      
        if let survey = surveyCellData(){
           //ToDo
        }
    
        let mydictionary: Dictionary = [answer: "value"]
        NSUserDefaults.standardUserDefaults().setValuesForKeysWithDictionary(mydictionary)
        NSUserDefaults.standardUserDefaults().synchronize()

    }
    
    func surveyCellData()-> CellData? {
        let index = NSIndexPath(forRow: 0, inSection: 0)
        if let cellData = self.itemData[index] {
                return cellData
        }
        return nil
    }
    
    // Filter only for survey questions
    func filterQuestions() {
        
        let index = NSIndexPath(forRow: 0, inSection: 0)
        
        guard let surveyCellData = self.itemData[index] else {
            TEALLog.log("No survey data for survey detail: \(self)")
            return
        }
        
        guard let questionIds = surveyCellData.data?[ph.keyQuestionIds] as? [String] else {
            TEALLog.log("No question ids for survey: \(surveyCellData)")
            return
        }
        
        self.dataSource?.searchTerms = questionIds
        self.refreshLocal()
    }
 
    
}
