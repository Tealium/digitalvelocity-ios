//
//  DigitalVelocityUITests.swift
//  DigitalVelocityUITests
//
//  Created by Merritt Tidwell on 3/7/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

import XCTest

class DigitalVelocityUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testButtons(){
        let app = XCUIApplication.init()
 
        app.buttons["Menu Button"].tap()
        
    
        //swipes a tableview
        app.tables.staticTexts["Agenda"].tap()
        let tableQuery = app.tables
        let table = tableQuery.element
        let lastCell = table.cells.elementBoundByIndex(table.cells.count-1)
        table.scrollToElement(lastCell)
        
        app.tables.cells.elementBoundByIndex(table.cells.count-1).tap()
        
        app.buttons["Favorite Button"].tap()
                
        let start = app.coordinateWithNormalizedOffset(CGVectorMake(0, 0))
        start.pressForDuration(2)
        
        app.tables.cells.elementBoundByIndex(4).buttons["Map Icon"].tap()
        
        start.pressForDuration(2)
        
        app.buttons["Filter Button"].tap()

        
        //need a way to access segmented controls
        app.buttons["Menu Button"].tap()
        app.tables.staticTexts["Event Location"].tap()

        app.buttons["Menu Button"].tap()
        app.tables.staticTexts["Sponsors"].tap()
        app.tables.cells.elementBoundByIndex(table.cells.count-1).tap()
        start.pressForDuration(2)

        app.buttons["Menu Button"].tap()
        app.tables.staticTexts["Contact"].tap()
        
        app.buttons["Menu Button"].tap()
        app.tables.staticTexts["Demo"].tap()
        
        let accountTextField = app.textFields["Account Text Field"]
        accountTextField.clearAndEnterText("testaccount")
        
        
        let profileTextField = app.textFields["Profile Text Field"]
        profileTextField.doubleTap()
        profileTextField.clearAndEnterText("testprofile")
        
        let environmetTextField = app.textFields["Environment Text Field"]
        environmetTextField.doubleTap()
        environmetTextField.clearAndEnterText("testenvironment")

        app.buttons["Save Button"].tap()
        
    }

}

extension XCUIElement {
    
    func scrollToElement(element: XCUIElement) {
        while !element.visible() {
            swipeUp()
        }
    }
        func visible() -> Bool {
        guard self.exists && !CGRectIsEmpty(self.frame) else { return false }
        return CGRectContainsRect(XCUIApplication().windows.elementBoundByIndex(0).frame, self.frame)
    }
    
}

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) -> Void {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        
        var deleteString: String = ""
        for _ in stringValue.characters {
            deleteString += "\u{8}"
        }
        self.typeText(deleteString)
        
        self.typeText(text)
    }
}
