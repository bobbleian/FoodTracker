//
//  Asset.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite

class OFLinkMedia {
    
    //MARK: Properties
    var OFNumber: String
    var MediaNumber: String
    var OFElement_ID: Int
    var SortOrder: Int
    
    //MARK: Initialization
    init?(OFNumber: String, MediaNumber: String, OFElement_ID: Int, SortOrder: Int) {
        
        // Initialization fails if OFNumber is empty
        guard !OFNumber.isEmpty else {
            return nil
        }
        
        // Initialization fails if MediaNumber is empty
        guard !MediaNumber.isEmpty else {
            return nil
        }
        
        // Initialization fails if OFElement_ID is negative
        guard OFElement_ID >= 0 else {
            return nil
        }
        
        // Initialization fails if SortOrder is negative
        guard SortOrder >= 0 else {
            return nil
        }
        
        self.OFNumber = OFNumber
        self.MediaNumber = MediaNumber
        self.OFElement_ID = OFElement_ID
        self.SortOrder = SortOrder
    }
    
    
    //MARK: Database interface
    public static func insertMediaToDB(db: Connection, MediaNumber: String, OFNumber: String, OFElement_ID: Int, SortOrder: Int) throws {
        let OFLinkMediaTable = Table("OFLinkMedia")
        let OFNumberExp = Expression<String>("OFNumber")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let OFElement_IDExp = Expression<Int64>("OFElement_ID")
        let SortOrderExp = Expression<Int64>("SortOrder")
        
        try db.run(OFLinkMediaTable.insert(OFNumberExp <- OFNumber,
                                           MediaNumberExp <- MediaNumber,
                                           OFElement_IDExp <- Int64(OFElement_ID),
                                           SortOrderExp <- Int64(SortOrder)))
    }
    
    public func insertMediaToDB(db: Connection) throws {
        let OFLinkMediaTable = Table("OFLinkMedia")
        let OFNumberExp = Expression<String>("OFNumber")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let OFElement_IDExp = Expression<Int64>("OFElement_ID")
        let SortOrderExp = Expression<Int64>("SortOrder")
        
        try db.run(OFLinkMediaTable.insert(OFNumberExp <- OFNumber,
                                           MediaNumberExp <- MediaNumber,
                                           OFElement_IDExp <- Int64(OFElement_ID),
                                           SortOrderExp <- Int64(SortOrder)))
    }
}
