//
//  LoadFormsByLastSyncTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-22.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class LoadFormsByLastSyncTask: OPLYNXUserServerTask {
    
    //MARK: Initializer
    init(viewController: UIViewController?) {
        super.init(module: "of", method: "getbylinksforclient", httpMethod: "GET")
        addParameter(name: "run_id", value: String(Authorize.CURRENT_RUN!.Run_ID))
        addParameter(name: "user_id", value: String(Authorize.CURRENT_USER!.OLUser_ID))
        // TODO: Fix start date Jan 1, 2000
        addParameter(name: "operational_date", value: "\"/Date(946710000000)/\"")
        // TODO: Fix hardcoded OF Type ID of 6
        addParameter(name: "oftype_ids", value: "6")
        taskDelegate = LoadFormsBySyncHandler(viewController: viewController)
    }
    
    // Inserts a "last_update" parameter to the task before calling Run
    override func RunTask() {
        if let lastDataSyncDate = ConfigSync.ASSET_SOFTWARE_INFO?.LastSyncData {
            addParameter(name: "last_update", value: "\"" + lastDataSyncDate.formatJsonDate() + "\"")
        }
        super.RunTask()
    }
    
    //MARK: Server Delegate Handler
    // Load Operational Forms by Operational Date and OFNumbers
    class LoadFormsBySyncHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Properties
        var totalCount: Int = 0
        var currentCount: Int = 0
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            super.init(taskTitle: "Loading Updated Forms", viewController: viewController)
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
            var ofLinkUser = [OperationalForm: [OFLinkUser]]()
            var ofLinkOperationalForm = [OperationalForm: [OFLinkOperationalForm]]()
            var ofLinkMedia = [OperationalForm: [OFLinkMedia]]()
            
            // Extract the Date -> OFNumber Dictionary
            for jsonListEntry in jsonList {
                if let viewController = viewController {
//                    DispatchQueue.main.async {
//                        let dateFormatter = DateFormatter()
//                        dateFormatter.dateFormat = "MMM dd, yyyy"
//                        JustHUD.shared.showInView(view: viewController.view, withHeader: "Loading " + dateFormatter.string(from: self.operationalDate) + " Forms [" + String(self.currentCount) + "/" + String(self.totalCount) + "]", andFooter: nil)
//                        self.currentCount += 1
//                    }
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
                    let OFLinkRunArray = parseOFLinkRun(OFNumber: OFNumber, data: data["lrl"]),
                    let OFLinkUserArray = parseOFLinkUser(OFNumber: OFNumber, data: data["lul"]),
                    let OFLinkOperationalFormArray = parseOFLinkOperationalForm(OFNumber: OFNumber, data: data["lofl"]),
                    let OFLinkMediaArray = parseOFLinkMedia(OFNumber: OFNumber, data: data["lml"]) else {
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
                    ofLinkUser[operationalForm] = OFLinkUserArray
                    ofLinkOperationalForm[operationalForm] = OFLinkOperationalFormArray
                    ofLinkMedia[operationalForm] = OFLinkMediaArray
                }
            }
            
            // Insert the Forms into the database
            // Get a Database Connection
            let db = try Database.DB()
            
            // Insert the Operational Form to the database
            currentCount = 1
            try db.transaction {
                for operationalForm in operationalForms {
//                    if let viewController = viewController {
//                        DispatchQueue.main.async {
//                            let dateFormatter = DateFormatter()
//                            dateFormatter.dateFormat = "MMM dd, yyyy"
//                            JustHUD.shared.showInView(view: viewController.view, withHeader: "Saving " + dateFormatter.string(from: self.operationalDate) + " Forms [" + String(self.currentCount) + "/" + String(self.totalCount) + "]", andFooter: nil)
//                            self.currentCount += 1
//                        }
//                    }
                    
                    // Delete the local verson of the form
                    try OperationalForm.deleteOF(db: db, OFNumber: operationalForm.OFNumber)
                    
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
                    
                    // Save the Link User Array
                    if let ofLinkUserArray = ofLinkUser[operationalForm] {
                        for ofLinkUser in ofLinkUserArray {
                            try ofLinkUser.insertOFLinkUser(db: db)
                        }
                    }
                    
                    // Save the Link Form Array
                    if let ofLinkOperationalFormArray = ofLinkOperationalForm[operationalForm] {
                        for ofLinkOperationalForm in ofLinkOperationalFormArray {
                            try ofLinkOperationalForm.insertOFLinkOperationalForm(db: db)
                        }
                    }
                    
                    // Save the Link Media Array
                    if let ofLinkMediaArray = ofLinkMedia[operationalForm] {
                        for ofLinkMedia in ofLinkMediaArray {
                            try ofLinkMedia.insertMediaToDB(db: db)
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
        
        private func parseOFLinkUser(OFNumber: String, data: Any?) -> [OFLinkUser]? {
            guard let jsonList = data as? [Any] else {
                // Unable to parse server data
                return nil
            }
            
            // Extract the Element Data array
            var ofLinkUserArray = [OFLinkUser]()
            for jsonListEntry in jsonList {
                guard let data = jsonListEntry as? [String:Any],
                    let OFNumber = data["ofn"] as? String,
                    let OLUser_ID = data["oui"] as? Int else {
                        // Unable to parse server data
                        return nil
                }
                
                // Create the OFElementData object
                if let ofLinkUser = OFLinkUser(OFNumber: OFNumber, OLUser_ID: OLUser_ID) {
                    ofLinkUserArray.append(ofLinkUser)
                }
            }
            return ofLinkUserArray
        }
        
        private func parseOFLinkOperationalForm(OFNumber: String, data: Any?) -> [OFLinkOperationalForm]? {
            guard let jsonList = data as? [Any] else {
                // Unable to parse server data
                return nil
            }
            
            // Extract the Element Data array
            var result = [OFLinkOperationalForm]()
            for jsonListEntry in jsonList {
                guard let data = jsonListEntry as? [String:Any],
                    let OFNumber = data["ofn"] as? String,
                    let LinkOFNumber = data["lofn"] as? String,
                    let OFLinkType_ID = data["olt"] as? Int else {
                        // Unable to parse server data
                        return nil
                }
                
                // Create the OFElementData object
                if let entry = OFLinkOperationalForm(OFNumber: OFNumber, LinkOFNumber: LinkOFNumber, OFLinkType_ID: OFLinkType_ID) {
                    result.append(entry)
                }
            }
            return result
        }
        
        private func parseOFLinkMedia(OFNumber: String, data: Any?) -> [OFLinkMedia]? {
            guard let jsonList = data as? [Any] else {
                // Unable to parse server data
                return nil
            }
            
            // Extract the Element Data array
            var result = [OFLinkMedia]()
            for jsonListEntry in jsonList {
                guard let data = jsonListEntry as? [String:Any],
                    let OFNumber = data["ofn"] as? String,
                    let MediaNumber = data["mn"] as? String,
                    let OFElement_ID = data["ofe"] as? Int,
                    let SortOrder = data["so"] as? Int else {
                        // Unable to parse server data
                        return nil
                }
                
                // Create the OFElementData object
                if let entry = OFLinkMedia(OFNumber: OFNumber, MediaNumber: MediaNumber, OFElement_ID: OFElement_ID, SortOrder: SortOrder) {
                    result.append(entry)
                }
            }
            return result
        }
        
    }
    
}
