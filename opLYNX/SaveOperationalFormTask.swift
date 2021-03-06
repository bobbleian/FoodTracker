//
//  SaveOperationalFormTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-21.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class SaveOperationalFormTask: OPLYNXUserServerTask {
    
    //MARK: Properties
    private let operationalForm: OperationalForm
    
    //MARK: Initializer
    init(_ operationalForm: OperationalForm, viewController: UIViewController?) {
        self.operationalForm = operationalForm
        super.init(module: "of", method: "save", httpMethod: "POST", viewController: viewController, taskTitle: "Data Sync", taskDescription: "Uploading Operational Form")
        setDataPayload(dataPayload: operationalForm.convertToOsono())
    }
    
    override func processData(data: Any) throws {
        if let data = data as? Bool {
            // Unable to parse server data
            if !data {
                throw OsonoError.Message("Error Saving Form to Server")
            }
        }
    }
    
    // Update Dirty status of Form to false
    override func success() {
        try? OperationalForm.updateOFDirty(db: Database.DB(), OFNumber: operationalForm.OFNumber, Dirty: false)
        operationalForm.Dirty = false;
        
        // Refresh the Operational Form List if this is being called from an OFTableViewController
        if let ofTableViewController = viewController as? OFTableViewController {
            ofTableViewController.loadAllOperationalForms()
            DispatchQueue.main.async {
                ofTableViewController.tableView?.reloadData()
            }
        }
    }
    
}
