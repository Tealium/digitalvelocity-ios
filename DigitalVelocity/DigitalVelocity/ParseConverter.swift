//
//  ParseConverter.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 3/31/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

/**
    Converts Parse data into format used by the DV App
*/
class ParseConverter {
   
    class func configFromPFObject(object:PFObject) -> Config{
        let config = Config()
        var conversionError = false
        
        if let ent = object[keyConfigEnterThreshold] as? Double{
            config.enterThreshold = ent
        } else {
            TEALLog.log("Missing from config: Enter Threshold")
            conversionError = true
        }
        
        if let ext = object[keyConfigExitThreshold] as? Double{
            config.exitThreshold = ext
        } else {
            TEALLog.log("Missing from config: Exit Threshold")
            conversionError = true
        }
        
        if let rt = object[keyConfigRssi] as? Int{
            config.rssiThreshold = rt
        } else {
            TEALLog.log("Missing from config: RSSI Threshold")
            conversionError = true
        }
        
        if let prc = object[keyConfigPOIRefreshCycle] as? Double{
            config.poiRefreshCycle = prc
        } else {
            TEALLog.log("Missing from config: POI Refresh Cycle")
            conversionError = true
        }
        
        if let sp = object[keyConfigPurge] as? Bool{
            config.shouldPurge = sp
        } else {
            TEALLog.log("Missing from config: Should Purge")
            conversionError = true
        }
        
        if let ent = object[keyConfigScanRate] as? Double{
            config.scanRate = ent
        } else {
            TEALLog.log("Missing from config: Scan Cycle")
            conversionError = true
        }
        
        if let smh = object[keyConfigStartMonitoringHour] as? Int{
            config.startMonitoring = smh
        } else {
            TEALLog.log("Missing from config: Start Monitoring Hour")
            conversionError = true
        }
        
        if let smd = object[keyConfigStartMonitoringDate] as? NSDate{
            config.startMonitoringDate = smd
        } else {
            TEALLog.log("Missing from config: Start Monitoring Date")
            conversionError = true
        }
        
        if let stmh = object[keyConfigStopMonitoringHour] as? Int{
            config.stopMonitoring = stmh
        } else {
            TEALLog.log("Missing from config: Stop Monitoring Hour")
            conversionError = true
        }
        
        if let stmd = object[keyConfigStopMonitoringDate] as? NSDate{
            config.stopMonitoringDate = stmd
        } else {
            TEALLog.log("Missing from config: Stop Monitoring Date")
            conversionError = true
        }
        
        if let sr = object[keyConfigSyncRate] as? Double{
            config.syncRate = sr
        } else {
            TEALLog.log("Missing from config: Sync Rate")
            conversionError = true
        }
        
        if let wt = object[keyConfigWelcomeTitle] as? String{
            config.welcomeTitle = wt
        } else {
            TEALLog.log("Missing from config: Welcome Title")
            conversionError = true
        }
        
        if let ws = object[keyConfigWelcomeSubtitle] as? String{
            config.welcomeSubtitle = ws
        } else {
            TEALLog.log("Missing from config: Welcome Subtitle")
            conversionError = true
        }
        
        if let wd = object[keyConfigWelcomeDescription] as? String{
            config.welcomeDescription = wd
        } else {
            TEALLog.log("Missing from config: Welcome Description")
            conversionError = true
        }
        
        config.updatedAt = object.updatedAt!
        config.isDefault = false
        
        if conversionError == true{
            TEALLog.log("Problem converting one or more elements from PFObject:\(object) to config object:\(config.description())")
        }
        return config
    }

    // MARK: Categories
    
    class func categoriesFromPFObjects(pfObjects:[AnyObject]!)->[Category]{
        var cats = [Category]()
        
