//
//  DateDisplayHelper.swift
//  DigitalVelocity
//
//  Created by George Webster on 4/1/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import Foundation

class DateDisplayHelper {

    class func notificationTimeDisplayFromDate(date:NSDate)->String {
        let cal = NSCalendar.currentCalendar()
        let nowComponents = cal.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Weekday], fromDate: date)
        let nowDay = dayOfWeek(nowComponents.weekday)
        let nowHour = String(format:"%.2d",nowComponents.hour)
        let nowMinutes = String(format:"%.2d",nowComponents.minute)
        let timeAsString : String = "\(nowDay) - \(nowHour)\(nowMinutes)"
        return timeAsString
    }
    
    class func dayOfWeek(dayNumber:Int)->String{
        switch(dayNumber){
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return ""
        }
    }
}

