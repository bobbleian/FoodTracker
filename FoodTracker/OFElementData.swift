//
//  Asset.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

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
}
