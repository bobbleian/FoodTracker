//
//  RefreshOFTableViewTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-20.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

class RefreshOFTableViewTask : OPLYNXGenericTask {
    
    private let ofTableViewController: OFTableViewController
    
    init(ofTableViewController: OFTableViewController) {
        self.ofTableViewController = ofTableViewController
        super.init()
    }
    
    // Refresh the OF Table View UI
    override func RunTask() {
        // Refresh the Operational Form List
        ofTableViewController.loadAllOperationalForms()
        DispatchQueue.main.async {
            
            JustHUD.shared.showInView(view: self.ofTableViewController.view, withHeader: "Updating UI", andFooter: nil)
        }
        
        DispatchQueue.main.async {
            if let ofTableViewController = self.viewController as? OFTableViewController {
                self.ofTableViewController.tableView?.reloadData()
            }
            
            // Run success  TODO: Check
            //self.taskDelegate?.success()
            
            // Run the next Osono Task, if necessary
            self.runNextTask()
            
        }
    }
}
