//
//  Database.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-17.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite

class Database {
    
    static func DB() throws -> Connection {
        let dbFile = try makeWritableCopy(named: "oplynx.db", ofResourceFile: "oplynx.db")
        let db = try Connection(dbFile.path)
        return db
    }
    
    // Utility function to move a resource file from one location to another
    public class func makeWritableCopy(named destFileName: String, ofResourceFile originalFileName: String) throws -> URL {
        // Get Documents directory in app bundle
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError("No document directory found in application bundle.")
        }
        
        // Get URL for dest file (in Documents directory)
        let writableFileURL = documentsDirectory.appendingPathComponent(destFileName)
        
        // If dest file doesn’t exist yet
        if (try? writableFileURL.checkResourceIsReachable()) == nil {
            // Get original (unwritable) file’s URL
            guard let originalFileURL = Bundle.main.url(forResource: originalFileName, withExtension: nil) else {
                fatalError("Cannot find original file “\(originalFileName)” in application bundle’s resources.")
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

