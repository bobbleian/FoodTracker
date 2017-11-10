//
//  Asset.swift
//  opLYNX
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
    public static func loadActiveRuns(db: Connection) throws -> [Run] {
        
        // Array of Runs
        var runs = [Run]()
        
        // SQLLite table properties
        let RunTable = Table("Run")
        let Run_IDExp = Expression<Int64>("Run_ID")
        let NameExp = Expression<String>("Name")
        let DescriptionExp = Expression<String>("Description")
        let ActiveExp = Expression<Bool>("Active")
        let LastUpdateExp = Expression<Date>("LastUpdate")
        
        
        for runRecord in try db.prepare(RunTable.filter(ActiveExp == true)) {
            guard let run = Run(
                Run_ID: Int(exactly: runRecord[Run_IDExp]) ?? 0,
                Name: runRecord[NameExp],
                Description: runRecord[DescriptionExp],
                Active: true,
                LastUpdate: Date())
                //TODO: restore once database format has been updated LastUpdate: runRecord[LastUpdateExp])
            else {
                fatalError("Unable to load run from database")
            }
            runs += [run]
        }
        
        return runs
    }
    
    
    //MARK: Database interface
    public func updateDB(db: Connection) throws {
        
        // SQLLite table properties
        let RunTable = Table("Run")
        let Run_IDExp = Expression<Int64>("Run_ID")
        let NameExp = Expression<String>("Name")
        let DescriptionExp = Expression<String>("Description")
        let ActiveExp = Expression<Bool>("Active")
        let LastUpdateExp = Expression<Date>("LastUpdate")
        
        // First try updating the entry
        if try db.run(RunTable.filter(Run_IDExp == Int64(Run_ID)).update(
                                        NameExp <- Name,
                                        DescriptionExp <- Description,
                                        ActiveExp <- Active,
                                        LastUpdateExp <- LastUpdate)) == 0 {
            // No records updated, try an insert
            try db.run(RunTable.insert(Run_IDExp <- Int64(Run_ID),
                                        NameExp <- Name,
                                        DescriptionExp <- Description,
                                        ActiveExp <- Active,
                                        LastUpdateExp <- LastUpdate))
        }
    }
    
}

