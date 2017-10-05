//
//  Asset.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

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
}
