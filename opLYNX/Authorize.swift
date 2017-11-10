//
//  Authorize.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-31.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class Authorize {
    
    public static let CLIENT_ID = "ba91fecd-7371-4466-a11e-8b44a99ee809"
    
    //MARK: Server Delegate Handlers
    class RegisterAssetHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(taskTitle: "Registering Asset", viewController: viewController)
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            if let data = data as? String {
                // Save the Asset Token
                do {
                    try LocalSettings.updateSettingsValue(db: Database.DB(), Key: LocalSettings.AUTHORIZE_ASSET_TOKEN_KEY, Value: data)
                    try OsonoServerTask.setAssetToken(newValue: data)
                }
                catch {
                    // Unable to save the Asset Token to the database
                    throw OsonoError.Message("Error saving Asset Token locally")
                }
            }
            else {
                // Unable to parse server data
                throw OsonoError.Message("Error Authorizing Asset on Server")
            }
        }
        
    }
    
    class LoadAssetHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(taskTitle: "Loading Asset", viewController: viewController)
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            if let data = data as? [String:Any] {
                if let Asset_ID = data["id"] as? Int, let Name = data["name"] as? String {
                    // Save the Asset record to the database
                    do {
                        let db = try Database.DB()
                        try Asset.deleteAllAsset(db: db)
                        try Asset.updateAsset(db: db, Asset_ID: Asset_ID, Name: Name)
                    }
                    catch {
                        // Unable to save the Asset Token to the database
                        throw OsonoError.Message("Error saving Asset Data locally")
                    }
                }
            }
            else {
                // Unable to parse server data
                throw OsonoError.Message("Error Loading Asset Data from Server")
            }
        }
    }
    
    public static func AuthorizeUser(grantType: String, userName: String) {
        
    }
    
}
