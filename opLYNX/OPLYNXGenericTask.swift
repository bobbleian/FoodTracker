//
//  OsonoNoServerTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-20.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class OPLYNXGenericTask: OPLYNXServerTask {
    
    // Initialize the Osono server task with blank parameters
    init() {
        super.init(module: nil, method: "NA", httpMethod: "NONE", viewController: nil, taskTitle: nil, taskDescription: nil)
    }
    
    init(viewController: UIViewController?) {
        super.init(module: nil, method: "NA", httpMethod: "NONE", viewController: viewController, taskTitle: nil, taskDescription: nil)
    }
    
    // Subclasses provide their own RunTask implementation
    override func RunTask() { }
    
}

