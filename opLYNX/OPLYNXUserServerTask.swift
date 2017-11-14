//
//  OPLYNXUserServerTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-13.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

class OPLYNXUserServerTask : OPLYNXServerTask {
    // Bearer token is the Asset token
    override func GetBearerToken() -> String {
        return OsonoServerTask.USER_TOKEN
    }
}
