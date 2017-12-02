//
//  PingServerTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-30.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class PingServerTask: OPLYNXAssetServerTask {
    
    //MARK: Initializer
    init(viewController: UIViewController?) {
        super.init(module: "common", method: "serverdatetimenowutc", httpMethod: "GET", viewController: viewController, taskTitle: "Internet Connectivity", taskDescription: "Establishing Server Connection")
    }
    
}

