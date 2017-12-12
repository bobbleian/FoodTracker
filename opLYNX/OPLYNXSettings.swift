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
        let result = UserDefaults.standard.string(forKey: "serverIP")
        return result ?? "199.180.29.38"
    }
    class func ServerPort() -> String {
        return UserDefaults.standard.string(forKey: "serverPort") ?? "13616"
    }
    
}
