//
//  StageSaveOperationalFormTasks.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-27.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class StageSaveOperationalFormTasks: OPLYNXGenericTask {
    
    // Subclasses provide their own RunTask implementation
    override func RunTask() {
        
        // Save Dirty Operational Forms
        var saveOperationalFormTasks = [SaveOperationalFormTask]()
        do {
            let dirtyOperationalForms = try OperationalForm.loadDirtyOperationalFormsFromDB(db: Database.DB())
            for operationalForm in dirtyOperationalForms {
                try operationalForm.ElementData = OFElementData.loadOFElementValue(db: Database.DB(), OFNumber: operationalForm.OFNumber)
                try operationalForm.LinkRun = OFLinkRun.loadOFLinkRuns(db: Database.DB(), OFNumber: operationalForm.OFNumber)
                try operationalForm.LinkUser = OFLinkUser.loadOFLinkUsers(db: Database.DB(), OFNumber: operationalForm.OFNumber)
                try operationalForm.LinkOperationalForm = OFLinkOperationalForm.loadOFLinkOperationalForms(db: Database.DB(), OFNumber: operationalForm.OFNumber)
                try operationalForm.LinkMedia = OFLinkMedia.loadOFLinkMedia(db: Database.DB(), OFNumber: operationalForm.OFNumber)
            }
            saveOperationalFormTasks = dirtyOperationalForms.map { SaveOperationalFormTask($0, viewController: viewController) }
            
            // Upload Dirty Forms
            var currentOsonoTask: OsonoServerTask = self
            for saveOperationalFormTask in saveOperationalFormTasks {
                currentOsonoTask.insertOsonoTask(saveOperationalFormTask)
                currentOsonoTask = saveOperationalFormTask
            }
            
            // Run the next Osono Task, if necessary
            self.runNextTask()
            
        }
        catch {
            // TODO log error
        }
        
        
    }
    
}
