//
//  Settings.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-12-12.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

class OPLYNXSettings {
    
    class func NearbyThreshold() -> Double {
        let threshold = UserDefaults.standard.double(forKey: "nearbyRange")
        return threshold <= 0 ? 250 : threshold
    }
    
    class func ServerIP() -> String {
        if let result = UserDefaults.standard.string(forKey: "serverIP"), !result.isEmpty {
            return result
        }
        //return "oplynxconvprod.cnrl.com"
        return "192.131.138.57"
    }
    
    class func ServerPort() -> String {
        if let result = UserDefaults.standard.string(forKey: "serverPort"), !result.isEmpty {
            return result
        }
        return "13615"
    }
    
}
