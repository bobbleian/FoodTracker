//
//  OperationalForm.swift
//
//  Created by oplynx developer on 2017-08-21.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import SQLite
import CoreLocation

class OperationalForm: Hashable {
    
    //MARK: Static Properties
    static let OF_STATUS_CREATED = 1
    static let OF_STATUS_COMPLETE = 2
    static let OF_STATUS_INPROGRESS = 6
    
    static let OF_D13_MANDATORY_ELEMENT_IDSOLD = [
        150, 160, 156, 157, 161, 162, 163, 187, 188, 172, 173, 174, 175, 177, 178, 189, 190, 191, 192, 165,
        166, 167, 168, 179, 170, 164, 171, 183, 184, 185
    ]
    
    static let OF_D13_MANDATORY_ELEMENT_IDS = [
        156, 157, 169,                                   // General
        161, 182, 162, 163, 181,195, 193,                // Site
        172, 173, 174, 177, 178, 189, 190, 191, 192,     // Equip
        165, 166, 167, 168,                              // Valves
        179, 170, 164, 171, 183, 184, 185                // Pressure
    ]
    public static let OF_D13_GPS_LOCATION_ELEMENT_ID = 201
    
    public static let OF_TYPE_ID_D13 = 6
    
    //MARK: Properties
    var key1: String = ""
    var key2: String = ""
    var key3: String = ""
    
    var formLocation: CLLocation?
    
    //MARK: Official opLYNX Properties
    var OFNumber: String
    var Operational_Date: Date
    var Asset_ID: Int
    var UniqueOFNumber: Int
    var OFType_ID: Int
    var OFStatus_ID: Int
    var Due_Date: Date
    var Create_Date: Date
    var Complete_Date: Date
    var CreateUser_ID: Int
    var CompleteUser_ID: Int
    var Comments: String
    var LastUpdate: Date
    var Dirty: Bool
    
    var ElementData = [OFElementData]()
    var LinkRun = [OFLinkRun]()
    var LinkUser = [OFLinkUser]()
    var LinkOperationalForm = [OFLinkOperationalForm]()
    var LinkMedia = [OFLinkMedia]()
    
    //MARK: Initialization
    init?(OFNumber: String, Operational_Date: Date, Asset_ID: Int, UniqueOFNumber: Int, OFType_ID: Int, OFStatus_ID: Int, Due_Date: Date, Create_Date: Date, Complete_Date: Date, CreateUser_ID: Int, CompleteUser_ID: Int, Comments: String, LastUpdate: Date, Dirty: Bool) {
        
        // Initialization fails if name is empty
        guard !OFNumber.isEmpty else {
            return nil
        }
        
        // Initialization fails if OFType_ID is out of range
        guard OFType_ID >= 0 else {
            return nil
        }
        
        self.OFNumber = OFNumber
        self.Operational_Date = Operational_Date
        self.Asset_ID = Asset_ID
        self.UniqueOFNumber = UniqueOFNumber
        self.OFType_ID = OFType_ID
        self.OFStatus_ID = OFStatus_ID
        self.Due_Date = Due_Date
        self.Create_Date = Create_Date
        self.Complete_Date = Complete_Date
        self.CreateUser_ID = CreateUser_ID
        self.CompleteUser_ID = CompleteUser_ID
        self.Comments = Comments
        self.LastUpdate = LastUpdate
        self.Dirty = Dirty
        
    }
    
    //MARK: Utility functions
    func isD13FormComplete() -> Bool {
        for ofElement_ID in OperationalForm.OF_D13_MANDATORY_ELEMENT_IDS {
            guard let elementData = ElementData.first(where: { $0.OFElement_ID == ofElement_ID }), !elementData.Value.isEmpty else {
                return false
            }
        }
        return true
    }
    
