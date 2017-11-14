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

class LoadOFListTask: OPLYNXUserServerTask {
    
    //MARK: Static Properties
    static var ServerOFList = [Date: [String]]()
    
    //MARK: Initializer
    init(viewController: UIViewController?) {
        super.init(module: "of", method: "getgroupedbydate", httpMethod: "GET")
        addParameter(name: "run_id", value: "238")
        addParameter(name: "user_id", value: "145")
        // Jan 1, 2000
        addParameter(name: "start_date", value: "\"/Date(946710000000)/\"")
        addParameter(name: "oftype_ids", value: "6")
        taskDelegate = LoadOFListHandler(viewController: viewController)
    }
    
    //MARK: Server Delegate Handler
    // Load Operational Form by Start Date
    class LoadOFListHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(taskTitle: "Loading Operational Forms", viewController: viewController)
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            
            // Clear out current Server OF List
            ServerOFList.removeAll()
            
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
                    if !ServerOFList.keys.contains(operationalDate) {
                        ServerOFList[operationalDate] = [String]()
                    }
                    ServerOFList[operationalDate]?.append(ofNumber)
                }
            }
            
        }
        
    }
    
}
