//
//  OsonoNoServerTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-20.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import os.log

class OsonoNoServerTask: OPLYNXServerTask {
    
    // Initialize the Osono server task with blank parameters
    init() {
        super.init(module: nil, method: "NA", httpMethod: "NONE")
    }
    
    // Subclasses provide their own RunTask implementation
    override func RunTask() { }
    
}

