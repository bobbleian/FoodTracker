//
//  Asset.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

class OFType {
    
    //MARK: Properties
    var OLType_ID: Int
    var Name: String
    var DisplayName: String
    
    static func GetDisplayNameFromID (OLType_ID: Int) -> String {
        switch OLType_ID {
        case 6:
            return "D13"
        default:
            return "Unknown"
        }
    }
    
    //MARK: Initialization
    init?(OLType_ID: Int, Name: String, DisplayName: String) {
        
        // Initialization fails if OLType_ID is negative
        guard OLType_ID >= 0 else {
            return nil
        }
        
        // Initialization fails if Name is empty
        guard !Name.isEmpty else {
            return nil
        }
        
        // Initialization fails if DisplayName is empty
        guard !DisplayName.isEmpty else {
            return nil
        }
        
        self.OLType_ID = OLType_ID
        self.Name = Name
        self.DisplayName = DisplayName
        
    }
}
