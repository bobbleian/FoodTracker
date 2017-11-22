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
    
    //MARK: Static Properties
    public static let OF_ELEMENT_ID_GPS_LOCATION = 201
    
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
    
    // Load all OF Element values for a Form
    public static func loadOFElementValue(db: Connection, OFNumber: String) throws -> [OFElementData] {
        var result = [OFElementData]()
        let OFElementDataTable = Table("OFElementData")
        let OFNumberExp = Expression<String>("OFNumber")
        let OFElement_IDExp = Expression<Int>("OFElement_ID")
        let ValueExp = Expression<String>("Value")
        
        for row in try db.prepare(OFElementDataTable.filter(OFNumberExp == OFNumber)) {
            if let ofElementData = OFElementData(OFNumber: OFNumber, OFElement_ID: row[OFElement_IDExp], Value: row[ValueExp]) {
                result.append(ofElementData)
            }
        }
        return result
    }
    
    public func insertOrUpdatepdateOFElementValue(db: Connection) throws {
        let OFElementDataTable = Table("OFElementData")
        let OFNumberExp = Expression<String>("OFNumber")
        let OFElement_IDExp = Expression<Int64>("OFElement_ID")
        let ValueExp = Expression<String>("Value")
        
        // First try updating the entry
        if try db.run(OFElementDataTable.filter(OFNumberExp == OFNumber && OFElement_IDExp == Int64(OFElement_ID)).update(ValueExp <- Value)) == 0 {
            // No records updated, try an insert
            try db.run(OFElementDataTable.insert(OFNumberExp <- OFNumber, OFElement_IDExp <- Int64(OFElement_ID), ValueExp <- Value))
        }
    }
    
    public func insertOFElementValue(db: Connection) throws {
        let OFElementDataTable = Table("OFElementData")
        let OFNumberExp = Expression<String>("OFNumber")
        let OFElement_IDExp = Expression<Int64>("OFElement_ID")
        let ValueExp = Expression<String>("Value")
        
        // Attempt to insert the record
        try db.run(OFElementDataTable.insert(OFNumberExp <- OFNumber, OFElement_IDExp <- Int64(OFElement_ID), ValueExp <- Value))
    }
    
    //MARK: Osono Data Interface
    public func convertToOsono() -> [String: Any] {
        var result = [String: Any]()
        result["e"] = String(OFElement_ID)
        result["v"] = Value
        return result
    }
    
}
