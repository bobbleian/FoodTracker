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
    
    //MARK: Static Properties
    public static let CLIENT_ID = "ba91fecd-7371-4466-a11e-8b44a99ee809"
    public static let D13_FORM_ID = 6
    public static var ASSET: Asset?
    public static var CURRENT_USER: OLUser?
    public static var CURRENT_RUN: Run?
    
    // Register Asset
    static func RegisterAsset(_ assetName: String, viewController: UIViewController?) {
        // Create a task for registering the asset
        let registerAssetTask = RegisterAssetTask(assetName, viewController: viewController)
        
        // Create a task for loading the asset data
        let loadAssetTask = LoadAssetTask(assetName, viewController: viewController)
        
        // Chain the tasks & run
        registerAssetTask.insertOsonoTask(loadAssetTask)
        registerAssetTask.RunTask()
    }
    
}
