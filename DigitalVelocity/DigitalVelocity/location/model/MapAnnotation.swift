//
//  MapAnnotation.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/20/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

import Foundation
import MapKit
import AddressBook

class MapAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var subtitle: String?
    
    init(coordinate:CLLocationCoordinate2D, title: String, subtitle: String) {
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
    
    func mapItem() -> MKMapItem {
        
        var subtitleString : String = ""
        
        if let s = self.subtitle {
            subtitleString = s
        }
        
        let addressDictionary : [ String: AnyObject] = [String(kABPersonAddressStreetKey): subtitleString]
        
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
}