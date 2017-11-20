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
        taskDelegate = LoadFormsByDateHandler(viewController: viewController, operationalDate: operationalDate, totalCount: ofNumbers.count)
    }
    
    //MARK: Server Delegate Handler
    // Load Operational Forms by Operational Date and OFNumbers
    class LoadFormsByDateHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Properties
        let operationalDate: Date
        let totalCount: Int
        var currentCount: Int = 1
        
        //MARK: Initializers
        init(viewController: UIViewController?, operationalDate: Date, totalCount: Int) {
            self.operationalDate = operationalDate
            self.totalCount = totalCount
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            super.init(taskTitle: "Loading " + dateFormatter.string(from: operationalDate) + " Forms [" + String(currentCount) + "/" + String(totalCount) + "]", viewController: viewController)
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            
            guard let jsonList = data as? [Any] else {
                // Unable to parse server data
                throw OsonoError.Message("Error Loading Form Data from Server")
            }
            
            
            // Build a list of OperationalForm objects to load to the database
            var operationalForms = [OperationalForm]()
            var ofElementData = [OperationalForm: [OFElementData]]()
            var ofLinkRun = [OperationalForm: [OFLinkRun]]()
            
            // Extract the Date -> OFNumber Dictionary
            for jsonListEntry in jsonList {
                if let viewController = viewController {
                    DispatchQueue.main.async {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM dd, yyyy"
                        JustHUD.shared.showInView(view: viewController.view, withHeader: "Loading " + dateFormatter.string(from: self.operationalDate) + " Forms [" + String(self.currentCount) + "/" + String(self.totalCount) + "]", andFooter: nil)
                        self.currentCount += 1
                    }
                }
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
                    let OFElementDataArray = parseOFElementData(OFNumber: OFNumber, data: data["da"]),
                    let OFLinkRunArray = parseOFLinkRun(OFNumber: OFNumber, data: data["lrl"]) else {
                        // Unable to parse server data
                        throw OsonoError.Message("Error Loading Form Data from Server")
                }
                
                
                
                // Create the Operational Form object
                // TODO: LastUpdate??
                if let operationalForm = OperationalForm(OFNumber: OFNumber, Operational_Date: Operational_Date, Asset_ID: Asset_ID, UniqueOFNumber: UniqueOFNumber, OFType_ID: OFType_ID, OFStatus_ID: OFStatus_ID, Due_Date: Due_Date, Create_Date: Create_Date, Complete_Date: Complete_Date, CreateUser_ID: CreateUser_ID, CompleteUser_ID: CompleteUser_ID, Comments: Comments, LastUpdate: Date(), Dirty: false) {
                    // Add to the list
                    operationalForms.append(operationalForm)
                    ofElementData[operationalForm] = OFElementDataArray
                    ofLinkRun[operationalForm] = OFLinkRunArray
                }
            }
            
            // Insert the Forms into the database            
            // Get a Database Connection
            let db = try Database.DB()
            
            // Insert the Operational Form to the database
            currentCount = 1
            try db.transaction {
                for operationalForm in operationalForms {
                    if let viewController = viewController {
                        DispatchQueue.main.async {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMM dd, yyyy"
                            JustHUD.shared.showInView(view: viewController.view, withHeader: "Saving " + dateFormatter.string(from: self.operationalDate) + " Forms [" + String(self.currentCount) + "/" + String(self.totalCount) + "]", andFooter: nil)
                            self.currentCount += 1
                        }
                    }
                    
                    // Save the Operational Form
                    try operationalForm.insertDB(db: db)
                    
                    // Save the Data Array
                    if let ofElementDataArray = ofElementData[operationalForm] {
                        for ofElementData in ofElementDataArray {
                            try ofElementData.insertOFElementValue(db: db)
                        }
                    }
                    
                    // Save the Link Run Array
                    if let ofLinkRunArray = ofLinkRun[operationalForm] {
                        for ofLinkRun in ofLinkRunArray {
                            try ofLinkRun.insertOFLinkRun(db: db)
                        }
                    }
                    
                }
            }
            
            // Refresh the Operational Form List if this is being called from an OFTableViewController
            if let ofTableViewController = viewController as? OFTableViewController {
                ofTableViewController.loadAllOperationalForms()
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
        
        private func parseOFLinkRun(OFNumber: String, data: Any?) -> [OFLinkRun]? {
            guard let jsonList = data as? [Any] else {
                // Unable to parse server data
                return nil
            }
            
            // Extract the Element Data array
            var ofLinkRunArray = [OFLinkRun]()
            for jsonListEntry in jsonList {
                guard let data = jsonListEntry as? [String:Any],
                    let OFNumber = data["ofn"] as? String,
                    let Run_ID = data["ri"] as? Int else {
                        // Unable to parse server data
                        return nil
                }
                
                // Create the OFElementData object
                if let ofLinkRun = OFLinkRun(OFNumber: OFNumber, Run_ID: Run_ID) {
                    ofLinkRunArray.append(ofLinkRun)
                }
            }
            return ofLinkRunArray
        }
        
    }
    
}
