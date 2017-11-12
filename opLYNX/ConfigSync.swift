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
    
    // Run Config Sync
    static func RunConfigSync(viewController: UIViewController?) {
        // Create a task for loading asset software info
        guard let loadAssetSoftwareInfoTask = LoadAssetSoftwareInfoTask(viewController: viewController) else {
            // TODO: Error message
            return
        }
        
        // Create a task for loading Server DateTime
        let loadDateTimeUTCTask = LoadDateTimeUTCTask(viewController: viewController)
        
        // Create a task for loading users
        let loadUserTask = LoadUserTask(viewController: viewController)
        
        // Create a task for loading runs
        let loadRunTask = LoadRunsTask(viewController: viewController)
        
        // Create a task for saving AssetSoftwareInfo
        let saveAssetSoftwareInfoTask = SaveAssetSoftwareInfoTask(viewController: viewController)
        
        // Chain the Config Sync tasks together
        loadAssetSoftwareInfoTask.nextOsonoTask = loadDateTimeUTCTask
        loadDateTimeUTCTask.nextOsonoTask = loadUserTask
        loadUserTask.nextOsonoTask = loadRunTask
        loadRunTask.nextOsonoTask = saveAssetSoftwareInfoTask
        
        // Run the Osono Task Chain
        loadAssetSoftwareInfoTask.RunTask()
    }
    
}
