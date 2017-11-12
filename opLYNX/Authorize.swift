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
    public static var ASSET: Asset?
    
    
    // Register Asset
    static func RegisterAsset(viewController: UIViewController?) {
        // Create a task for registering the asset
        let registerAssetTask = RegisterAssetTask(viewController: viewController)
        
        // Create a task for loading the asset data
        let loadAssetTask = LoadAssetTask("CIS9", viewController: viewController)
        
        // Chain the tasks & run
        registerAssetTask.nextOsonoTask = loadAssetTask
        registerAssetTask.RunTask()
    }
    
}
