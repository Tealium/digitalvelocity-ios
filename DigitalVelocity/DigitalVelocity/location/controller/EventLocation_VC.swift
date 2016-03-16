//
//  EventLocation_VC.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/19/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit
import MapKit

class EventLocation_VC: DVViewController, LayoutContainerViewDatasource {

    @IBOutlet weak var viewTypeControl: UISegmentedControl!
    @IBOutlet weak var locationControl: UISegmentedControl!
    @IBOutlet weak var contentView: UIView!
    
    let locationStore = EventLocationStore.sharedInstance()

    var viewType = EventLocationType.Maps
    var locationIndex:Int = -1
    
    var layoutContainer: LayoutContainerView? = nil
    var mapContainer: MapContainerView? = nil

    var currentLocationID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMenuNavigationForController()
        
        self.viewTypeControl.accessibilityIdentifier = "View Type Control"
        
        // Views
        setupContentViews()

        // Controls
        let image = UIImage(named: "BlackBG.png")
        locationControl.setBackgroundImage(image, forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        viewTypeControl.setBackgroundImage(image, forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)

        // Netowkring
        // TODO: move to app launch
        locationStore.loadRemoteData() {
            
            if let vID = self.currentLocationID {
                let typeAndIndex = self.locationStore.viewTypeAndLocationIndexForLocationID(vID)
                self.viewType = typeAndIndex.viewType
                self.locationIndex = typeAndIndex.locationIndex
            }
            self.transitionToViewType(self.viewType, selectedIndex: self.locationIndex)
            
            self.currentLocationID = nil
        }
        
        
        transitionToViewType(viewType, selectedIndex: locationIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupContentViews() {
        
        layoutContainer = LayoutContainerView(frame: contentView.bounds)
        layoutContainer?.translatesAutoresizingMaskIntoConstraints = false
        layoutContainer?.datasource = self
        
        self.contentView.addSubview(layoutContainer!)
        
        mapContainer = MapContainerView(frame: contentView.bounds)
        mapContainer?.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(mapContainer!)
        
        let layoutViewDictionary : [ String : AnyObject] = ["layoutContainer": layoutContainer!]

        let hConstraintLayout = NSLayoutConstraint.constraintsWithVisualFormat("H:|[layoutContainer]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: layoutViewDictionary)
        self.contentView.addConstraints(hConstraintLayout)
        let vConstraintLayout = NSLayoutConstraint.constraintsWithVisualFormat("V:|[layoutContainer]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: layoutViewDictionary)
        self.contentView.addConstraints(vConstraintLayout)

        let mapViewDictionary : [ String : AnyObject] = ["mapContainer": mapContainer!]

        let hConstraintMap = NSLayoutConstraint.constraintsWithVisualFormat("H:|[mapContainer]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: mapViewDictionary)
        self.contentView.addConstraints(hConstraintMap)
        let vConstraintMap = NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapContainer]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: mapViewDictionary)
        self.contentView.addConstraints(vConstraintMap)

    }

    
    // MARK: - Controls
    
    @IBAction func handleViewTypeChanged(sender: UISegmentedControl) {

        if let vType = EventLocationType(rawValue: sender.selectedSegmentIndex) {
            viewType = vType
            locationIndex = -1
            transitionToViewType(viewType, selectedIndex: locationIndex)
        }
    }

    @IBAction func handleLocationChanged(sender: UISegmentedControl) {

        if viewType == EventLocationType.Maps {
            if let map:LocationDataMap = locationStore.mapForIndex(sender.selectedSegmentIndex) {
                mapContainer?.locationData = map
            }
        } else {
            if let layout:LocationDataLayout = locationStore.layoutForIndex(sender.selectedSegmentIndex) {
                layoutContainer?.locationData = layout
            }
        }
    }

    
    // MARK: - Maps
    
    func transitionToViewType( type: EventLocationType, selectedIndex:Int ) {
        
        switch (type) {

        case EventLocationType.Maps:

            transitionContentViewFrom(layoutContainer!, to: mapContainer!)
            mapContainer?.updateMapAnnotationsWithData(locationStore.maps)

        case EventLocationType.Layouts:
            
            transitionContentViewFrom(mapContainer!, to: layoutContainer!)
        }
        updateLocationControlForViewType(type, selectedIndex: selectedIndex)
    }
    
    func transitionContentViewFrom(from:UIView, to:UIView) {

        to.hidden = false
        contentView.bringSubviewToFront(to)
        from.hidden = true
    }

    func updateLocationControlForViewType(type:EventLocationType, selectedIndex:Int) {

        let locationItems = locationStore.arrayOfTitlesForLocationType(type)
        
        locationControl.removeAllSegments();
        
        var idx = 0
        for title:String in locationItems {
            locationControl.insertSegmentWithTitle(title, atIndex: idx, animated: true)
            idx++
        }

        var index = selectedIndex
        if locationControl.numberOfSegments > 0 {
            if index == -1 {
                index = 0
            }
        }
        locationControl.selectedSegmentIndex = index
        handleLocationChanged(locationControl)
    }
    
    // MARK: - LayoutContainerViewDatasource
    
    func imageDataForLayout(layout: LocationDataLayout) -> NSData? {
        
        return locationStore.imageDataForLayout(layout)
    }
}
