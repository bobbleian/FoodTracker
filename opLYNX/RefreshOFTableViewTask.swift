//
//  RefreshOFTableViewTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-20.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

class RefreshOFTableViewTask : OPLYNXGenericTask {
    
    // Refresh the OF Table View UI
    // TODO: Implement progress spinner
    override func RunTask() {
        if let ofTableViewController = self.viewController as? OFTableViewController {
            
            // Refresh the Operational Form List
            ofTableViewController.loadAllOperationalForms()
            if let oplynxProgressView = viewController as? OPLYNXProgressView {
                oplynxProgressView.updateProgress(title: "Updating UI", description: nil)
            }
            
            DispatchQueue.main.async {
                ofTableViewController.tableView?.reloadData()
                
                // Run success  TODO: Check
                //self.taskDelegate?.success()
                
                // Run the next Osono Task, if necessary
                self.runNextTask()
                
            }
        }
    }
}
