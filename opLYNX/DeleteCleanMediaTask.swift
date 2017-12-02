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

class DeleteCleanMediaTask: OPLYNXGenericTask {
    
    // Subclasses provide their own RunTask implementation
    override func RunTask() {
        try? Media.deleteCleanMediaFromDB(db: Database.DB())
        
        // Run the next Osono Task, if necessary
        self.runNextTask()
        
    }
    
}