        if let pfos = pfObjects{
            for pfObject in pfos{
                if let pfo = pfObject as? PFObject{
                    let cat = self.categoryFromPFObject(pfo)
                    cats.append(cat)
                }
            }
            
            // Sort categories
            cats = cats.sort({ (cat1:Category, cat2:Category) -> Bool in
                return cat1.priority < cat2.priority
            })
            
        }
        return cats
    }
    
    class private func categoryFromPFObject(pfObject:PFObject)->Category{
        let cat = Category()
        cat.objectId = pfObject.objectId!
        cat.updatedAt = pfObject.updatedAt!
        if let t = pfObject[ph.keyTitle] as? String{
            cat.title = t
        }
        if let p = pfObject[ph.keyPriority] as? Int{
            cat.priority = p
        }
        if let ed = pfObject[ph.keyEventDate] as? NSDate{
            cat.eventDate = ed
        }
        return cat
    }
    
    // MARK: Cell data

    class func convertToCategoriesWithCellDataFor(pfObjects:[PFObject], ascending:Bool, categories:[Category]?) -> [Category]{
        
        var sortedCategoryCellData = [Category]()
        
        let allCellData = self.cellDatasForPFObjects(pfObjects)
        if let cats = categories{
            let selectCats = categoriesForAllObjects(allCellData, categories: cats)
            let sortedCategoriesByPriority = self.sortedCategoriesByPriority(ascending, categories: selectCats)
            for cat in sortedCategoriesByPriority{
                // create dict for each category
                let cellDatas = self.sortedCellDataForCategory(cat, ascending:ascending, allCellData: allCellData)
                cat.cellData = cellDatas
                sortedCategoryCellData.append(cat)
            }
        } else {
            let cat = Category()
            cat.cellData = sortedCellData(ascending, cellDataArray:allCellData)
            sortedCategoryCellData.append(cat)
        }
    
        return sortedCategoryCellData
    }
    
    class private func sortedCategoriesByPriority(ascending:Bool, categories:[Category])->[Category]{
        
        let sortedArray:[Category] = categories.sort({
            (cat1:Category, cat2:Category) -> Bool in
            
            if ascending{
                return cat1.priority < cat2.priority
            } else {
                return cat1.priority > cat2.priority
            }
        })
        return sortedArray
    }
    
    // TODO: Move cell data sorting to Category
    class private func sortedCellDataForCategory(category:Category, ascending:Bool, allCellData:[CellData])->[CellData]{
        
        let cid = category.objectId
        
        let filteredArray:[CellData] = allCellData.filter{ (cellData:CellData) -> Bool in
            return cellData.categoryId == cid
        }
        
        let sortedArray:[CellData] = sortedCellData(ascending, cellDataArray:filteredArray)
        
        return sortedArray
    }
    
    class private func sortedCellData(ascending:Bool, cellDataArray:[CellData])->[CellData]{
        var sortedArray:[CellData] = [CellData]()
        
        if let cellSample = cellDataArray.first{
            if cellSample.start != nil{
                sortedArray = cellDataArray.sort({
                    (cell1:CellData, cell2:CellData) -> Bool in
                    
                    if ascending{
                        return cell1.start < cell2.start
                    } else {
                        return cell1.start > cell2.start
                    }
                })
            } else {
                sortedArray = cellDataArray.sort({
                    (cell1:CellData, cell2:CellData) -> Bool in
                    if ascending{
                        return cell1.createdAt.timeIntervalSince1970 > cell2.createdAt.timeIntervalSince1970
                    } else {
                        return cell1.createdAt.timeIntervalSince1970 < cell2.createdAt.timeIntervalSince1970
                    }
                })
            }
        }
        return sortedArray
    }
    
    class private func categoriesForAllObjects(cellDatas:[CellData], categories:[Category])->[Category]{
        
        // For class with no category break up
        if categories.isEmpty{
            let cat = Category()
            let cats = [cat]
            return cats
        }
        
        // For classes with categories
        var targetCats = [String:String]()
        for cellData in cellDatas{
            if let cid = cellData.categoryId{
                targetCats[cid] = cid
            }
        }
        
