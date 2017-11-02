//
//  OPLYNXJsonServerTask.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-11-02.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

class OPLYNXServerTask : OsonoServerTask {
    // Static values
    private static let SERVER_IP = "199.180.29.38"
    private static let SERVER_PORT = "13616"
    private static let SERVER_METHOD = "http"
    private static let SERVER_APPLICATION = "opLYNXJSON"
    
    init(module: String?, method: String) {
        super.init(serverIP: OPLYNXServerTask.SERVER_IP,
                   serverPort: OPLYNXServerTask.SERVER_PORT,
                   serverMethod: OPLYNXServerTask.SERVER_METHOD,
                   application: OPLYNXServerTask.SERVER_APPLICATION,
                   module: module,
                   method: method)
    }
}

