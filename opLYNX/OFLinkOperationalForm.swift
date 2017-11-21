//
//  Asset.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite

class OFLinkOperationalForm {
    
    //MARK: Properties
    var OFNumber: String
    var LinkOFNumber: String
    var OFLinkType_ID: Int
    
    //MARK: Initialization
    init?(OFNumber: String, LinkOFNumber: String, OFLinkType_ID: Int) {
        
        // Initialization fails if OFNumber is empty
        guard !OFNumber.isEmpty else {
            return nil
        }
        
        // Initialization fails if LinkOFNumber is empty
        guard !LinkOFNumber.isEmpty else {
            return nil
        }
        
        // Initialization fails if OFLinkType_ID is negative
        guard OFLinkType_ID >= 0 else {
            return nil
        }
        
        self.OFNumber = OFNumber
        self.LinkOFNumber = LinkOFNumber
        self.OFLinkType_ID = OFLinkType_ID
        
    }
    
    
    //MARK: Database interface
    public func insertOFLinkOperationalForm(db: Connection) throws {
        let OFLinkOperationalFormTable = Table("OFLinkOperationalForm")
        let OFNumberExp = Expression<String>("OFNumber")
        let LinkOFNumberExp = Expression<String>("LinkOFNumber")
        let OFLinkType_IDExp = Expression<Int64>("OFLinkType_ID")
        
        // Try an insert
        try db.run(OFLinkOperationalFormTable.insert(OFNumberExp <- OFNumber, LinkOFNumberExp <- LinkOFNumber, OFLinkType_IDExp <- Int64(OFLinkType_ID)))
    }
    
}
