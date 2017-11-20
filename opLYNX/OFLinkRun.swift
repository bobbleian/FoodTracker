//
//  Asset.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite

class OFLinkRun {
    
    //MARK: Properties
    var OFNumber: String
    var Run_ID: Int
    
    //MARK: Initialization
    init?(OFNumber: String, Run_ID: Int) {
        
        // Initialization fails if OFNumber is empty
        guard !OFNumber.isEmpty else {
            return nil
        }
        
        // Initialization fails if OFLinkType_ID is negative
        guard Run_ID >= 0 else {
            return nil
        }
        
        self.OFNumber = OFNumber
        self.Run_ID = Run_ID
        
    }
    
    //MARK: Database interface
    public func insertOFLinkRun(db: Connection) throws {
        let OFLinkRunTable = Table("OFLinkRun")
        let OFNumberExp = Expression<String>("OFNumber")
        let Run_IDExp = Expression<Int64>("Run_ID")
        
        // Try an insert
        try db.run(OFLinkRunTable.insert(OFNumberExp <- OFNumber, Run_IDExp <- Int64(Run_ID)))
    }
    
    
}
