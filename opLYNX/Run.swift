//
//  Asset.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite

class Run {
    
    //MARK: Properties
    var Run_ID: Int
    var Name: String
    var Description: String
    var Active: Bool
    var LastUpdate: Date
    
    //MARK: Initialization
    init?(Run_ID: Int, Name: String, Description: String, Active: Bool, LastUpdate: Date) {
        
        // Initialization fails if name is empty
        guard !Name.isEmpty else {
            return nil
        }
        
        // Initialization fails if Run_ID is negative
        guard Run_ID >= 0 else {
            return nil
        }
        
        self.Run_ID = Run_ID
        self.Name = Name
        self.Description = Description
        self.Active = Active
        self.LastUpdate = LastUpdate
    }
    
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

