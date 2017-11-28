//
//  DeleteCleanMediaTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-28.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class DeleteCleanMediaTask: OsonoNoServerTask {
    
    let viewController: UIViewController?
    
    //MARK: Initializer
    init(viewController: UIViewController?) {
        self.viewController = viewController
        super.init()
    }
    
    // Subclasses provide their own RunTask implementation
    override func RunTask() {
        try? Media.deleteCleanMediaFromDB(db: Database.DB())
    }
    
}