        var catsToKeep = [Category]()
        for cat in categories{
            for key in targetCats.keys{
                if cat.objectId == key{
                    catsToKeep.append(cat)
                }
            }
        }
        return catsToKeep
    }
    
    class func cellDatasForPFObjects(pfObjects:[AnyObject])->[CellData]{
        var cellDatas = [CellData]()
        
        for pfObject in pfObjects{
            if let pfo = pfObject as? PFObject{
                if let cellData = cellDataForPFObject(pfo){
                    cellDatas.append(cellData)
                }
            }
        }
        
        return cellDatas
    }
    
    class func cellDataForPFObject(pfo:PFObject)->CellData?{
        let cell = CellData()
        
        // Origin object id
        if let oid = pfo.objectId{
            cell.objectId = oid
        }
        
        
        // Answers
        if let answers = pfo[ph.keyAnswers] as? [String]{
            
            if cell.data == nil {
                cell.data = [ String : AnyObject]()
            }
            
            cell.data![ph.keyAnswers] = answers
        }
        
        // CreatedAt
        if let c = pfo.createdAt{
            cell.createdAt = c
        } else if let ac = pfo["altCreatedAt"] as? NSDate{
            cell.createdAt = ac
        }
        
        // CategoryId
        if let cid = pfo[ph.keyCategoryId] as? String{
            cell.categoryId = cid
        }
        
        // Title
        if let t = pfo[ph.keyTitle] as? String{
            cell.title = t
        }
        
        // Subtitle
        if let st = pfo[ph.keySubtitle] as? String{
            cell.subtitle = st
        }
        
        // Time range
        if let start = pfo[ph.keyStart] as? Int{
            
            let startH = String(format:"%.2d",start/100)
            let startM = String(format:"%.2d",start%100)
            var s : String = "\(startH):\(startM)"
            
            if let end = pfo[ph.keyEnd] as? Int{
                let endH = String(format:"%.2d",end/100)
                let endM = String(format:"%.2d",end%100)
                s = s + " - \(endH):\(endM)"
            }
            cell.timeRange = s
        }
        
        // Time Actual
        TEALLog.log("\(pfo)")
        if let start = pfo[ph.keyStartDate] as? NSDate{
            cell.startDate = start
            if let end = pfo[ph.keyEndDate] as? NSDate{
                cell.endDate = end
            }
        }
        
        // Room Name
        if let rn = pfo[ph.keyRoomName] as? String{
            cell.roomName = rn
        }
        
        // Image
        if let i = pfo[ph.keyImageData] as? PFFile{
            
            // Actual
            i.getDataInBackgroundWithBlock({ (imageDataSource, error) -> Void in

                if let ids = imageDataSource {
                    cell.imageData = ids
                    cell.imageDataReady = true
                }
                
                if error != nil {
                    TEALLog.log("Problem retrieveing pffile:\(i)")
                }
            })
        }
        
        // Font Awesome
        
        if let fa = pfo[ph.keyImageFontAwesome] as? String {
            if fa != "" {
                cell.fontAwesomeValue = fa
            }
        }
        
        // Details
        if let d = pfo[ph.keyDescription] as? String{
            cell.targetDescription = d
        }
        
        // Start
        if let start = pfo[ph.keyStart] as? Int{
            
            cell.start = start
        }
        
        // Weblink
        if let u = pfo[ph.keyUrl] as? String{
            let url = NSURL(string: u)
            cell.url = url
        }
        
        // Map Location
        if let l = pfo[ph.keyLocationId] as? String{
            cell.locationId = l
        }
        
        // Survey questions
        if let surveyQuestionIds = pfo[ph.keyQuestionIds] as? [String] {
            
            var data = [String: AnyObject]()
            data[ph.keyQuestionIds] = surveyQuestionIds
            cell.data = data
            
        }
        
        return cell
    }
    
}
