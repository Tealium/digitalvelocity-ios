//
//  SurveyDetail_TVC.swift
//  DigitalVelocity
//
//  Created by Merritt Tidwell on 3/30/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import UIKit

class SurveyDetail_TVC: Table_VC {
    
    // TODO: save answers when sumbit button is pressed and update check box on original VC

    let QuestionCellReuseID: String = "SurveyQuestionCell"
    let SubmitButtonReuseID: String = "SubmitButtonCell"
    var numOfElements: Int = 0
    var answerDictionary = [NSIndexPath : AnyObject]() //questionID : selectedAnswer
    var indexPathLastRow = NSIndexPath(forRow: 0, inSection: 0)
    var savedSurveyData = [String: String]()
    
    // MARK:
    // MARK: LIFECYCLE
    
    override func viewDidLoad() {
        
        eventDataType = EventDataType.Question
        super.viewDidLoad()
        setupNavigationItemsForController()
     
    //    self.savedSurveyData = self.loadSurveyAnswers()

        if let surveryTitle = surveyCellData()?.title {
            navigationItem.title = surveryTitle
        }
     
       self.refreshControl = nil
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
    
   
    // MARK:
    // MARK: TABLEVIEW DELEGATE
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == indexPathLastRow { //submit button height
            return 90
        }
        else{
            return 240.0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
  
        let cell = MessageCell(reuseIdentifier: "blank")

        let lastSectionIndex : NSInteger = tableView.numberOfSections - 1
        let lastRowIndex: NSInteger = tableView.numberOfRowsInSection(lastSectionIndex) - 1
        indexPathLastRow = NSIndexPath(forRow: lastRowIndex, inSection: lastSectionIndex)
        
        if(indexPath.section == lastSectionIndex) {
            if let cell: SubmitButtonCell = tableView.dequeueReusableCellWithIdentifier(SubmitButtonReuseID) as? SubmitButtonCell {
            return cell
            }
        }else{
       let questionCellData = cellDataForTableView(tableView, indexPath: indexPath)
            if questionCellData.title != nil {
            
            let cell:SurveyQuestionCell = tableView.dequeueReusableCellWithIdentifier(QuestionCellReuseID) as! SurveyQuestionCell
                
                configureCell(cell, data: questionCellData, indexPath: indexPath)
                cell.surveyDelegate = self
                return cell
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numOfElements = (dataSource?.numberOfRows(section))!
        return numOfElements
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let numOfElements = dataSource?.numberOfSections() else{
            return 0
        }
        return numOfElements + 1
    }
    
    func configureCell(cell:SurveyQuestionCell, data:CellData, indexPath:NSIndexPath) {
        
        let question = data.title
        cell.titleLabel.text = question
        cell.questionID = data.objectId
        
        // For array of answer options to this question
        guard let answersArray = data.data[ph.keyAnswers] as? NSArray else {
            TEALLog.log("No answers available for question: \(question)")
            return
        }
        
        TEALLog.log("Answers for question: \(question): \(answersArray)")
        
        let preselectedAnswer = self.loadSurveyAnswers()[cell.questionID]
       
        cell.setUp(indexPath, answersArray: answersArray, preSelectedAnswer: preselectedAnswer)
    }
    
    // MARK: PERSISTENCE
  
    let savedSurveyAnswerKey = "com.digitalvelocity.surveyanswers"
    
    func saveSurveyAnswers(){
      
        guard let surveyID = self.surveyCellData()?.objectId else{
            return
        }
        let mydictionary: Dictionary = [savedSurveyAnswerKey: [surveyID :self.savedSurveyData]]
        NSUserDefaults.standardUserDefaults().setValuesForKeysWithDictionary(mydictionary)
        NSUserDefaults.standardUserDefaults().synchronize()

    }
    

    func loadSurveyAnswers() -> [String: String]{
        guard let surveyID = self.surveyCellData()?.objectId else{
            return [:]
        }
        
        if let dictionary = NSUserDefaults.standardUserDefaults().objectForKey(savedSurveyAnswerKey)?.objectForKey(surveyID) {
            return dictionary as! [String: String]
        }
        return [:]
    }
 
    // MARK: SUBMIT
    @IBAction func submitButtonPressed(sender: AnyObject) {
        
        for (key,value) in answerDictionary {
            executeTrackCall(value as! String, indexForCell: key )
        }
    
        self.saveSurveyAnswers()
        self.showAlertController()
    }
    
    func showAlertController(){
      
        let alertController = UIAlertController(title: "Congratulations", message: "You have submitted your Survey", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func executeTrackCall(answer: String, indexForCell : NSIndexPath){

        // Keys
        let keySurveyComplete = "survey_complete"
        let keySurveyId = "survey_id"
        let keySurveyTitle = "survey_title"
        let keyQuestionId = "survey_question_id"
        let keyQuestionTitle = "survey_question"
        let keyAnswer = "survey_answer"
        
        // Required Data
        guard let surveyData = surveyCellData() else {
            TEALLog.log("Execute track call ERROR: survey data missing.")
            return
        }
        guard let surveyId = surveyData.objectId else {
            TEALLog.log("Execute track call ERROR: Survey data missing object id.")
            return
        }
        
        let questionCellData = cellDataForTableView(self.tableView, indexPath: indexForCell)
        guard let questionId = questionCellData.objectId else {
            TEALLog.log("Execute track call ERROR: Question id missing.")
            return
        }
        
        
        var data = [ String : String ]()
        data[keySurveyId] = surveyId
        data[keyQuestionId] = questionId
        data[keyAnswer] = answer
        
        
        // Optional data
        if let surveyTitle = surveyData.data[ph.keyTitle] as? String {
            data[keySurveyTitle] = surveyTitle
        } else {
            TEALLog.log("Execute track call ERROR: Survey missing or illformatted title.")
        }
        
        if let questionTitle = questionCellData.title  {
            data[keyQuestionTitle] = questionTitle
        } else {
            TEALLog.log("Execute track call ERROR: Question title missing.")
        }
        
        Analytics.track(keySurveyComplete, isView: false, data: data)
 
    }
    
    // MARK: HELPERS
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
        
        guard let questionIds = surveyCellData.data[ph.keyQuestionIds] as? [String] else {
            TEALLog.log("No question ids for survey: \(surveyCellData)")
            return
        }
        
        self.dataSource?.searchTerms = questionIds
        self.refreshLocal()
    }
}

// MARK:
// MARK: SURVEY QUESTION CELL DELEGATE
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
        
        self.savedSurveyData[cell.questionID] = answer
        
    }

}