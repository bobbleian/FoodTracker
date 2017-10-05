//
//  Meal.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-08-21.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit

class OperationalForm {
    //MARK: Properties
    var name: String
    var photo: UIImage?
    var rating: Int
    var type: String = "type"
    var dueDate: String = "due date"
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
    init?(name: String, photo: UIImage?, rating: Int, type: String, dueDate: String, key1: String, key2: String, key3: String) {
        
        // Initialization fails if name is empty
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialization fails if rating is out of range
        guard rating >= 0 else {
            return nil
        }
        
        self.name = name
        self.photo = photo
        self.rating = rating
        self.type = type
        self.dueDate = dueDate
        self.key1 = key1
        self.key2 = key2
        self.key3 = key3
        
        self.OFNumber = ""
        self.Operational_Date = Date()
        self.Asset_ID = 0
        self.UniqueOFNumber = 0
        self.OFType_ID = 0
        self.OFStatus_ID = 0
        self.Due_Date = Date()
        self.Create_Date = Date()
        self.Complete_Date = Date()
        self.CreateUser_ID = 0
        self.CompleteUser_ID = 0
        self.Comments = ""
        self.LastUpdate = Date()
        self.Dirty = false
        
    }
}
