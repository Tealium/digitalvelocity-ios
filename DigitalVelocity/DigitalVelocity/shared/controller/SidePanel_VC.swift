//
//  LeftViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Modified by Jason Koo on 02/12/2015
//  Copyright (c) 2014 James Frost. All rights reserved.
//
//  BRIEF: Slideout, we're only using it for a right-hand slide out, but could be repurposed for left-hand side as well

import UIKit

//@objc
protocol SidePanel_VC_Delegate {
    func menuOptionSelected(option: MenuOption)
}

class SidePanel_VC: UIViewController {
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: SidePanel_VC_Delegate?
    var options : [MenuOption]!
    
    struct TableView {
        struct CellIdentifiers {
            static let optionCell = "optionCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        options = MenuOption.allOptions()
        tableView.scrollEnabled = false
        tableView.reloadData()
        
        // hack for hiding insets 
        self.tableView.tableFooterView = self.footerView
    }

    @IBAction func gotoSettings(){
        let mo = MenuOption(title: menuOptions.settings.title, storyboardId: menuOptions.settings.storyboardId)
        delegate?.menuOptionSelected(mo)
    }

}

// MARK: TableView DataSource
extension SidePanel_VC: UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.optionCell, forIndexPath: indexPath) as! rightSidedOptionCell
        let menuOption = options[indexPath.row]
        cell.updateTitle(menuOption.title)
        return cell
    }
    
}

// MARK: TableView Delegate
extension SidePanel_VC: UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let menuOption = options[indexPath.row]
        delegate?.menuOptionSelected(menuOption)
    }
}


class rightSidedOptionCell: UITableViewCell{
    @IBOutlet weak var titleLabel: UILabel!
    
    func updateTitle(title:String){
        titleLabel.text = title
    }
}