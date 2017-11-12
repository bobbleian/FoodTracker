//
//  SaveAssetSoftwareInfoTask.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-11-09.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class SaveAssetSoftwareInfoTask: OPLYNXServerTask {
    
    //MARK: Initializer
    init(viewController: UIViewController?) {
        super.init(module: "asset", method: "saveassetsoftwareinfo", httpMethod: "POST")
        taskDelegate = SaveAssetSoftwareInfoHandler(viewController: viewController)
    }
    
    // Inserts the AssetSoftwareInfo payload into the Task before calling Run
    override func RunTask() {
        // Need to load ASSET SOFTWARE INFO
        if let assetSoftwareInfo = ConfigSync.ASSET_SOFTWARE_INFO {
            // Update ASSET SOFTWARE INFO with server time, if exists
            if let serverSyncTime = ConfigSync.SERVER_DATETIME_UTC {
                assetSoftwareInfo.LastSyncConfiguration = serverSyncTime
            }
            // Update Last Update time ??
            assetSoftwareInfo.LastUpdate = Date()
            setDataPayload(dataPayload: assetSoftwareInfo.convertToOsono())
        }
        super.RunTask()
    }
    
    // Save AssetSoftwareInfo Handler
    class SaveAssetSoftwareInfoHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(taskTitle: "Saving AssetSWInfo", viewController: viewController)
        }
        
        //MARK: OsonoTaskDelegate Protocol
        
        // On Success, we save the AssetSoftwareInfo object to the database
        override func success() {
            do {
                try ConfigSync.ASSET_SOFTWARE_INFO?.updateDB(db: Database.DB())
                super.success()
                let alert = UIAlertController(title: "Success", message: "Config Sync Complete", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                viewController?.present(alert, animated: true, completion: nil)
            } catch {
                super.error(message: "Error saving AssetSWInfo to local database")
            }
        }
    }
    
}
