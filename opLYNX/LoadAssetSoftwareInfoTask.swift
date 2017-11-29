//
//  LoadAssetSoftwareInfoTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-11.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log


class LoadAssetSoftwareInfoTask: OPLYNXAssetServerTask {
    
    //MARK: Initializer
    init?(_ syncType: String, viewController: UIViewController?) {
        // Load current Asset from local database
        guard let asset = try? Asset.loadAsset(db: Database.DB())! else { return nil }
        super.init(module: "asset", method: "loadassetsoftwareinfo", httpMethod: "GET")
        addParameter(name: "asset_id", value: String(asset.Asset_ID))
        addParameter(name: "software_id", value: String(AssetSoftwareInfo.SOFTWARE_ID))
        taskDelegate = LoadAssetSoftwareInfoHandler(syncType, viewController: viewController)
    }
    
    // Load Asset Software Info
    class LoadAssetSoftwareInfoHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(_ syncType: String, viewController: UIViewController?) {
            super.init(viewController: viewController, taskTitle: syncType, taskDescription: "Loading Asset Software Info")
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            if let data = data as? [String:Any] {
                if let AssetSoftwareInfo_ID = data["id"] as? Int,
                    let Asset_ID = data["aid"] as? Int,
                    let Software_ID = data["sid"] as? Int,
                    let Version = data["ver"] as? String,
                    let LastSyncConfiguration = data["lsc"] as? String,
                    let LastSyncData = data["lsd"] as? String,
                    let LastSyncConfigurationDate = Date(jsonDate: LastSyncConfiguration),
                    let LastSyncDataDate = Date(jsonDate: LastSyncData),
                    let assetSoftwareInfo = AssetSoftwareInfo(AssetSoftwareInfo_ID: AssetSoftwareInfo_ID, Asset_ID: Asset_ID, Software_ID: Software_ID, Version: Version, LastSyncConfiguration: LastSyncConfigurationDate, LastSyncData: LastSyncDataDate, LastUpdate: Date())
                {
                    
                    // Save the AssetSoftwareInfo record to the database
                    do {
                        try assetSoftwareInfo.updateDB(db: Database.DB())
                        Authorize.ASSET_SOFTWARE_INFO = assetSoftwareInfo
                    }
                    catch {
                        // Unable to save the Asset Token to the database
                        throw OsonoError.Message("Error saving AssetSoftwareInfo Data locally")
                    }
                }
                else {
                    // Unable to parse server data
                    throw OsonoError.Message("Error Loading AssetSoftwareInfo Data from Server")
                }
            }
            else {
                // Unable to parse server data
                throw OsonoError.Message("Error Loading AssetSoftwareInfo Data from Server")
            }
        }
    }
    
}
