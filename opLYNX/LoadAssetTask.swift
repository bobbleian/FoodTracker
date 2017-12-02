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

class LoadAssetTask: OPLYNXAssetServerTask {
    
    //MARK: Initializer
    init(_ assetName: String, viewController: UIViewController?) {
        super.init(module: "asset", method: "loadassetbyname", httpMethod: "GET", viewController: viewController, taskTitle: "Authorize", taskDescription: "Loading Asset")
        addParameter(name: "asset_name", value: assetName)
    }
    
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
    
    // Navigate to User Login screen
    override func success() {
        // Navigate to User Login screen
        if let assetRegistrationViewController = viewController as? AssetRegistrationViewController {
            DispatchQueue.main.async {
                assetRegistrationViewController.performSegue(withIdentifier: "ShowUserLogin", sender: assetRegistrationViewController)
            }
        }
    }
}


