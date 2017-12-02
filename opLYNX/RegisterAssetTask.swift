//
//  RegisterAssetTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-11.
//  Copyright © 2017 CIS. All rights reserved.
//


import Foundation
import UIKit
import os.log

class RegisterAssetTask: OPLYNXAssetServerTask {
    
    //MARK: Initializer
    init(_ assetName: String, viewController: UIViewController?) {
        super.init(module: "auth", method: "registerasset", httpMethod: "GET", viewController: viewController, taskTitle: "Authorize", taskDescription: "Registering Asset")
        addParameter(name: "asset_name", value: assetName)
        addParameter(name: "client_id", value: Authorize.CLIENT_ID)
    }
    
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
