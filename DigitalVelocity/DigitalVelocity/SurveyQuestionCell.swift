//
//  SurveyQuestionCell.swift
//  DigitalVelocity
//
//  Created by Merritt Tidwell on 4/1/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import UIKit

class SurveyQuestionCell: DVBaseTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var option1Button: DownStateButton!
    @IBOutlet weak var option2Button: DownStateButton!
    @IBOutlet weak var option3Button: DownStateButton!
    @IBOutlet weak var option4Button: DownStateButton!
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        option1Button?.myAlternateButton = [option2Button, option3Button, option4Button]
        option2Button?.myAlternateButton = [option3Button, option4Button, option1Button]
        option3Button?.myAlternateButton = [option1Button, option2Button, option4Button]
        option4Button?.myAlternateButton = [option1Button, option2Button, option3Button]

        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func setUp(answerArray: NSArray){
        
        var dictionary = [DownStateButton: String]()
        let buttonArray: NSMutableArray = [option1Button, option2Button, option3Button, option4Button]
        for var i = 0; i < answerArray.count; i++ {
            dictionary.addEntriesFrom([buttonArray[i] as! DownStateButton: answerArray[i] as! String] )
        }
        print(dictionary)
    }
    
    @IBAction func buttonSelected(sender: AnyObject) {
        
     }
}