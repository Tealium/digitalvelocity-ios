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
    // save answers when sumbit button is pressed and update check box on original VC

   
    let QuestionCellReuseID: String = "SurveyQuestionCell"
    let SubmitButtonReuseID: String = "SubmitButtonCell"
    var numOfElements: Int = 0
    var selectionButton: DownStateButton!
//    let screen = UIScreen.mainScreen()
    var titleLabel: UILabel = UILabel(frame: CGRectMake(0,0,0,0))
    var selectedAnswer: String = ""
//    var answerLabel : UILabel = UILabel(frame: CGRectMake(0,0,0,0))
    var questionID: String = ""
    var answerDictionary = [NSIndexPath : AnyObject]() //questionID : selectedAnswer
    
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
        let cell = MessageCell(reuseIdentifier: "blank")
        if indexPath.row == numOfElements {
            if let cell: SubmitButtonCell = tableView.dequeueReusableCellWithIdentifier(SubmitButtonReuseID) as? SubmitButtonCell {
            return cell
            }
        }else{
       let surveyDetail = cellDataForTableView(tableView, indexPath: indexPath)
            if surveyDetail.title != nil {
            
            let cell:SurveyQuestionCell = tableView.dequeueReusableCellWithIdentifier(QuestionCellReuseID) as! SurveyQuestionCell
                
                configureCell(cell, data: surveyDetail, indexPath: indexPath)
                cell.surveyDelegate = self
                return cell
            }
        }
        return cell
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         numOfElements = (dataSource?.numberOfRows(section))!
        
            return numOfElements + 1
        
    }
    
    
    func configureCell(cell:SurveyQuestionCell, data:CellData, indexPath:NSIndexPath) {
        
        let question = data.title
        cell.titleLabel.text = question
        
        
        // For array of answer options to this question
        guard let answersArray = data.data?[ph.keyAnswers] as? NSArray else {
            
            TEALLog.log("No answers available for question: \(question)")
            
            return
        }
        
        TEALLog.log("Answers for question: \(question): \(answersArray)")

        cell.setUp(indexPath, answersArray: answersArray)
        
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        
        for (key,value) in answerDictionary {
            executeTrackCall(value as! String, indexForCell: key )
        }
    
    }
    
    func constructDictionary (questionID: Int , answerChoosen: String)-> NSDictionary{
        var dict = [questionID: answerChoosen]
        return dict
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
 
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == numOfElements { //submit button height
            return 90
        }else{
            return 240.0
        }
    }

    func executeTrackCall(answer: String, indexForCell : NSIndexPath){
        
    }
}

extension SurveyDetail_TVC : SurveyQuestionCellDelegate {
    
    func SurveyQuestionCellAnswerTapped(cell: SurveyQuestionCell) {
        
        TEALLog.log("Survey cell answer tapped: \(cell.optionalData)")
        print(cell.optionalData[SurveyQuestionCellKey_Answer])
        guard let index = cell.optionalData[SurveyQuestionCellKey_IndexPath] as? NSIndexPath else{
            TEALLog.log("index path missing for survey question cell")
            return
        }
        
        guard let answer = cell.optionalData[SurveyQuestionCellKey_Answer] as? String else{
            TEALLog.log("answer missing for survey question cell")
            return
        }
        
        answerDictionary[index] = answer
        
    }
}