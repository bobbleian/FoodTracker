//
//  DataSync.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-12.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit

class DataSync {
    
    //MARK: Static Properties
    // Static variable for storing Server Date Time used in Data Sync
    public static var SERVER_DATETIME_UTC: Date?
    
    // Run Data Sync
    static func RunDataSync(viewController: UIViewController?) {

        // Create a task for loading asset software info
        guard let loadAssetSoftwareInfoTask = LoadAssetSoftwareInfoTask(viewController: viewController) else {
            // TODO: Error message
            return
        }
        
        // Register User Task
        let registerUserTask = RegisterUserTask(Authorize.CURRENT_USER?.UserName ?? "", viewController: viewController)
              
        // Save Dirty Media
        var saveMediaTasks = [SaveMediaTask]()
        do {
            let dirtyPictures = try Media.loadDirtyMediaFromDB(db: Database.DB())
            saveMediaTasks = dirtyPictures.map { SaveMediaTask($0, viewController: viewController) }
        }
        catch {
            // TODO log error
        }
        
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
        }
        catch {
            // TODO log error
        }
        
        // Load Operational Form List by Start Date
        let loadOFListTask = LoadFormListTask(viewController: viewController)

        // Create a task for loading Server DateTime
        let loadDateTimeUTCTask = LoadDateTimeUTCTask(viewController: viewController, updateConfigSync: false, updateDataSync: true)
        
        // Create task for getting all updated forms from server since last data sync
        let loadFormsByLastSync = LoadFormsByLastSyncTask(viewController: viewController)
        
        // Create a task for saving AssetSoftwareInfo
        let saveAssetSoftwareInfoTask = SaveAssetSoftwareInfoTask("Data Sync", viewController: viewController)
        
        // Chain the Data Sync tasks together
        loadAssetSoftwareInfoTask.insertOsonoTask(registerUserTask)
        
        // Upload Dirty Pictures
        var currentOsonoTask: OsonoServerTask = registerUserTask
        for saveMediaTask in saveMediaTasks {
            currentOsonoTask.insertOsonoTask(saveMediaTask)
            currentOsonoTask = saveMediaTask
        }
        
        // Upload Dirty Forms
        for saveOperationalFormTask in saveOperationalFormTasks {
            currentOsonoTask.insertOsonoTask(saveOperationalFormTask)
            currentOsonoTask = saveOperationalFormTask
        }
        
        // Sync Forms from Server
        currentOsonoTask.insertOsonoTask(loadOFListTask)
        loadOFListTask.insertOsonoTask(loadDateTimeUTCTask)
        loadDateTimeUTCTask.insertOsonoTask(loadFormsByLastSync)
        loadFormsByLastSync.insertOsonoTask(saveAssetSoftwareInfoTask)
        
        // TESTING ONLY
        //currentOsonoTask.insertOsonoTask(saveAssetSoftwareInfoTask)
        
        // Run the Osono Task Chain
        loadAssetSoftwareInfoTask.RunTask()
    }
    
}
