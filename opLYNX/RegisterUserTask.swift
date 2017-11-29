//
//  RegisterUserTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-13.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class RegisterUserTask: OPLYNXAssetServerTask {
    
    //MARK: Initializer
    init(_ userName: String, viewController: UIViewController?) {
        super.init(module: "auth", method: "registeruser", httpMethod: "GET")
        addParameter(name: "grant_type", value: "password")
        addParameter(name: "username", value: userName)
        addParameter(name: "client_assertion", value: OsonoServerTask.ASSET_TOKEN)
        taskDelegate = RegisterUserHandler(viewController: viewController)
    }
    
    //MARK: Server Delegate Handlers
    class RegisterUserHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(viewController: viewController, taskTitle: "Data Sync", taskDescription: "Registering User")
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            if let data = data as? String {
                // Save the Asset Token
                do {
                    try LocalSettings.updateSettingsValue(db: Database.DB(), Key: LocalSettings.AUTHORIZE_USER_TOKEN_KEY, Value: data)
                    try OsonoServerTask.setUserToken(newValue: data)
                }
                catch {
                    // Unable to save the Asset Token to the database
                    throw OsonoError.Message("Error saving User Token locally")
                }
            }
            else {
                // Unable to parse server data
                throw OsonoError.Message("Error Authorizing User on Server")
            }
        }
        
    }
    
}
