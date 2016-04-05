//
//  DVTableData.swift
//  DigitalVelocity
//
//  Created by Jason Koo on 2/25/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//
//  BRIEF: Intermediary between the various table views and the Parse backend

import UIKit

class TableDataSource: NSObject {
   
    var isLoaded = false
    var name: String
    var filteredCategories : [Category]!
    var sortedCategories : [Category] = [Category]()
        {
        didSet{
            filteredCategories = filterCategories(sortedCategories)
        }
    }
    var searchTerm : String?{
        didSet{
            filteredCategories = filterCategories(sortedCategories)
        }
    }
    
    var searchTerms : [String]?{
        didSet{
            filteredCategories = multiFilterCategories(sortedCategories)
        }
    }
    
    override var description : String {
        
        return "TableDataSource name:\(name) sortedCategoryCellData:\(sortedCategories)"
        
    }
    
    init(name: String) {
        self.name = name
        super.init()
    }

    func load(){
        // Meant to be overwritten by subclass
        filteredCategories = filterCategories(sortedCategories)
    }
    
    
    func forceRefresh(completion:(successful:Bool, error:NSError?) ->())->Void{
        // Meant to be overwritten by subclass - pulls from offsite, regardless of local
        
    }
    
    func refresh(completion:(successful:Bool, error:NSError?) ->())->Void{
        // Meant to be overwritten by subclass

    }
    
    func numberOfSections()-> Int{
        if filteredCategories.count > 0{
            return filteredCategories.count
        }
        return 1
    }
    
    func titleForHeaderInSection(section: Int)-> String?{
        if section < filteredCategories.count{
            // categories holds raw ids, - convert to string value
            let cat = filteredCategories[section]
            return cat.title
        }
        return nil
    }
    
    func numberOfRows(section:Int) -> Int{        
        if section < filteredCategories.count{
            let cat = filteredCategories[section]
            return cat.sortedCellData().count//cellData.count
        }
        return 1
    }

    func cellDataFor(indexPath:NSIndexPath)->CellData{
        if filteredCategories.count > indexPath.section{
            let cat = filteredCategories[indexPath.section]
            let cellData = cat.sortedCellData()//cellData
            if indexPath.row < cellData.count{
                return cellData[indexPath.row]
            }
        }
        return CellData()
    }
    
    private func multiFilterCategories(categories:[Category])->[Category]{
        
        guard let searchTerms = searchTerms else {
            // No searchTerms to use
            return categories
        }
        
        var newCategories : [Category] = [Category]()
        for category in categories{
            for term in searchTerms {
                let newCategory = category.duplicate()
                let newCellData = newCategory.filteredCellData(term)
                if newCellData.count > 0 {
                    newCategory.cellData = newCellData
                    newCategories.append(newCategory)
                } else {
                    newCategory.cellData = [CellData]()
                }
            }
        }
        return newCategories
    }
    
    private func filterCategories(categories:[Category])->[Category]{
        
        if searchTerm == nil || searchTerm == "" {
            return categories
        }
        
        var newCategories : [Category] = [Category]()
        for category in categories{
            let newCategory = category.duplicate()
            let newCellData = newCategory.filteredCellData(searchTerm)
            if newCellData.count > 0 {
                newCategory.cellData = newCellData
                newCategories.append(newCategory)
            } else {
                newCategory.cellData = [CellData]()
            }
        }
        return newCategories
    }
    
}