    //MARK: Database interface
    public func insertOrUpdateDB(db: Connection) throws {
        
        // SQLLite table properties
        let OperationalFormTable = Table("OperationalForm")
        let OFNumber = Expression<String>("OFNumber")
        let Operational_Date = Expression<Date>("Operational_Date")
        let Asset_ID = Expression<Int>("Asset_ID")
        let UniqueOFNumber = Expression<Int>("UniqueOFNumber")
        let OFType_ID = Expression<Int>("OFType_ID")
        let OFStatus_ID = Expression<Int>("OFStatus_ID")
        let Due_Date = Expression<Date>("Due_Date")
        let Create_Date = Expression<Date>("Create_Date")
        let Complete_Date = Expression<Date>("Complete_Date")
        let CreateUser_ID = Expression<Int>("CreateUser_ID")
        let CompleteUser_ID = Expression<Int>("CompleteUser_ID")
        let Comments = Expression<String>("Comments")
        let LastUpdate = Expression<Date>("LastUpdate")
        let Dirty = Expression<Bool>("Dirty")
        
        // First try updating the entry
        if try db.run(OperationalFormTable.filter(OFNumber == self.OFNumber).update(
            Operational_Date <- self.Operational_Date,
            Asset_ID <- self.Asset_ID,
            UniqueOFNumber <- self.UniqueOFNumber,
            OFType_ID <- self.OFType_ID,
            OFStatus_ID <- self.OFStatus_ID,
            Due_Date <- self.Due_Date,
            Create_Date <- self.Create_Date,
            Complete_Date <- self.Complete_Date,
            CreateUser_ID <- self.CreateUser_ID,
            CompleteUser_ID <- self.CompleteUser_ID,
            Comments <- self.Comments,
            LastUpdate <- self.LastUpdate,
            Dirty <- Dirty)) == 0 {
            // No records updated, try an insert
            try db.run(OperationalFormTable.insert(OFNumber <- self.OFNumber,
                                                   Operational_Date <- self.Operational_Date,
                                                   Asset_ID <- self.Asset_ID,
                                                   UniqueOFNumber <- self.UniqueOFNumber,
                                                   OFType_ID <- self.OFType_ID,
                                                   OFStatus_ID <- self.OFStatus_ID,
                                                   Due_Date <- self.Due_Date,
                                                   Create_Date <- self.Create_Date,
                                                   Complete_Date <- self.Complete_Date,
                                                   CreateUser_ID <- self.CreateUser_ID,
                                                   CompleteUser_ID <- self.CompleteUser_ID,
                                                   Comments <- self.Comments,
                                                   LastUpdate <- self.LastUpdate,
                                                   Dirty <- self.Dirty))
        }
    }
    
    
    public func insertDB(db: Connection) throws {
        
        // SQLLite table properties
        let OperationalFormTable = Table("OperationalForm")
        let OFNumber = Expression<String>("OFNumber")
        let Operational_Date = Expression<Date>("Operational_Date")
        let Asset_ID = Expression<Int>("Asset_ID")
        let UniqueOFNumber = Expression<Int>("UniqueOFNumber")
        let OFType_ID = Expression<Int>("OFType_ID")
        let OFStatus_ID = Expression<Int>("OFStatus_ID")
        let Due_Date = Expression<Date>("Due_Date")
        let Create_Date = Expression<Date>("Create_Date")
        let Complete_Date = Expression<Date>("Complete_Date")
        let CreateUser_ID = Expression<Int>("CreateUser_ID")
        let CompleteUser_ID = Expression<Int>("CompleteUser_ID")
        let Comments = Expression<String>("Comments")
        let LastUpdate = Expression<Date>("LastUpdate")
        let Dirty = Expression<Bool>("Dirty")
        
        // Attempt to insert the record
        try db.run(OperationalFormTable.insert(OFNumber <- self.OFNumber,
            Operational_Date <- self.Operational_Date,
            Asset_ID <- self.Asset_ID,
            UniqueOFNumber <- self.UniqueOFNumber,
            OFType_ID <- self.OFType_ID,
            OFStatus_ID <- self.OFStatus_ID,
            Due_Date <- self.Due_Date,
            Create_Date <- self.Create_Date,
            Complete_Date <- self.Complete_Date,
            CreateUser_ID <- self.CreateUser_ID,
            CompleteUser_ID <- self.CompleteUser_ID,
            Comments <- self.Comments,
            LastUpdate <- self.LastUpdate,
            Dirty <- self.Dirty))
    }
    
