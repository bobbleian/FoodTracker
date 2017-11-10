//
//  Asset.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite

class Asset {
    
    //MARK: Properties
    var Asset_ID: Int
    var Name: String
    var LastUpdate: Date
    
    //MARK: Initialization
    init?(Asset_ID: Int, Name: String, LastUpdate: Date) {
        
        // Initialization fails if name is empty
        guard !Name.isEmpty else {
            return nil
        }
        
        // Initialization fails if Asset_ID is negative
        guard Asset_ID >= 0 else {
            return nil
        }
        
        self.Asset_ID = Asset_ID
        self.Name = Name
        self.LastUpdate = LastUpdate
    }    
    
    //MARK: Database interface
    public static func loadAsset(db: Connection) throws -> Asset? {
        let AssetTable = Table("Asset")
        let Asset_IDExp = Expression<Int64>("Asset_ID")
        let NameExp = Expression<String>("Name")
        let LastUpdateExp = Expression<Date>("LastUpdate")
        
        for assetRecord in try db.prepare(AssetTable) {
            return Asset(Asset_ID: Int(assetRecord[Asset_IDExp]), Name: assetRecord[NameExp], LastUpdate: assetRecord[LastUpdateExp])
        }
        return nil
    }
    
    public static func updateAsset(db: Connection, Asset_ID: Int, Name: String) throws {
        let AssetTable = Table("Asset")
        let Asset_IDExp = Expression<Int64>("Asset_ID")
        let NameExp = Expression<String>("Name")
        let LastUpdateExp = Expression<Date>("LastUpdate")
        
        // First try updating the entry
        if try db.run(AssetTable.filter(Asset_IDExp == Int64(Asset_ID)).update(NameExp <- Name, LastUpdateExp <- Date())) == 0 {
            // No records updated, try an insert
            try db.run(AssetTable.insert(Asset_IDExp <- Int64(Asset_ID), NameExp <- Name, LastUpdateExp <- Date()))
        }
    }
    
    public static func deleteAllAsset(db: Connection) throws {
        let AssetTable = Table("Asset")
        
        // Delete all records
        try db.run(AssetTable.delete())
    }
}
