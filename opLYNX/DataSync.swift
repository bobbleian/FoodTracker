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
    public static var DATA_SYNC_SERVER_TIME_UTC: Date?
    
    // Run Data Sync
    static func RunDataSync(selectedRun: Run, viewController: UIViewController?, successTask: OsonoServerTask?, errorTask: OsonoErrorTask?) {

        // Check first we can hit the server
        let pingServerTask = PingServerTask(viewController: viewController)
        
        // Create a task for loading asset software info
        guard let loadAssetSoftwareInfoTask = LoadAssetSoftwareInfoTask("Data Sync", viewController: viewController) else {
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
        
        // Delete all Media that exists on the server
        let deleteCleanMediaTask = DeleteCleanMediaTask()
        
        // Save Dirty Operational Forms
        let stageSaveOperationalFormsTask = StageSaveOperationalFormTasks(viewController: viewController)
        
        // Load Operational Form List by Start Date
        let loadOFListTask = LoadFormListTask(viewController: viewController, run: selectedRun)

        // Create a task for loading Server DateTime
        let loadDateTimeUTCTask = LoadDateTimeUTCTask(viewController: viewController, updateConfigSync: false, updateDataSync: true)
        
        // Create task for getting all updated forms from server since last data sync
        let loadFormsByLastSync = LoadFormsByLastSyncTask(viewController: viewController, run: selectedRun)
        
        // Create a task for saving AssetSoftwareInfo
        let saveAssetSoftwareInfoTask = SaveAssetSoftwareInfoTask("Data Sync", viewController: viewController)
        
        // Chain the Data Sync tasks together
        pingServerTask.insertOsonoTask(loadAssetSoftwareInfoTask)
        loadAssetSoftwareInfoTask.insertOsonoTask(registerUserTask)
        
        // Upload Dirty Pictures
        var currentOsonoTask: OsonoServerTask = registerUserTask
        for saveMediaTask in saveMediaTasks {
            currentOsonoTask.insertOsonoTask(saveMediaTask)
            currentOsonoTask = saveMediaTask
        }
        
        // Sync Forms from Server
        currentOsonoTask.insertOsonoTask(deleteCleanMediaTask)
        deleteCleanMediaTask.insertOsonoTask(stageSaveOperationalFormsTask)
        stageSaveOperationalFormsTask.insertOsonoTask(loadOFListTask)
        loadOFListTask.insertOsonoTask(loadDateTimeUTCTask)
        loadDateTimeUTCTask.insertOsonoTask(loadFormsByLastSync)
        loadFormsByLastSync.insertOsonoTask(saveAssetSoftwareInfoTask)
        
        // Add the final tasks, if necessary
        if let successTask = successTask {
            saveAssetSoftwareInfoTask.insertOsonoTask(successTask)
            if let errorTask = errorTask {
                successTask.insertOsonoTask(errorTask)
            }
        }
        else if let errorTask = errorTask {
            saveAssetSoftwareInfoTask.insertOsonoTask(errorTask)
        }
        
        // Run the Osono Task Chain
        pingServerTask.RunTask()
    }
    
}