    public static func loadOperationalFormsFromDB(db: Connection) throws -> [OperationalForm] {
        var operationalForms = [OperationalForm]()
        let OperationalFormTable = Table("OperationalForm")
        let OFNumber = Expression<String>("OFNumber")
        let Operational_Date = Expression<Date>("Operational_Date")
        let Asset_ID = Expression<Int>("Asset_ID")
        let UniqueOFNumber = Expression<Int>("UniqueOFNumber")
        let OFType_ID = Expression<Int>("OFType_ID")
        let OFStatus_ID = Expression<Int>("OFStatus_ID")
        let Due_Date = Expression<Date>("Due_Date")
        let Create_Date = Expression<Date>("Create_Date")
        let Complete_Date = Expression<Date>("Complete_Date")
        let CreateUser_ID = Expression<Int>("CreateUser_ID")
        let CompleteUser_ID = Expression<Int>("CompleteUser_ID")
        let Comments = Expression<String>("Comments")
        let LastUpdate = Expression<Date>("LastUpdate")
        let Dirty = Expression<Bool>("Dirty")
        
        for operationalFormRecord in try db.prepare(OperationalFormTable.order(Due_Date)) {
            if let operationalForm = OperationalForm(
                OFNumber: operationalFormRecord[OFNumber],
                Operational_Date: operationalFormRecord[Operational_Date],
                Asset_ID: operationalFormRecord[Asset_ID],
                UniqueOFNumber: operationalFormRecord[UniqueOFNumber],
                OFType_ID: operationalFormRecord[OFType_ID],
                OFStatus_ID: operationalFormRecord[OFStatus_ID],
                Due_Date: operationalFormRecord[Due_Date],
                Create_Date: operationalFormRecord[Create_Date],
                Complete_Date: operationalFormRecord[Complete_Date],
                CreateUser_ID: operationalFormRecord[CreateUser_ID],
                CompleteUser_ID: operationalFormRecord[CompleteUser_ID],
                Comments: operationalFormRecord[Comments],
                LastUpdate: operationalFormRecord[LastUpdate],
                Dirty: operationalFormRecord[Dirty]) {
                operationalForms += [operationalForm]
            }
            else {
                // TODO: Error message?
            }
        }
        return operationalForms
    }
    
    public static func loadDirtyOperationalFormsFromDB(db: Connection) throws -> [OperationalForm] {
        var operationalForms = [OperationalForm]()
        let OperationalFormTable = Table("OperationalForm")
        let OFNumber = Expression<String>("OFNumber")
        let Operational_Date = Expression<Date>("Operational_Date")
        let Asset_ID = Expression<Int>("Asset_ID")
        let UniqueOFNumber = Expression<Int>("UniqueOFNumber")
        let OFType_ID = Expression<Int>("OFType_ID")
        let OFStatus_ID = Expression<Int>("OFStatus_ID")
        let Due_Date = Expression<Date>("Due_Date")
        let Create_Date = Expression<Date>("Create_Date")
        let Complete_Date = Expression<Date>("Complete_Date")
        let CreateUser_ID = Expression<Int>("CreateUser_ID")
        let CompleteUser_ID = Expression<Int>("CompleteUser_ID")
        let Comments = Expression<String>("Comments")
        let LastUpdate = Expression<Date>("LastUpdate")
        let Dirty = Expression<Bool>("Dirty")
        
        for operationalFormRecord in try db.prepare(OperationalFormTable.filter(Dirty == true)) {
            if let operationalForm = OperationalForm(
                OFNumber: operationalFormRecord[OFNumber],
                Operational_Date: operationalFormRecord[Operational_Date],
                Asset_ID: operationalFormRecord[Asset_ID],
                UniqueOFNumber: operationalFormRecord[UniqueOFNumber],
                OFType_ID: operationalFormRecord[OFType_ID],
                OFStatus_ID: operationalFormRecord[OFStatus_ID],
                Due_Date: operationalFormRecord[Due_Date],
                Create_Date: operationalFormRecord[Create_Date],
                Complete_Date: operationalFormRecord[Complete_Date],
                CreateUser_ID: operationalFormRecord[CreateUser_ID],
                CompleteUser_ID: operationalFormRecord[CompleteUser_ID],
                Comments: operationalFormRecord[Comments],
                LastUpdate: operationalFormRecord[LastUpdate],
                Dirty: operationalFormRecord[Dirty]) {
                operationalForms += [operationalForm]
            }
            else {
                // TODO: Error message?
            }
        }
        return operationalForms
    }
    
    public static func loadOperationalFormsWithKeysFromDB(db: Connection) throws -> [OperationalForm] {
        let operationalForms = try OperationalForm.loadOperationalFormsFromDB(db: db)
        
        // Load key values from OFElementData table
        for operationalForm in operationalForms {
            let key1Value = try OFElementData.loadOFElementValue(db: db, OFNumber: operationalForm.OFNumber, OFElement_ID: 148)
            operationalForm.key1 = key1Value
            let key2Value = try OFElementData.loadOFElementValue(db: db, OFNumber: operationalForm.OFNumber, OFElement_ID: 149)
            operationalForm.key2 = key2Value
            let key3Value = try OFElementData.loadOFElementValue(db: db, OFNumber: operationalForm.OFNumber, OFElement_ID: 151)
            operationalForm.key3 = key3Value
            
            // Get the GSP location
            if let gpsLocation = try? OFElementData.loadOFElementValue(db: db, OFNumber: operationalForm.OFNumber, OFElement_ID: OperationalForm.OF_D13_GPS_LOCATION_ELEMENT_ID) {
                let gpsComponents = gpsLocation.components(separatedBy: ";")
                if gpsComponents.count >= 2 {
                    if let gpsLatitude = Double(gpsComponents[0]), let gpsLongitude = Double(gpsComponents[1]) {
                        operationalForm.formLocation = CLLocation(latitude: gpsLatitude, longitude: gpsLongitude)
                    }
                }
            }
        }
        return operationalForms
    }
    
