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
    init(viewController: UIViewController?) {
        super.init(module: "common", method: "serverdatetimenowutc", httpMethod: "GET")
        taskDelegate = GetDateTimeUTCHandler(viewController: viewController)
    }
    
    //MARK: Server Delegate Handler
    class GetDateTimeUTCHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(taskTitle: "Getting Server Time", viewController: viewController)
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            if let data = data as? String, let serverDate = Date(jsonDate: data) {
                ConfigSync.SERVER_DATETIME_UTC = serverDate
            }
            else {
                // Unable to parse server data
                throw OsonoError.Message("Error Loading Server Time")
            }
        }
        
    }
    
}
