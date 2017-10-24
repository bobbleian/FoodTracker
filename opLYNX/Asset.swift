//
//  Asset.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

class Asset {
    
    //MARK: Properties
    var Asset_ID: Int
    var Name: String
    var LastUpdate: Date
    
    //MARK: Initialization
    init?(Asset_ID: Int, Name: String, LastUpdate: Date) {
        
        // Initialization fails if name is empty
        guard !Name.isEmpty else {
            return nil
        }
        
        // Initialization fails if Asset_ID is negative
        guard Asset_ID >= 0 else {
            return nil
        }
        
        self.Asset_ID = Asset_ID
        self.Name = Name
        self.LastUpdate = LastUpdate
    }
}
