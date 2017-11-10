//
//  ConfigSync.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-11-01.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class ConfigSync {
    
    //MARK: Static Properties
    
    // Static variable for storing Server Date Time used in Config Sync
    public static var SERVER_DATETIME_UTC: Date?
    public static var ASSET_SOFTWARE_INFO: AssetSoftwareInfo?
    
    //MARK: ConfigSyncServerTask Definition
    class ConfigSyncServerTask: OPLYNXServerTask {
        
        // Inserts a "last_update" parameter to all the Task before calling Run
        override func Run() {
            if let lastConfigSyncDate = ASSET_SOFTWARE_INFO?.LastSyncConfiguration {
                addParameter(name: "last_update", value: "\"" + lastConfigSyncDate.formatJsonDate() + "\"")
            }
            super.Run()
        }
    }
    
    //MARK: Server Delegate Handlers
    
    // GetDateTimeUTC
    class GetDateTimeUTCHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(taskTitle: "Getting Server Time", viewController: viewController)
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            if let data = data as? String, let serverDate = Date(jsonDate: data) {
                SERVER_DATETIME_UTC = serverDate
            }
            else {
                // Unable to parse server data
                throw OsonoError.Message("Error Loading Server Time")
            }
        }
        
    }
    
    // Load Asset Software Info
    class LoadAssetSoftwareInfoHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(taskTitle: "Loading Asset Software Info", viewController: viewController)
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            if let data = data as? [String:Any] {
                if let AssetSoftwareInfo_ID = data["id"] as? Int,
                    let Asset_ID = data["aid"] as? Int,
                    let Software_ID = data["sid"] as? Int,
                    let Version = data["ver"] as? String,
                    let LastSyncConfiguration = data["lsc"] as? String,
                    let LastSyncData = data["lsd"] as? String,
                    let LastSyncConfigurationDate = Date(jsonDate: LastSyncConfiguration),
                    let LastSyncDataDate = Date(jsonDate: LastSyncData),
                    let assetSoftwareInfo = AssetSoftwareInfo(AssetSoftwareInfo_ID: AssetSoftwareInfo_ID, Asset_ID: Asset_ID, Software_ID: Software_ID, Version: Version, LastSyncConfiguration: LastSyncConfigurationDate, LastSyncData: LastSyncDataDate, LastUpdate: Date())
                    {
                    
                        // Save the AssetSoftwareInfo record to the database
                        do {
                            try assetSoftwareInfo.updateDB(db: Database.DB())
                            ASSET_SOFTWARE_INFO = assetSoftwareInfo
                        }
                        catch {
                            // Unable to save the Asset Token to the database
                            throw OsonoError.Message("Error saving AssetSoftwareInfo Data locally")
                        }
                }
                else {
                    // Unable to parse server data
                    throw OsonoError.Message("Error Loading AssetSoftwareInfo Data from Server")
                }
            }
            else {
                // Unable to parse server data
                throw OsonoError.Message("Error Loading AssetSoftwareInfo Data from Server")
            }
        }
    }
    
    // Load Users By Last Update
    class LoadUsersHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(taskTitle: "Loading Users", viewController: viewController)
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            if let jsonList = data as? [Any] {
                
                for jsonListEntry in jsonList {
                    if let data = jsonListEntry as? [String:Any] {
                        if let OLUser_ID = data["id"] as? Int,
                            let Run_ID = data["rid"] as? Int,
                            let UserName = data["un"] as? String,
                            let Password = data["pw"] as? String,
                            let FirstName = data["fn"] as? String,
                            let LastName = data["ln"] as? String,
                            let Active = data["act"] as? Bool,
                            let PhoneNumber = data["pn"] as? String,
                            let MobileNumber = data["mn"] as? String,
                            let EmailAddress = data["em"] as? String {
                            
                            // Save the User record to the database
                            do {
                                if let olUser = OLUser(OLUser_ID: OLUser_ID, Run_ID: Run_ID, UserName: UserName, Password: Password, FirstName: FirstName, LastName: LastName, PhoneNumber: PhoneNumber, MobileNumber: MobileNumber, EmailAddress: EmailAddress, Active: Active, LastUpdate: Date()) {
                                    let db = try Database.DB()
                                    try olUser.updateUser(db: db)
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
            else {
                // Unable to parse server data
                throw OsonoError.Message("Error Loading User Data from Server")
            }
        }
        
    }
    
    
    // Load Runs By Last Update
    class LoadRunsHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(taskTitle: "Loading Runs", viewController: viewController)
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
        
    }
    
    
}
