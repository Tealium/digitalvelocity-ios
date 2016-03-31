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
    case Sponsors
    case Survey
    case Notifications
}

private let _sharedInstance = EventDataStore()

class EventDataStore {
    
    private var agendaDatasource = ParseTableDataSource(name: "Event")
    private var attendeeDatasource = ParseTableDataSource(name: "Attendee")
    private var sponsorDatasource = ParseTableDataSource(name: "Company")
    private var surveyDatasource = ParseTableDataSource(name: "Survey")
    
    var notificationsDatasource = NotificationTableDataSource(name: "Notification")
    var favorites : Favorites = Favorites()             // self loading
    var lastPositions : [ String : [ AnyObject ] ] = [ String : [AnyObject]]()

    private var isAgendaLoaded = false
    private var isAttendeeLoaded = false
    private var isSponsorsLoaded = false
    private var isSurveyLoaded = false
    private var isNotificationsLoaded = false
    
    class func sharedInstance() -> EventDataStore {
        return _sharedInstance
    }

    init() {
        
    }
    
    
    // MARK: Networking
    
    func loadRemoteData() {
        
        // TODO: Re-enable these closures        
//        loadRemoteDataForType(EventDataType.Agenda){ (refreshed) -> () in }
//        loadRemoteDataForType(EventDataType.Notifications){ (refreshed) -> () in }
//        loadRemoteDataForType(EventDataType.Sponsors){ (refreshed) -> () in }
    }

    func loadRemoteDataForType(type:EventDataType, completion:((refreshed:Bool) -> Void)) {

        switch(type) {
            
        case .Agenda:
            loadAgendaData(completion)
        case .Attendee:
            loadAttendeeData(completion)
        case .Sponsors:
            loadSponsorData(completion)
        case .Survey:
            loadSurveyData(completion)
        case .Notifications:
            loadNotificationData(completion)
        }
    }

    private func loadAgendaData(completion:((refreshed:Bool) -> Void)) {
        
        if isAgendaLoaded {
            completion(refreshed: false)
        } else {
            agendaDatasource.refresh { (successful, error) -> () in
                self.isAgendaLoaded = successful
                completion(refreshed: true)
            }
        }
    }
    
    private func loadAttendeeData(completion:((refreshed: Bool) -> Void)) {
        
        if isAttendeeLoaded {
            completion(refreshed: false)
        } else {
            // TODO
        }
        
        
    }

    private func loadSponsorData(completion:((refreshed:Bool) -> Void)) {
        
        if isSponsorsLoaded {
            completion(refreshed: false)
        } else {
            sponsorDatasource.refresh { (successful, error) -> () in
                self.isSponsorsLoaded = successful
                completion(refreshed: true)
            }
        }
    }
    
    private func loadSurveyData(completion:((refreshed:Bool) -> Void)) {
        
        if isSurveyLoaded {
            completion(refreshed: false)
        } else {
            surveyDatasource.refresh({ (successful, error) -> () in
                self.isSurveyLoaded = true
                completion(refreshed: true)
            })
        }
    }

    private func loadNotificationData(completion:((refreshed:Bool) -> Void)) {
        
        if isNotificationsLoaded {
            completion(refreshed: false)
        } else {
            notificationsDatasource.refresh { (successful, error) -> () in
                self.isNotificationsLoaded = true
                completion(refreshed: true)
            }
        }
    }

    func isDatasourceLoadedForType(type:EventDataType) -> Bool {
        
        switch(type) {
            
        case .Agenda:
            return isAgendaLoaded
        case .Attendee:
            return isAttendeeLoaded
        case .Sponsors:
            return isSponsorsLoaded
        case .Survey:
            return isSurveyLoaded
        case .Notifications:
            return isNotificationsLoaded
        }
    }
    
    func datasourceForType(type:EventDataType) -> TableDataSource {

        switch(type) {
            
        case .Agenda:
            return agendaDatasource
        case .Attendee:
            return attendeeDatasource
        case .Sponsors:
            return sponsorDatasource
        case .Survey:
            return surveyDatasource
        case .Notifications:
            return notificationsDatasource
        }
    }
}