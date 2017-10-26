//
//  Asset.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite

class OFElementData {
    
    //MARK: Properties
    var OFNumber: String
    var OFElement_ID: Int
    var Value: String
    
    //MARK: Initialization
    init?(OFNumber: String, OFElement_ID: Int, Value: String) {
        
        // Initialization fails if name is empty
        guard !OFNumber.isEmpty else {
            return nil
        }
        
        // Initialization fails if Asset_ID is negative
        guard OFElement_ID >= 0 else {
            return nil
        }
        
        self.OFNumber = OFNumber
        self.OFElement_ID = OFElement_ID
        self.Value = Value
    }
    
    
    //MARK: Database interface
    public static func loadOFElementValue(db: Connection, OFNumber: String, OFElement_ID: Int) throws -> String {
        let OFElementDataTable = Table("OFElementData")
        let OFNumberExp = Expression<String>("OFNumber")
        let OFElement_IDExp = Expression<Int64>("OFElement_ID")
        let ValueExp = Expression<String>("Value")
        
        for ofElementValue in try db.prepare(OFElementDataTable.select(ValueExp).filter(OFNumberExp == OFNumber).filter(OFElement_IDExp == Int64(OFElement_ID))) {
            return ofElementValue[ValueExp]
        }
        return ""
    }
    
    public static func updateOFElementValue(db: Connection, OFNumber: String, OFElement_ID: Int, Value: String) throws {
        let OFElementDataTable = Table("OFElementData")
        let OFNumberExp = Expression<String>("OFNumber")
        let OFElement_IDExp = Expression<Int64>("OFElement_ID")
        let ValueExp = Expression<String>("Value")
        
        try db.run(OFElementDataTable.filter(OFNumberExp == OFNumber && OFElement_IDExp == Int64(OFElement_ID)).update(ValueExp <- Value))
    }
    
}
