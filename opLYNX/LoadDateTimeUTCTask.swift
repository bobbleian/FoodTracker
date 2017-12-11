//
//  LoadDateTimeUTCTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-12.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class LoadDateTimeUTCTask: OPLYNXAssetServerTask {
    
    //MARK: Properties
    private let updateConfigSync: Bool
    private let updateDataSync: Bool
    
    //MARK: Initializer
    init(viewController: UIViewController?, updateConfigSync: Bool, updateDataSync: Bool) {
        self.updateConfigSync = updateConfigSync
        self.updateDataSync = updateDataSync
        super.init(module: "common", method: "serverdatetimenowutc", httpMethod: "GET", viewController: viewController, taskTitle: updateConfigSync ? "Config Sync" : "Data Sync", taskDescription: "Getting Server Time")
    }
    
    override func processData(data: Any) throws {
        if let data = data as? String, let serverDate = Date(jsonDate: data) {
            if updateConfigSync { ConfigSync.CONFIG_SYNC_SERVER_TIME_UTC = serverDate }
            if updateDataSync { DataSync.DATA_SYNC_SERVER_TIME_UTC = serverDate }
        }
        else {
            // Unable to parse server data
            throw OsonoError.Message("Error Loading Server Time")
        }
    }
}
