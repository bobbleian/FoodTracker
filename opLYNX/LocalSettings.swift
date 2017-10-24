//
//  Asset.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite

class LocalSettings {

    //MARK: Database interface
    public static func loadSettingsValue(db: Connection, Key: String) throws -> String? {
        let LocalSettingsTable = Table("LocalSettings")
        let KeyExp = Expression<String>("Key")
        let ValueExp = Expression<String>("Value")
        
        for localValue in try db.prepare(LocalSettingsTable.select(ValueExp).filter(KeyExp == Key)) {
            return localValue[ValueExp]
        }
        return nil
    }
    
    
    public static func updateSettingsValue(db: Connection, Key: String, Value: String) throws {
        let LocalSettingsTable = Table("LocalSettings")
        let KeyExp = Expression<String>("Key")
        let ValueExp = Expression<String>("Value")
        
        // First try updating the entry
        if try db.run(LocalSettingsTable.filter(KeyExp == Key).update(ValueExp <- Value)) == 0 {
            // No records updated, try an insert
            try db.run(LocalSettingsTable.insert(KeyExp <- Key, ValueExp <- Value))
        }
    }
    
}

