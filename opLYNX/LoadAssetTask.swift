//
//  LoadAssetTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-11.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class LoadAssetTask: OPLYNXServerTask {
    
    //MARK: Initializer
    init(_ assetName: String, viewController: UIViewController?) {
        super.init(module: "asset", method: "loadassetbyname", httpMethod: "GET")
        addParameter(name: "asset_name", value: "CIS9")
        taskDelegate = LoadAssetHandler(viewController: viewController)
    }
    
    //MARK: Server Delegate Handlers
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
    
}
