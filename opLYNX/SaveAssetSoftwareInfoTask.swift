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

class SaveAssetSoftwareInfoTask: OPLYNXAssetServerTask {
    
    
    //MARK: Initializer
    init(_ syncType: String, viewController: UIViewController?) {
        super.init(module: "asset", method: "saveassetsoftwareinfo", httpMethod: "POST", viewController: viewController, taskTitle: syncType, taskDescription: "Saving AssetSWInfo")
    }
    
    // Inserts the AssetSoftwareInfo payload into the Task before calling Run
    override func RunTask() {
        // Need to load ASSET SOFTWARE INFO
        if let assetSoftwareInfo = Authorize.ASSET_SOFTWARE_INFO {
            // Update ASSET SOFTWARE INFO with config sync server time, if exists
            if let serverSyncTime = ConfigSync.CONFIG_SYNC_SERVER_TIME_UTC {
                assetSoftwareInfo.LastSyncConfiguration = serverSyncTime
            }
            // Update ASSET SOFTWARE INFO with data sync server time, if exists
            if let serverSyncTime = DataSync.DATA_SYNC_SERVER_TIME_UTC {
                assetSoftwareInfo.LastSyncData = serverSyncTime
            }
            // Update Last Update time ??
            assetSoftwareInfo.LastUpdate = Date()
            setDataPayload(dataPayload: assetSoftwareInfo.convertToOsono())
        }
        super.RunTask()
    }
    
    // On Success, we save the AssetSoftwareInfo object to the database
    override func success() {
        try? Authorize.ASSET_SOFTWARE_INFO?.updateDB(db: Database.DB())
        DispatchQueue.main.async {
            JustHUD.shared.hide()
            super.success()
        }
    }
    
}
