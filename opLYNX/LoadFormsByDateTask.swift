//
//  LoadFormsByDateTask.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-11-14.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class LoadFormsByDateTask: OPLYNXUserServerTask {
    
    //MARK: Initializer
    init(operationalDate: Date, ofNumbers: [String], viewController: UIViewController?) {
        super.init(module: "of", method: "getbydateandofnumbers", httpMethod: "GET")
        addParameter(name: "run_id", value: String(Authorize.CURRENT_RUN!.Run_ID))
        addParameter(name: "user_id", value: String(Authorize.CURRENT_USER!.OLUser_ID))
        addParameter(name: "operational_date", value: "\"" + operationalDate.formatJsonDate() + "\"")
        addParameter(name: "ofnumbers", value: ofNumbers.joined(separator: ","))
        taskDelegate = LoadFormsByDateHandler(viewController: viewController)
    }
    
    //MARK: Server Delegate Handler
    // Load Operational Forms by Operational Date and OFNumbers
    class LoadFormsByDateHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(taskTitle: "Loading Operational Forms", viewController: viewController)
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            
            guard let jsonList = data as? [Any] else {
                // Unable to parse server data
                throw OsonoError.Message("Error Loading Form Data from Server")
            }
            
            // Get a Database Connection
            let db = try Database.DB()
            
            // Extract the Date -> OFNumber Dictionary
            for jsonListEntry in jsonList {
                guard let data = jsonListEntry as? [String:Any],
                    let OFNumber = data["ofn"] as? String,
                    let Operational_DateString = data["od"] as? String,
                    let Operational_Date = Date(jsonDate: Operational_DateString),
                    let Asset_ID = data["ai"] as? Int,
                    let UniqueOFNumber = data["uofn"] as? Int,
                    let OFType_ID = data["oti"] as? Int,
                    let OFStatus_ID = data["osi"] as? Int,
                    let Due_DateString = data["dd"] as? String,
                    let Due_Date = Date(jsonDate: Due_DateString),
                    let Create_DateString = data["cd"] as? String,
                    let Create_Date = Date(jsonDate: Create_DateString),
                    let Complete_DateString = data["cpd"] as? String,
                    let Complete_Date = Date(jsonDate: Complete_DateString),
                    let CreateUser_ID = data["cui"] as? Int,
                    let CompleteUser_ID = data["cpui"] as? Int,
                    let Comments = data["com"] as? String,
                    let OFElementDataArray = parseOFElementData(OFNumber: OFNumber, data: data["da"]) else {
                        // Unable to parse server data
                        throw OsonoError.Message("Error Loading Form Data from Server")
                }
                
                // Create the Operational Form object
                // TODO: LastUpdate??
                let operationalForm = OperationalForm(OFNumber: OFNumber, Operational_Date: Operational_Date, Asset_ID: Asset_ID, UniqueOFNumber: UniqueOFNumber, OFType_ID: OFType_ID, OFStatus_ID: OFStatus_ID, Due_Date: Due_Date, Create_Date: Create_Date, Complete_Date: Complete_Date, CreateUser_ID: CreateUser_ID, CompleteUser_ID: CompleteUser_ID, Comments: Comments, LastUpdate: Date(), Dirty: false)
                
                // Insert the Operational Form to the database
                try db.transaction {
                    // Save the Operational Form
                    try operationalForm?.insertDB(db: db)
                    
                    // Save the Data Array
                    for ofElementData in OFElementDataArray {
                        try ofElementData.insertOrUpdatepdateOFElementValue(db: db)
                    }
                }
                /*
                do {
                    // Save the Operational Form
                    try operationalForm?.updateDB(db: db)
                    
                    // Save the Data Array
                    for ofElementData in OFElementDataArray {
                        try ofElementData.updateOFElementValue(db: db)
                    }
                } catch {
                    // TODO: Handle database error
                    os_log("Unable to save Operational Form to database OFNumber=%@", log: OSLog.default, type: .error, OFNumber)
                }
                */
            }
            
            // Refresh the Operational Form List if this is being called from an OFTableViewController
            if let ofTableViewController = viewController as? OFTableViewController {
                ofTableViewController.loadOperationalForms()
                DispatchQueue.main.async {
                    ofTableViewController.tableView?.reloadData()
                }
            }
            
        }
        
        //MARK: Helper Methods
        private func parseOFElementData(OFNumber: String, data: Any?) -> [OFElementData]? {
            guard let jsonList = data as? [Any] else {
                // Unable to parse server data
                return nil
            }
            
            // Extract the Element Data array
            var ofElementDataArray = [OFElementData]()
            for jsonListEntry in jsonList {
                guard let data = jsonListEntry as? [String:Any],
                    let OFElement_ID = data["e"] as? Int,
                    let Value = data["v"] as? String else {
                        // Unable to parse server data
                        return nil
                }
                
                // Create the OFElementData object
                if let ofElementData = OFElementData(OFNumber: OFNumber, OFElement_ID: OFElement_ID, Value: Value) {
                    ofElementDataArray.append(ofElementData)
                }
            }
            return ofElementDataArray
        }
        
    }
    
}
