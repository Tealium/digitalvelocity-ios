//
//  Categories.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 3/30/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

class Category : NSObject{
    
    var objectId : String = ""
    var title : String = ""
    var priority : Int = 0
    var updatedAt : NSDate = NSDate()
    var eventDate : NSDate?
    var cellData : [CellData] = [CellData]()
    var cellDataSortAscending : Bool = true
    
    override var description : String{
        return "Category objectId:\(objectId) title:\(title) priority:\(priority) eventDate:\(eventDate) cellData:\(cellData)"
    }
    
    func duplicate()->Category{
        let newCategory = Category()
        newCategory.objectId = objectId
        newCategory.title = title
        newCategory.priority = priority
        newCategory.updatedAt = updatedAt
        newCategory.eventDate = eventDate
        var newCellData = [CellData]()
        for cell in cellData{
            let newCell = cell
            newCellData.append(newCell)
        }
        newCategory.cellData = newCellData
        return newCategory
    }
    
    private func sortedCellData(ascending:Bool, cellDataArray:[CellData])->[CellData]{
        var sortedArray:[CellData] = [CellData]()
        
        if let cellSample = cellDataArray.first{
            if cellSample.start != nil{
                sortedArray = cellDataArray.sort({
                    (cell1:CellData, cell2:CellData) -> Bool in
                    
                    if let c1sd = cell1.startDate?.timeIntervalSince1970{
                        if let c2sd = cell2.startDate?.timeIntervalSince1970{
                            if ascending == true{
                                return c1sd < c2sd
                            } else {
                                return c1sd > c2sd
                            }
                        }
                    }
                    
                    if ascending == true{
                        return cell1.start < cell2.start
                    } else {
                        return cell1.start > cell2.start
                    }

                })
            } else {
                sortedArray = cellDataArray.sort({
                    (cell1:CellData, cell2:CellData) -> Bool in
                    if ascending == true{
                        return cell1.createdAt.timeIntervalSince1970 > cell2.createdAt.timeIntervalSince1970
                    } else {
                        return cell1.createdAt.timeIntervalSince1970 < cell2.createdAt.timeIntervalSince1970
                    }
                })
            }
        }
        return sortedArray
    }
    
    func sortedCellData()->[CellData]{
        return sortedCellData(cellDataSortAscending, cellDataArray: cellData)
    }
    
    func filteredCellData(searchTerm : String?) -> [CellData]{
        if let searchTerm = searchTerm{
            if searchTerm == "_favorites"{
                let filteredData = cellData.filter({m in m.isLocalFavorite() == true})
                return sortedCellData(cellDataSortAscending, cellDataArray: filteredData)
            }
            
            // TODO: add future search feature here
        }
        return sortedCellData(cellDataSortAscending, cellDataArray: cellData)
    }
}
