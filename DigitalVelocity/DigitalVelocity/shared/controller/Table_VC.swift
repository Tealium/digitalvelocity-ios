 //
//  DVTableViewController.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/12/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

private var itemDataContext = 0

class Table_VC: UITableViewController {

    var dataSource:TableDataSource?
    var eventDataType: EventDataType?
    var selectedItemData: CellData?
    var store: EventDataStore!
    var reuseIDBaseCell     = "DVBaseCell"
    let reuseIDHeaderCell   = "DVHeaderCell"
    
    var itemData:Dictionary<NSIndexPath, CellData> = Dictionary()
    
    deinit {
        cleanupItemData()
    }

    func cleanupItemData() {

        for data in itemData.values{
            data.removeImageDataReadyObserver()
        }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine

        setupMenuNavigationForController()
        
        store = EventDataStore.sharedInstance()
        
        self.setupRefresh()
        
        if let edt = eventDataType{
            
            dataSource = store.dataSourceForType(edt)
            
            store.loadRemoteDataForType(edt){ (refreshed) -> () in
                if refreshed {
                    self.refresh()
                }
            }
        }
    }
    
    func setupRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("forceRefresh"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewDidAppear(animated:Bool){

        Analytics.trackView(self, data: nil)
        
        restoreLastPosition()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveLastPosition()
    }

    func forceRefresh() {
        
        guard let dataSource = dataSource else {
        
            refreshControl?.endRefreshing()
            return
        }
        
        dataSource.forceRefresh({ (successful, error) -> () in
            
            self.refresh()
        
        })
        
    }
    
    // Only refreshes from local data
    func refresh() {
        
        dataSource?.refresh { (successful, error) -> () in
            
            if successful == true {
                self.refreshLocal()
            } else {
                TEALLog.log("Could not refresh table:\(error?.localizedDescription)")
            }
        }
    }
    
    func refreshLocal(){
        
        // Can be called by search feature
        
        self.cleanupItemData()
        self.itemData.removeAll(keepCapacity: false)
        self.tableView.reloadData()
        refreshControl?.endRefreshing()

    }
    
    func saveLastPosition(){
        let lastPositions = self.tableView.indexPathsForVisibleRows
        if let title = self.restorationIdentifier{
            store.lastPositions[title] = lastPositions
        }
    }
    
    func restoreLastPosition(){
        
        self.tableView?.reloadData()
        
        if let title = self.restorationIdentifier{
            if let s = store{
                if let lastPositions = s.lastPositions[title]{
                    // Key on 2nd index due possibly to first being masked by nav bar. Scrolling to first index will appear incorrect to user
                    if lastPositions.count < 2 {
                        // No last position data - scroll to top
                        self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
                        return
                    }
                    
                    if let topIndexPath = lastPositions[1] as? NSIndexPath{
                        self.tableView?.scrollToRowAtIndexPath(topIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                    }
                }
            }
        }
    }
    
    // MARK: - Sections / Headers

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let num = dataSource?.numberOfSections() {
            return num
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource?.titleForHeaderInSection(section)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCellWithIdentifier(reuseIDHeaderCell) as! DVHeaderTableViewCell
        
        if let title = dataSource?.titleForHeaderInSection(section) as String! {
            headerCell.configureCell(title)
        }
        return headerCell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 26
    }
    
    // MARK: - Rows / Cells

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = dataSource?.numberOfRows(section) {
            return num
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88.0
    }
    
    
    /*

    Tealium.tagBridgeCommand..{
    
    //...
    
    }
    
    
*/
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier(reuseIDBaseCell) as! DVBaseTableViewCell

        let item = cellDataForTableView(tableView, indexPath: indexPath)
        
        c.textLabel?.text = item.title
        c.detailTextLabel?.text = item.subtitle
        c.delegate = self

        return c
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if let item = itemData[indexPath] {
            
            selectedItemData = item
        }
        
        if let item = dataSource?.cellDataFor(indexPath){
            selectedItemData = item
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let segueID = segue.identifier {
            
            switch segueID {
                
            case menuOptions.web.storyboardId:
                
                if let web = segue.destinationViewController as? Web_VC {
                    
                    if let target = selectedItemData?.url {
                        web.url = target
                    }
                }
            case menuOptions.location.storyboardId:
                
                if let map = segue.destinationViewController as? EventLocation_VC {
                    if let target = selectedItemData?.locationId {
                        map.currentLocationID = target
                    } else {
                        TEALLog.log("Location Id not present for location item.")
                    }
                }
            default:
                TEALLog.log("Unsupported segue: \(segueID)")
            }
        }
    }
    
    // MARK: Item / Cell Data Methods
    
    func cellDataForTableView(tableView:UITableView, indexPath:NSIndexPath) -> CellData {
        if let item = itemData[indexPath] {
            
            return item
        } else
            if let data = dataSource?.cellDataFor(indexPath) {
        
            data.indexPath = indexPath
            data.observeForImageDataReady(self, context: &itemDataContext)
            itemData[indexPath] = data
            
            return data
        } else {
            return CellData()
        }
    }

    // MARK: CellData Obvserver
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == &itemDataContext {
            
            let itemData = object as! CellData
            
            if let indexPath = itemData.indexPath {

                if let paths = tableView.indexPathsForVisibleRows {
                
                    if paths.contains(indexPath) {
                        
                        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    }
                }
            }
        }
        
    }
}

extension Table_VC: DVTableViewCellDelegate {
    
    func tableViewCellAccessoryTapped(tableViewCell: DVBaseTableViewCell) {
        
        if let indexPath = self.tableView.indexPathForCell(tableViewCell) {
            
            if let item = itemData[indexPath] {
            
                if item.locationId != nil{
                    self.selectedItemData = item
                    self.performSegueWithIdentifier(menuOptions.location.storyboardId, sender: self)
                }
            }
        }
    }
    
    func tableViewCellFavoriteTapped(tableViewCell: DVBaseTableViewCell) {
        if let indexPath = self.tableView.indexPathForCell(tableViewCell) {
            if let item = itemData[indexPath] {
                item.toggleFavorite(nil)
                tableViewCell.updateFavoriteStatus(item.isLocalFavorite())
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
        
    }
}

