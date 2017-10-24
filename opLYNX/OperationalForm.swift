//
//  Meal.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-08-21.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import SQLite

class OperationalForm {
    //MARK: Properties
    var photo: UIImage?
    var type: String = "type"
    var key1: String = "key 1"
    var key2: String = "key 2"
    var key3: String = "key 3"
    
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
    
    
    //MARK: Initialization
    init?(OFNumber: String, photo: UIImage?, OFType_ID: Int, type: String, Due_Date: Date, key1: String, key2: String, key3: String) {
        
        // Initialization fails if name is empty
        guard !OFNumber.isEmpty else {
            return nil
        }
        
        // Initialization fails if OFType_ID is out of range
        guard OFType_ID >= 0 else {
            return nil
        }
        
        self.photo = photo
        self.type = type
        self.key1 = key1
        self.key2 = key2
        self.key3 = key3
        
        self.OFNumber = OFNumber
        self.Operational_Date = Date()
        self.Asset_ID = 0
        self.UniqueOFNumber = 0
        self.OFType_ID = OFType_ID
        self.OFStatus_ID = 0
        self.Due_Date = Due_Date
        self.Create_Date = Date()
        self.Complete_Date = Date()
        self.CreateUser_ID = 0
        self.CompleteUser_ID = 0
        self.Comments = ""
        self.LastUpdate = Date()
        self.Dirty = false
        
    }
    
    //MARK: Database interface
    
    public static func loadOperationalFormsFromDB(db: Connection) throws -> [OperationalForm] {
        var operationalForms = [OperationalForm]()
        let operationalFormTable = Table("OperationalForm")
        let OFNumber = Expression<String>("OFNumber")
        let OFType_ID = Expression<Int64>("OFType_ID")
        let Due_Date = Expression<Date>("Due_Date")
        
        for operationalFormRecord in try db.prepare(operationalFormTable) {
            guard let operationalForm = OperationalForm(
                OFNumber: operationalFormRecord[OFNumber],
                photo: nil,
                OFType_ID: Int(exactly: operationalFormRecord[OFType_ID]) ?? 0,
                type: "Type",
                Due_Date: operationalFormRecord[Due_Date],
                key1: "Surface Location",
                key2: "Location Name",
                key3: "UWI")
                else {
                    fatalError("Unable to load meal from database")
            }
            operationalForms += [operationalForm]
        }
        return operationalForms
    }
}
