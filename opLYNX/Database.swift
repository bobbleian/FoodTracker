//
//  Database.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-17.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite

class Database {
    
    static func DB() throws -> Connection {
        let dbFile = try MealTableViewController.makeWritableCopy(named: "oplynx.db", ofResourceFile: "oplynx.db")
        let db = try Connection(dbFile.path)
        return db
    }
}

