//
//  LoadRunTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-12.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class LoadRunsTask: ConfigSyncServerTask {
    
    //MARK: Initializer
    init(viewController: UIViewController?) {
        super.init(module: "fd", method: "getrunsbylastupdate", httpMethod: "GET")
        taskDelegate = LoadRunsHandler(viewController: viewController)
    }
    
    //MARK: Server Delegate Handler
    // Load Runs By Last Update
    class LoadRunsHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(viewController: viewController, taskTitle: "Config Sync", taskDescription: "Loading Runs")
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            guard let jsonList = data as? [Any] else {
                // Unable to parse server data
                throw OsonoError.Message("Error Loading User Data from Server")
            }
            
            for jsonListEntry in jsonList {
                if let data = jsonListEntry as? [String:Any] {
                    if let Run_ID = data["id"] as? Int,
                        let Name = data["name"] as? String,
                        let Description = data["desc"] as? String,
                        let Active = data["act"] as? Bool {
                        
                        // Save the User record to the database
                        do {
                            if let run = Run(Run_ID: Run_ID, Name: Name, Description: Description, Active: Active, LastUpdate: Date()) {
                                let db = try Database.DB()
                                try run.updateDB(db: db)
                            }
                            else {
                                // Unable to create an OLUser object to save to local database
                                throw OsonoError.Message("Error saving user data to local database")
                            }
                        }
                        catch {
                            // Unable to save the Asset Token to the database
                            throw OsonoError.Message("Error saving user data to local database")
                        }
                    }
                    
                }
                else {
                    // Unable to parse server data
                    throw OsonoError.Message("Error Loading User Data from Server")
                }
            }
        }
        
        override func success() {
            // If this is being called from the LoginViewController, update the Run list
            if let loginViewController = viewController as? LoginViewController {
                DispatchQueue.main.async {
                    loginViewController.loadRunList()
                }
            }
            super.success()
        }
        
    }
    
}
