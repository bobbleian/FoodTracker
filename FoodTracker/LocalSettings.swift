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
    
}

