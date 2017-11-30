//
//  PingServerTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-30.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class PingServerTask: OPLYNXAssetServerTask {
    
    //MARK: Initializer
    init(viewController: UIViewController?) {
        super.init(module: "common", method: "serverdatetimenowutc", httpMethod: "GET")
        taskDelegate = PingServerHandler(viewController: viewController)
    }
    
    //MARK: Server Delegate Handler
    class PingServerHandler: OPLYNXServerTaskDelegate {
        
        //MARK: Initializers
        init(viewController: UIViewController?) {
            super.init(viewController: viewController, taskTitle: "Internet Connectivity", taskDescription: "Establishing Server Connection")
        }
        
        override func error(message: String) {
            DispatchQueue.main.async {
                JustHUD.shared.hide()
            }
            let alert = UIAlertController(title: "Internet Connectivity Error", message: "Unable to contact server, please try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController?.present(alert, animated: true, completion: nil)
        }
        
    }
    
}

