//
//  Asset.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite

class OFLinkUser {
    
    //MARK: Properties
    var OFNumber: String
    var OLUser_ID: Int
    
    //MARK: Initialization
    init?(OFNumber: String, OLUser_ID: Int) {
        
        // Initialization fails if OFNumber is empty
        guard !OFNumber.isEmpty else {
            return nil
        }
        
        // Initialization fails if OFLinkType_ID is negative
        guard OLUser_ID >= 0 else {
            return nil
        }
        
        self.OFNumber = OFNumber
        self.OLUser_ID = OLUser_ID
        
    }
    
    
    //MARK: Database interface
    public func insertOFLinkUser(db: Connection) throws {
        let OFLinkRunTable = Table("OFLinkUser")
        let OFNumberExp = Expression<String>("OFNumber")
        let OLUser_IDExp = Expression<Int64>("OLUser_ID")
        
        // Try an insert
        try db.run(OFLinkRunTable.insert(OFNumberExp <- OFNumber, OLUser_IDExp <- Int64(OLUser_ID)))
    }
    
}
