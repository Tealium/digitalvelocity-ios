//
//  EventDataStore.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/28/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import Foundation

enum EventDataType: Int {
    case Agenda = 0
    case Attendee
    case Question
    case Sponsors
    case Survey
    case Notifications
}

private let _sharedInstance = EventDataStore()

class EventDataStore {
    
    private var tableDataSources = [ String: AnyObject]()
    
    var favorites : Favorites = Favorites()             // self loading
    var lastPositions : [ String : [ AnyObject ] ] = [ String : [AnyObject]]()
    
    class func sharedInstance() -> EventDataStore {
        return _sharedInstance
    }

    init() {
        
    }
    
    private func stringFromEventType(type:EventDataType) -> String {
        
        switch(type){
        case .Agenda:
            return PARSE_CLASS_KEY_EVENT
        case .Attendee:
            return PARSE_CLASS_KEY_ATTENDEE
        case .Question:
            return PARSE_CLASS_KEY_QUESTION
        case .Sponsors:
            return PARSE_CLASS_KEY_COMPANY
        case .Survey:
            return PARSE_CLASS_KEY_SURVEY
        case .Notifications:
            return PARSE_CLASS_KEY_NOTIFICATION
        }
        
    }
    
    func notificationsDatasource() -> NotificationTableDataSource {
        
        return self.dataSourceForType(.Notifications) as! NotificationTableDataSource
        
    }
    
    func dataSourceForType(type: EventDataType) -> TableDataSource {
        
        let typeString = self.stringFromEventType(type)
        
        print("DataSource Type string: \(typeString)")
        
        // Exception
        if type == .Notifications {
         
            guard let tableDataSource = self.tableDataSources[typeString] as? NotificationTableDataSource else {
                
                TEALLog.log("Starting up new Notifications Table Data Source.")
                
                let notification = NotificationTableDataSource(name: PARSE_CLASS_KEY_NOTIFICATION)
                
                self.tableDataSources[PARSE_CLASS_KEY_NOTIFICATION] = notification
                
                return notification
                
            }
            
            return tableDataSource
            
        }
        
        // All Else
        guard let tableDataSource = self.tableDataSources[typeString] as? ParseTableDataSource else {
            
            let dataSource = ParseTableDataSource(name: typeString)
            
            self.tableDataSources[typeString] = dataSource
            
            TEALLog.log("Starting up new \(typeString) Table Data Source: \(dataSource)")

            return dataSource
            
        }
        
        TEALLog.log("Table Data source retrieved for \(typeString): \(tableDataSource)")
        
        return tableDataSource
    }
    
    func fetchSpecificRecord(className:String, key: String, value:String, completion:(dictionary:[NSObject:AnyObject], error:NSError?)->())->Void{
        
        ph.fetchSpecificRecord(className, key: key, value: value, completion: completion)
        
    }
    
    // MARK: Networking
    
    func loadRemoteDataForType(type:EventDataType, completion:((refreshed:Bool) -> Void)) {
        
        let dataSource = self.dataSourceForType(type)
        
        // Exceptions
        if (type == .Survey){
            self.loadSurveyData(completion)
            return
        }
        
        // All Others
        if dataSource.isLoaded == true {
            completion(refreshed: false)
        } else {
        
            dataSource.refresh { (successful, error) -> () in
                completion(refreshed: true)
            }
        }
    }
    
    private func loadSurveyData(completion:((refreshed:Bool) -> Void)) {
        
        let surveyDatasource = self.dataSourceForType(.Survey)
        let questionDatasource = self.dataSourceForType(.Question)
        
        if surveyDatasource.isLoaded == true {
            
            completion(refreshed: false)
            
        } else {
            
            // refresh pull for questions data first
            questionDatasource.refresh({ (successful, error) -> () in
              
                if successful == false {
                    TEALLog.log("No new question data found. Current questions: \(questionDatasource)")
                }
                
                surveyDatasource.refresh({ (successful, error) -> () in
                

                    
                    completion(refreshed: true)
                
                })
                
            })

        }
    }
    
}