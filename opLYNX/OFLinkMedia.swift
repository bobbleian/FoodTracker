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
    
    // Load all OF Link Media for a Form
    public static func loadOFLinkMedia(db: Connection, OFNumber: String) throws -> [OFLinkMedia] {
        var result = [OFLinkMedia]()
        let OFLinkMediaTable = Table("OFLinkMedia")
        let OFNumberExp = Expression<String>("OFNumber")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let OFElement_IDExp = Expression<Int>("OFElement_ID")
        let SortOrderExp = Expression<Int>("SortOrder")
        
        for row in try db.prepare(OFLinkMediaTable.filter(OFNumberExp == OFNumber).order(SortOrderExp)) {
            if let ofLinkMedia = OFLinkMedia(OFNumber: OFNumber, MediaNumber: row[MediaNumberExp], OFElement_ID: row[OFElement_IDExp], SortOrder: row[SortOrderExp]) {
                result.append(ofLinkMedia)
            }
        }
        return result
    }
    
    // Load all OF Link Media for an Element
    public static func loadOFLinkMedia(db: Connection, OFNumber: String, OFElement_ID: Int) throws -> [OFLinkMedia] {
        var result = [OFLinkMedia]()
        let OFLinkMediaTable = Table("OFLinkMedia")
        let OFNumberExp = Expression<String>("OFNumber")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let OFElement_IDExp = Expression<Int>("OFElement_ID")
        let SortOrderExp = Expression<Int>("SortOrder")
        
        for row in try db.prepare(OFLinkMediaTable.filter(OFNumberExp == OFNumber && OFElement_IDExp == OFElement_ID).order(SortOrderExp)) {
            if let ofLinkMedia = OFLinkMedia(OFNumber: OFNumber, MediaNumber: row[MediaNumberExp], OFElement_ID: row[OFElement_IDExp], SortOrder: row[SortOrderExp]) {
                result.append(ofLinkMedia)
            }
        }
        return result
    }
    
    // Load all OF Link Media for an Element
    public static func existsOFLinkMedia(db: Connection, OFNumber: String, OFElement_ID: Int) throws -> Bool {
        let OFLinkMediaTable = Table("OFLinkMedia")
        let OFNumberExp = Expression<String>("OFNumber")
        let OFElement_IDExp = Expression<Int>("OFElement_ID")
        
        if let row = try db.pluck(OFLinkMediaTable.filter(OFNumberExp == OFNumber && OFElement_IDExp == OFElement_ID)) {
            return true
        }
        return false
    }
    
    // Delete OFLinkMedia record
    public func deleteFromDB(db: Connection) throws {
        let OFLinkMediaTable = Table("OFLinkMedia")
        let OFNumberExp = Expression<String>("OFNumber")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let OFElement_IDExp = Expression<Int>("OFElement_ID")
        
        try db.run(OFLinkMediaTable.filter(OFNumberExp == OFNumber && MediaNumberExp == MediaNumber && OFElement_IDExp == OFElement_ID).delete())
        
    }
    
    //MARK: Osono Data Interface
    public func convertToOsono() -> [String: Any] {
        var result = [String: Any]()
        result["ofn"] = OFNumber
        result["mn"] = MediaNumber
        result["ofe"] = String(OFElement_ID)
        result["so"] = String(SortOrder)
        return result
    }
    
}
