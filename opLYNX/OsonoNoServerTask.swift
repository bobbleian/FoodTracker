//
//  OsonoNoServerTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-20.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

import Foundation
import os.log

class OsonoNoServerTask: OsonoServerTask {
    
    // Initialize the Osono server task with blank parameters
    init() {
        super.init(serverIP: "", serverPort: nil, serverMethod: "", application: "", module: nil, method: "", httpMethod: "")
    }
    
    // Subclasses provide their own RunTask implementation
    override func RunTask() { }
    
}

