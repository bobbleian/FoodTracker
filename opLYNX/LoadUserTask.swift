//
//  LoadUserTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-12.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class LoadUserTask: ConfigSyncServerTask {
    
    //MARK: Initializer
    init(viewController: UIViewController?) {
        super.init(module: "user", method: "getusersbylastupdate", httpMethod: "GET")
        taskDelegate = LoadUsersHandler(viewController: viewController)
    }
    
    //MARK: Server Delegate Handler
    // Load Users By Last Update
    class LoadUsersHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(taskTitle: "Loading Users", viewController: viewController)
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            guard let jsonList = data as? [Any] else {
                // Unable to parse server data
                throw OsonoError.Message("Error Loading User Data from Server")
            }
                
            for jsonListEntry in jsonList {
                guard let data = jsonListEntry as? [String:Any],
                        let OLUser_ID = data["id"] as? Int,
                        let Run_ID = data["rid"] as? Int,
                        let UserName = data["un"] as? String,
                        let Password = data["pw"] as? String,
                        let FirstName = data["fn"] as? String,
                        let LastName = data["ln"] as? String,
                        let Active = data["act"] as? Bool,
                        let PhoneNumber = data["pn"] as? String,
                        let MobileNumber = data["mn"] as? String,
                        let EmailAddress = data["em"] as? String else {
                            // Unable to parse server data
                            throw OsonoError.Message("Error Loading User Data from Server")
                }
                
                // Create the OLUser object
                guard let olUser = OLUser(OLUser_ID: OLUser_ID, Run_ID: Run_ID, UserName: UserName, Password: Password, FirstName: FirstName, LastName: LastName, PhoneNumber: PhoneNumber, MobileNumber: MobileNumber, EmailAddress: EmailAddress, Active: Active, LastUpdate: Date()) else {
                    // Unable to create an OLUser object to save to local database
                    throw OsonoError.Message("Error saving user data to local database")
                }
                
                // Save the User record to the database
                do {
                    let db = try Database.DB()
                    try olUser.updateUser(db: db)
                }
                catch {
                    // Unable to save the Asset Token to the database
                    throw OsonoError.Message("Error saving user data to local database")
                }
            }
        }
        
    }
    
}
