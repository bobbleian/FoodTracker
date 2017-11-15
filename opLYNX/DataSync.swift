//
//  DataSync.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-12.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit

class DataSync {
    
    //MARK: Static Properties
    // Static variable for storing Server Date Time used in Data Sync
    public static var SERVER_DATETIME_UTC: Date?
    public static var ASSET_SOFTWARE_INFO: AssetSoftwareInfo?
    
    // Run Data Sync
    static func RunDataSync(viewController: UIViewController?) {
        // Create a task for loading asset software info
        guard let loadAssetSoftwareInfoTask = LoadAssetSoftwareInfoTask(viewController: viewController) else {
            // TODO: Error message
            return
        }
        
        // Register User Task
        let registerUserTask = RegisterUserTask(Authorize.CURRENT_USER?.UserName ?? "", viewController: viewController)
              
        // Save Dirty Media
        
        // Save Dirty Operational Forms
        
        
        // Load Operational Form List by Start Date
        let loadOFListTask = LoadFormListTask(viewController: viewController)
        
        // Create a task for loading Server DateTime
        let loadDateTimeUTCTask = LoadDateTimeUTCTask(viewController: viewController)
        
        // Create a task for saving AssetSoftwareInfo
        let saveAssetSoftwareInfoTask = SaveAssetSoftwareInfoTask("Data Sync", viewController: viewController)
        
        // Chain the Data Sync tasks together
        loadAssetSoftwareInfoTask.insertOsonoTask(registerUserTask)
        registerUserTask.insertOsonoTask(loadOFListTask)
        loadOFListTask.insertOsonoTask(loadDateTimeUTCTask)
        loadDateTimeUTCTask.insertOsonoTask(saveAssetSoftwareInfoTask)
        
        // Run the Osono Task Chain
        loadAssetSoftwareInfoTask.RunTask()
    }
    
}
