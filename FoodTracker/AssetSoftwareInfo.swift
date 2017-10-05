//
//  Asset.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

class AssetSoftwareInfo {
    
    //MARK: Properties
    var AssetSoftwareInfo_ID: Int
    var Asset_ID: Int
    var Software_ID: Int
    var Version: String
    var LastSyncConfiguration: Date
    var LastSyncData: Date
    var LastUpdate: Date
    
    //MARK: Initialization
    init?(AssetSoftwareInfo_ID: Int, Asset_ID: Int, Software_ID: Int, Version: String, LastSyncConfiguration: Date, LastSyncData: Date, LastUpdate: Date) {
        
        // Initialization fails if name is empty
        guard !Version.isEmpty else {
            return nil
        }
        
        // Initialization fails if AssetSoftwareInfo_ID is negative
        guard AssetSoftwareInfo_ID >= 0 else {
            return nil
        }
        
        // Initialization fails if Asset_ID is negative
        guard Asset_ID >= 0 else {
            return nil
        }
        
        // Initialization fails if Software_ID is negative
        guard Software_ID >= 0 else {
            return nil
        }
        
        self.AssetSoftwareInfo_ID = AssetSoftwareInfo_ID
        self.Asset_ID = Asset_ID
        self.Software_ID = Software_ID
        self.Version = Version
        self.LastSyncConfiguration = LastSyncConfiguration
        self.LastSyncData = LastSyncData
        self.LastUpdate = LastUpdate
    }
}
