//
//  Database.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-17.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite
import os.log

class Database {
    
    static func DB() throws -> Connection {
        let dbFile = try makeWritableCopy(named: "oplynx.db", ofResourceFile: "oplynx.db")
        let db = try Connection(dbFile.path)
        db.foreignKeys = true
        return db
    }
    
    // Utility function to move a resource file from one location to another
    public class func makeWritableCopy(named destFileName: String, ofResourceFile originalFileName: String) throws -> URL {
        // Get Documents directory in app bundle
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            os_log("No document directory found in application bundle.", log: OSLog.default, type: .error)
            throw OsonoError.Message("No document directory found in application bundle")
        }
        
        // Get URL for dest file (in Documents directory)
        let writableFileURL = documentsDirectory.appendingPathComponent(destFileName)
        
        // If dest file doesn’t exist yet
        if (try? writableFileURL.checkResourceIsReachable()) == nil {
            // Get original (unwritable) file’s URL
            guard let originalFileURL = Bundle.main.url(forResource: originalFileName, withExtension: nil) else {
                os_log("Cannot find original file %s in application bundle’s resources.", log: OSLog.default, type: .error, originalFileName)
                throw OsonoError.Message("No document directory found in application bundle")
            }
            
            // Get original file’s contents
            let originalContents = try Data(contentsOf: originalFileURL)
            
            // Write original file’s contents to dest file
            try originalContents.write(to: writableFileURL, options: .atomic)
            print("Made a writable copy of file “\(originalFileName)” in “\(documentsDirectory)\\\(destFileName)”.")
            
        }
        
        // Return dest file URL
        return writableFileURL
    }
    
}

extension Connection {
    
    // Set the foreign_keys PRAGMA for SQLite so foreign key contraints are enforced
    public var foreignKeys: Bool {
        get {
            return Int32(try! scalar("PRAGMA foreign_keys") as! Int64) != 0
        }
        set {
            try! run("PRAGMA foreign_keys = " + (newValue ? "ON" : "OFF"))
        }
    }
}

