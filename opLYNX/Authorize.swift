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
    
    
    
    public static func AuthorizeUser(grantType: String, userName: String) {
        
    }
    
    /*
     // Create a task for registering the asset
     let registerAssetTask = OPLYNXServerTask(module: "auth", method: "registerasset", httpMethod: "GET")
     registerAssetTask.addParameter(name: "asset_name", value: "CIS9")
     registerAssetTask.addParameter(name: "client_id", value: Authorize.CLIENT_ID)
     registerAssetTask.taskDelegate = Authorize.RegisterAssetHandler(viewController: self)
     
     // Create a task for loading the asset data
     let loadAssetTask = OPLYNXServerTask(module: "asset", method: "loadassetbyname", httpMethod: "GET")
     loadAssetTask.addParameter(name: "asset_name", value: "CIS9")
     loadAssetTask.taskDelegate = Authorize.LoadAssetHandler(viewController: self)
     
     // Chain the tasks & run
     registerAssetTask.nextOsonoTask = loadAssetTask
     registerAssetTask.Run()
     */
    
}
