//
//  LoadOFListTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-13.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class LoadFormListTask: OPLYNXUserServerTask {
    
    //MARK: Static Properties
    static var ServerOFList = [Date: [String]]()
    
    //MARK: Properties
    let run: Run
    
    //MARK: Initializer
    init(viewController: UIViewController?, run: Run) {
        self.run = run
        super.init(module: "of", method: "getgroupedbydate", httpMethod: "GET", viewController: viewController, taskTitle: "Data Sync", taskDescription: "Loading Operational Forms")
        addParameter(name: "run_id", value: String(run.Run_ID))
        if let currentUser = Authorize.CURRENT_USER {
            addParameter(name: "user_id", value: String(currentUser.OLUser_ID))
        }
        // TODO: Fix start date Jan 1, 2000
        addParameter(name: "start_date", value: "\"/Date(946710000000)/\"")
        addParameter(name: "oftype_ids", value: String(OperationalForm.OF_TYPE_ID_D13))
    }
    
    override func processData(data: Any) throws {
        
        // Clear out current Server OF List
        LoadFormListTask.ServerOFList.removeAll()
        
        guard let jsonList = data as? [Any] else {
            // Unable to parse server data
            throw OsonoError.Message("Error Loading User Data from Server")
        }
        
        // Extract the Date -> OFNumber Dictionary
        for jsonListEntry in jsonList {
            guard let data = jsonListEntry as? [String:Any],
                let operationalDateString = data["key"] as? String,
                let operationalDate = Date(jsonDate: operationalDateString),
                let ofList = data["value"] as? [String] else {
                    // Unable to parse server data
                    throw OsonoError.Message("Error Loading Form Data from Server")
            }
            
            for ofNumber in ofList {
                if !LoadFormListTask.ServerOFList.keys.contains(operationalDate) {
                    LoadFormListTask.ServerOFList[operationalDate] = [String]()
                }
                LoadFormListTask.ServerOFList[operationalDate]?.append(ofNumber)
            }
        }
        
        // Get the Local OF List from database
        guard let LocalOFList = try? OperationalForm.loadOFListByOperationalDate(db: Database.DB()) else {
            throw OsonoError.Message("Error Loading Local Form Data")
        }
        
        // Prune Server OF List based on contents of Local OF List
        for localOFDate in LocalOFList.keys {
            var serverOFNumbers = LoadFormListTask.ServerOFList[localOFDate] ?? [String]()
            for localOFNumber in LocalOFList[localOFDate]! {
                //  If the local OFNumber is in the Server list, we can remove it from the Server list
                if let index = serverOFNumbers.index(of: localOFNumber){
                    // Remove it from the server list
                    serverOFNumbers.remove(at: index)
                }
                    // Remove it from the local database
                else {
                    print("Deleting form \(localOFNumber) from database")
                    try? OperationalForm.deleteOF(db: Database.DB(), OFNumber: localOFNumber)
                }
            }
            // Update the ServerOFList entry
            LoadFormListTask.ServerOFList[localOFDate] = serverOFNumbers
        }
        
        // Now we are on the selected run, update the global reference
        Authorize.CURRENT_RUN = run
        try? LocalSettings.updateSettingsValue(db: Database.DB(), Key: LocalSettings.LOGIN_CURRENT_RUN_KEY, Value: run.Name)
        
        // Refresh the Operational Form List if this is being called from an OFTableViewController
        if let ofTableViewController = viewController as? OFTableViewController {
            ofTableViewController.loadAllOperationalForms()
            DispatchQueue.main.async {
                ofTableViewController.tableView?.reloadData()
            }
        }
        
        // Go through the Server OF List Dictionary, loading Forms from server as necessary
        for serverOFDate in LoadFormListTask.ServerOFList.keys.sorted() {
            let serverOFNumbers = LoadFormListTask.ServerOFList[serverOFDate] ?? [String]()
            // Create a task to load new Forms, if there is at least one new form to load
            if serverOFNumbers.count > 0 {
                // Build an Osono Task for loading Forms by Date, to be run after this task
                let loadFormsByDateTask = LoadFormsByDateTask(operationalDate: serverOFDate, ofNumbers: serverOFNumbers, run: run, viewController: viewController)
                insertOsonoTask(loadFormsByDateTask)
            }
        }
        
        
    }
    
}
