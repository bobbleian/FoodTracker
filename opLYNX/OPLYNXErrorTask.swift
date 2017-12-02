//
//  OPLYNXErrorTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-12-01.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit

class OPLYNXErrorTask: OsonoErrorTask {
    
    //MARK: Properties
    var errorMessage: String?
    var viewController: UIViewController?
    
    //MARK: Initializer
    init() {
        super.init(serverIP: "", serverPort: nil, serverMethod: "", application: "", module: nil, method: "", httpMethod: "")
    }
    
    override func RunTask() {
        // Hide any progress dialogs
        JustHUD.shared.hide()
    }
    
}
