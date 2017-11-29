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
    
    //MARK: Initializer
    init(viewController: UIViewController?, updateConfigSync: Bool, updateDataSync: Bool) {
        super.init(module: "common", method: "serverdatetimenowutc", httpMethod: "GET")
        taskDelegate = GetDateTimeUTCHandler(viewController: viewController, updateConfigSync: updateConfigSync, updateDataSync: updateDataSync)
    }
    
    //MARK: Server Delegate Handler
    class GetDateTimeUTCHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Properties
        private let updateConfigSync: Bool
        private let updateDataSync: Bool
        
        //MARK: Initializers
        init(viewController: UIViewController?, updateConfigSync: Bool, updateDataSync: Bool) {
            self.updateConfigSync = updateConfigSync
            self.updateDataSync = updateDataSync
            super.init(viewController: viewController, taskTitle: updateConfigSync ? "Config Sync" : "Data Sync", taskDescription: "Getting Server Time")
        }
        
        //MARK: OsonoTaskDelegate Protocol
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
    
}
