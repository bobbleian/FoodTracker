//
//  ConfigSyncServerTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-12.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

class ConfigSyncServerTask: OPLYNXAssetServerTask {
    
    // Inserts a "last_update" parameter to all the Task before calling Run
    override func RunTask() {
        if let lastConfigSyncDate = Authorize.ASSET_SOFTWARE_INFO?.LastSyncConfiguration {
            addParameter(name: "last_update", value: "\"" + lastConfigSyncDate.formatJsonDate() + "\"")
        }
        super.RunTask()
    }
}
