//
//  Asset.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite

class AssetSoftwareInfo {
    
    //MARK: Static Properties
    static let SOFTWARE_ID = 101
    
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
    
    //MARK: Osono Data Interface
    public func convertToOsono() -> [String: Any] {
        var result = [String: Any]()
        result["id"] = String(AssetSoftwareInfo_ID)
        result["aid"] = String(Asset_ID)
        result["sid"] = String(Software_ID)
        result["ver"] = Version
        result["lsc"] = LastSyncConfiguration.formatJsonDate()
        result["lsd"] = LastSyncData.formatJsonDate()
        return result
    }
    
    
    //MARK: Database interface
    public func updateDB(db: Connection) throws {
        let AssetSoftwareInfoTable = Table("AssetSoftwareInfo")
        let AssetSoftwareInfo_IDExp = Expression<Int64>("AssetSoftwareInfo_ID")
        let Asset_IDExp = Expression<Int64>("Asset_ID")
        let Software_IDExp = Expression<Int64>("Software_ID")
        let VersionExp = Expression<String>("Version")
        let LastSyncConfigurationExp = Expression<Date>("LastSyncConfiguration")
        let LastSyncDataExp = Expression<Date>("LastSyncData")
        let LastUpdateExp = Expression<Date>("LastUpdate")
        
        // First try updating the entry
        if try db.run(AssetSoftwareInfoTable.filter(AssetSoftwareInfo_IDExp == Int64(AssetSoftwareInfo_ID)).update(AssetSoftwareInfo_IDExp <- Int64(AssetSoftwareInfo_ID),
                                                                                  Asset_IDExp <- Int64(Asset_ID),
                                                                                  Software_IDExp <- Int64(Software_ID),
                                                                                  VersionExp <- Version,
                                                                                  LastSyncConfigurationExp <- LastSyncConfiguration,
                                                                                  LastSyncDataExp <- LastSyncData,
                                                                                  LastUpdateExp <- LastUpdate)) == 0 {
            // No records updated, try an insert
            try db.run(AssetSoftwareInfoTable.insert(AssetSoftwareInfo_IDExp <- Int64(AssetSoftwareInfo_ID),
                                          AssetSoftwareInfo_IDExp <- Int64(AssetSoftwareInfo_ID),
                                          Asset_IDExp <- Int64(Asset_ID),
                                          Software_IDExp <- Int64(Software_ID),
                                          VersionExp <- Version,
                                          LastSyncConfigurationExp <- LastSyncConfiguration,
                                          LastSyncDataExp <- LastSyncData,
                                          LastUpdateExp <- LastUpdate))
        }
    }
}
