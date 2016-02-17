//
//  MapContainerView.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/19/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit
import MapKit

class MapContainerView: UIView, MKMapViewDelegate {

    var mapView:MKMapView
    
    var locationData:LocationDataMap? {

        didSet {

            update()
        }
    }
    
    let spanDelta = 0.01
    
    override var frame: CGRect {
        didSet {
            mapView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))
        }
    }

    override init(frame: CGRect) {
        

        let mapFrame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))

        self.mapView = MKMapView(frame: mapFrame)
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: frame)
        
        self.mapView.delegate = self

        
        addSubview(self.mapView)
        
        let viewsDictionary = ["mapView": self.mapView]
        
        let hConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[mapView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        self.addConstraints(hConstraint)
        
        let vConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        self.addConstraints(vConstraint)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
    
        if let data = locationData {

            updateMapWithData(data)
        }
    }
    
    func updateMapWithData(data:LocationDataMap) {
        
        let location    = coordinateFromLatitude(data.latitude, longitude: data.longitude)
        let span        = MKCoordinateSpanMake(spanDelta, spanDelta)
        let region      = MKCoordinateRegion(center: location, span: span)

        mapView.setRegion(region, animated: true)
        
        if let annotation = self.annotationFor(data){
        
            mapView.selectAnnotation(annotation, animated: true)
            
        }
    }
    
    func annotationFor(data:LocationDataMap)->MapAnnotation? {
        for annotation in mapView.annotations {
            if let ma = annotation as? MapAnnotation {
                if ma.title == data.title {
                    return ma
                }
            }
        }
        return nil
    }
    
    func coordinateFromLatitude(latitude:Double, longitude:Double) -> CLLocationCoordinate2D {

        let lat     = CLLocationDegrees(latitude)
        let long    = CLLocationDegrees(longitude)
        
        return CLLocationCoordinate2DMake(lat, long)
    }
    
    func updateMapAnnotationsWithData(data:Array<LocationDataMap>) {

        for map:LocationDataMap in data {
    
            let location    = coordinateFromLatitude(map.latitude, longitude: map.longitude)
            let annotation  = MapAnnotation(coordinate: location, title: map.title, subtitle: map.subtitle)
            
            
            mapView.addAnnotation(annotation)
        }
    }

    // MARK: MAPVIEW DELEGATE
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? MapAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                calloutAccessoryControlTapped control: UIControl) {
            let location = view.annotation as! MapAnnotation
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
}
