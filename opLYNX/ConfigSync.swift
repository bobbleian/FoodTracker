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
    public static var CONFIG_SYNC_SERVER_TIME_UTC: Date?
    
    // Run Config Sync
    static func RunConfigSync(viewController: UIViewController?) {
        
        // Check first we can hit the server
        let pingServerTask = PingServerTask(viewController: viewController)
        
        // Create a task for loading asset software info
        guard let loadAssetSoftwareInfoTask = LoadAssetSoftwareInfoTask("Config Sync", viewController: viewController) else {
            // TODO: Error message
            return
        }
        
        // Create a task for loading Server DateTime
        let loadDateTimeUTCTask = LoadDateTimeUTCTask(viewController: viewController, updateConfigSync: true, updateDataSync: false)
        
        // Create a task for loading users
        let loadUserTask = LoadUserTask(viewController: viewController)
        
        // Create a task for loading runs
        let loadRunTask = LoadRunsTask(viewController: viewController)
        
        // Create a task for saving AssetSoftwareInfo
        let saveAssetSoftwareInfoTask = SaveAssetSoftwareInfoTask("Config Sync", viewController: viewController)
        
        // Chain the Config Sync tasks together
        pingServerTask.insertOsonoTask(loadAssetSoftwareInfoTask)
        loadAssetSoftwareInfoTask.insertOsonoTask(loadDateTimeUTCTask)
        loadDateTimeUTCTask.insertOsonoTask(loadUserTask)
        loadUserTask.insertOsonoTask(loadRunTask)
        loadRunTask.insertOsonoTask(saveAssetSoftwareInfoTask)
        
        // Run the Osono Task Chain
        loadAssetSoftwareInfoTask.RunTask()
    }
    
}
