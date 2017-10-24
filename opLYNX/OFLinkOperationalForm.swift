//
//  Asset.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

class OFLinkOperationalForm {
    
    //MARK: Properties
    var OFNumber: String
    var LinkOFNumber: String
    var OFLinkType_ID: Int
    
    //MARK: Initialization
    init?(OFNumber: String, LinkOFNumber: String, OFLinkType_ID: Int) {
        
        // Initialization fails if OFNumber is empty
        guard !OFNumber.isEmpty else {
            return nil
        }
        
        // Initialization fails if LinkOFNumber is empty
        guard !LinkOFNumber.isEmpty else {
            return nil
        }
        
        // Initialization fails if OFLinkType_ID is negative
        guard OFLinkType_ID >= 0 else {
            return nil
        }
        
        self.OFNumber = OFNumber
        self.LinkOFNumber = LinkOFNumber
        self.OFLinkType_ID = OFLinkType_ID
        
    }
}
