//
//  Asset.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

class OFLinkRun {
    
    //MARK: Properties
    var OFNumber: String
    var Run_ID: Int
    
    //MARK: Initialization
    init?(OFNumber: String, Run_ID: Int) {
        
        // Initialization fails if OFNumber is empty
        guard !OFNumber.isEmpty else {
            return nil
        }
        
        // Initialization fails if OFLinkType_ID is negative
        guard Run_ID >= 0 else {
            return nil
        }
        
        self.OFNumber = OFNumber
        self.Run_ID = Run_ID
        
    }
}
