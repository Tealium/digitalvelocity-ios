//
//  SurveyQuestionCell.swift
//  DigitalVelocity
//
//  Created by Merritt Tidwell on 4/1/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import UIKit


protocol SurveyQuestionCellDelegate {

    func SurveyQuestionCellAnswerTapped(cell:SurveyQuestionCell)
    
}

let SurveyQuestionCellKey_IndexPath = "indexPath"
let SurveyQuestionCellKey_Answer = "answer"

class SurveyQuestionCell: DVBaseTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var option1Button: DownStateButton!
    @IBOutlet weak var option2Button: DownStateButton!
    @IBOutlet weak var option3Button: DownStateButton!
    @IBOutlet weak var option4Button: DownStateButton!
  
    var questionAnswerDictionary = [DownStateButton:String]()
    var surveyDelegate : SurveyQuestionCellDelegate?
    var questionID: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        option1Button?.myAlternateButton = [option2Button, option3Button, option4Button]
        option2Button?.myAlternateButton = [option3Button, option4Button, option1Button]
        option3Button?.myAlternateButton = [option1Button, option2Button, option4Button]
        option4Button?.myAlternateButton = [option1Button, option2Button, option3Button]
        
        option1Button.hidden = true
        option2Button.hidden = true
        option3Button.hidden = true
        option4Button.hidden = true
    
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func setUp(index:NSIndexPath, answersArray: NSArray, preSelectedAnswer:String?){
        
        self.optionalData[SurveyQuestionCellKey_IndexPath] = index
        
        
        let buttonArray: NSMutableArray = [option1Button, option2Button, option3Button, option4Button]
        
        for var i = 0; i < answersArray.count; i++ {
            let answer = answersArray[i] as! String
            let button = buttonArray[i] as! DownStateButton
            
            self.questionAnswerDictionary.addEntriesFrom([button:answer])
            
            if answer == preSelectedAnswer{
                button.selected = true
            }
            
            button.hidden = false
        }
        
        print("Question-Answer dictionary: \(self.questionAnswerDictionary)")
        
        var buttonY: CGFloat = 20
        for var i = 0; i < answersArray.count; i++ {
            print(answersArray[i])
            buttonY = buttonY + 43
            let answerLabel = buildAnswersLabel(buttonY)
            answerLabel.text = answersArray[i] as? String
            self.contentView.addSubview(answerLabel)
        }
    
        
    }
    
    func buildAnswersLabel(height: CGFloat) -> UILabel{
        
        let screen = UIScreen.mainScreen()

        var answerLabel : UILabel = UILabel(frame: CGRectMake(0,0,0,0))

        answerLabel = UILabel(frame: CGRectMake(60, height, screen.bounds.width - 60, 30.0))

        var incrementedTag : Int = 0
        
        incrementedTag += 1
        
        return answerLabel
    }
    
    @IBAction func buttonSelected(sender: DownStateButton) {
        
        guard let answer = self.questionAnswerDictionary[sender ] else {
            TEALLog.log("Survey button selected: no answer associated with button: \(sender) in questionAnswerDictionary: \(self.questionAnswerDictionary)")
            return
        }
        
        guard let delegate = self.surveyDelegate else {
            TEALLog.log("No surveyQuestionCellDelegate to pass button tap back to.")
            return
        }
        
        self.optionalData[SurveyQuestionCellKey_Answer] = answer
        
        delegate.SurveyQuestionCellAnswerTapped(self)
        
     }
}