    // Returns a list of all locally stored OFNumbers grouped by Operational Date
    public static func loadOFListByOperationalDate(db: Connection) throws -> [Date: [String]] {
        var ofList = [Date: [String]]()
        
        let OperationalFormTable = Table("OperationalForm")
        let OFNumberExp = Expression<String>("OFNumber")
        let Operational_DateExp = Expression<Date>("Operational_Date")
        
        for ofRecord in try db.prepare(OperationalFormTable.select(Operational_DateExp, OFNumberExp).order(Operational_DateExp)) {
            let operationalDate = ofRecord[Operational_DateExp]
            let ofNumber = ofRecord[OFNumberExp]
            if !ofList.keys.contains(operationalDate) {
                ofList[operationalDate] = [String]()
            }
            ofList[operationalDate]?.append(ofNumber)
        }
        
        return ofList
    }
    
    public static func deleteOF(db: Connection, OFNumber: String) throws {
        let OperationalFormTable = Table("OperationalForm")
        let OFNumberExp = Expression<String>("OFNumber")
        try db.run(OperationalFormTable.filter(OFNumberExp == OFNumber).delete())
    }
    
    // Mark Form as DIRTY so it is part of the list of Forms to be sent to the server on a data sync
    public static func updateOFDirty(db: Connection, OFNumber: String, Dirty: Bool) throws {
        let OperationalFormTable = Table("OperationalForm")
        let OFNumberExp = Expression<String>("OFNumber")
        let DirtyExp = Expression<Bool>("Dirty")
        try db.run(OperationalFormTable.filter(OFNumberExp == OFNumber).update(DirtyExp <- Dirty))
    }
    
    // Update Form's Status
    public static func updateOFStatus(db: Connection, OFNumber: String, OFStatus_ID: Int) throws {
        let OperationalFormTable = Table("OperationalForm")
        let OFNumberExp = Expression<String>("OFNumber")
        let OFStatus_IDExp = Expression<Int>("OFStatus_ID")
        let Complete_DateExp = Expression<Date>("Complete_Date")
        let CompleteUser_IDExp = Expression<Int>("CompleteUser_ID")
        
        let Complete_Date = OFStatus_ID == OperationalForm.OF_STATUS_COMPLETE ? Date() : Date(timeIntervalSinceReferenceDate: -31557600)
        let CompleteUser_ID = OFStatus_ID == OperationalForm.OF_STATUS_COMPLETE ? Authorize.CURRENT_USER!.OLUser_ID : 0
        
        try db.run(OperationalFormTable.filter(OFNumberExp == OFNumber).update(OFStatus_IDExp <- OFStatus_ID, Complete_DateExp <- Complete_Date, CompleteUser_IDExp <- CompleteUser_ID))
        
    }
    
    //MARK: Hashable protocal
    var hashValue: Int {
        return OFNumber.hashValue
    }
    
    static func == (lhs: OperationalForm, rhs: OperationalForm) -> Bool {
        return lhs.OFNumber == rhs.OFNumber
    }
    
    
    //MARK: Osono Data Interface
    public func convertToOsono() -> [String: Any] {
        var result = [String: Any]()
        result["ofn"] = OFNumber
        result["od"] = Operational_Date.formatJsonDate()
        result["ai"] = String(Asset_ID)
        result["uofn"] = UniqueOFNumber
        result["oti"] = String(OFType_ID)
        result["osi"] = String(OFStatus_ID)
        result["dd"] = Due_Date.formatJsonDate()
        result["cd"] = Create_Date.formatJsonDate()
        result["cpd"] = Complete_Date.formatJsonDate()
        result["cui"] = String(CreateUser_ID)
        result["cpui"] = String(CompleteUser_ID)
        result["com"] = Comments
        
        result["da"] = ElementData.map { $0.convertToOsono() }
        result["lrl"] = LinkRun.map { $0.convertToOsono() }
        result["lul"] = LinkUser.map { $0.convertToOsono() }
        result["lofl"] = LinkOperationalForm.map { $0.convertToOsono() }
        result["lml"] = LinkMedia.map { $0.convertToOsono() }
        
        return result
    }
    
    
}
