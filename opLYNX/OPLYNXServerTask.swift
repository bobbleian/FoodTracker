//
//  OPLYNXJsonServerTask.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-11-02.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit

class OPLYNXServerTask : OsonoServerTask {
    // Static values
    private static let SERVER_IP = "199.180.29.38"
    private static let SERVER_PORT = "13616"
    private static let SERVER_METHOD = "http"
    private static let SERVER_APPLICATION = "opLYNXJSON"
    
    //MARK: Properties
    let taskTitle: String?
    let taskDescription: String?
    let viewController: UIViewController?
    
    init(module: String?, method: String, httpMethod: String, viewController: UIViewController?, taskTitle: String?, taskDescription: String?) {
        self.taskTitle = taskTitle
        self.taskDescription = taskDescription
        self.viewController = viewController
        super.init(serverIP: OPLYNXServerTask.SERVER_IP,
                   serverPort: OPLYNXServerTask.SERVER_PORT,
                   serverMethod: OPLYNXServerTask.SERVER_METHOD,
                   application: OPLYNXServerTask.SERVER_APPLICATION,
                   module: module,
                   method: method,
                   httpMethod: httpMethod)
    }
    
    
    override func RunTask() {
        // Display task title, if it exists
        if let oplynxProgressView = viewController as? OPLYNXProgressView, let header = taskTitle, let footer = taskDescription {
            oplynxProgressView.updateProgress(title: header, description: footer)
        }
        
        // Run the task
        super.RunTask()
        
    }
    
    override public func runError(errorMessage: String) {
        if let oplynxProgressView = viewController as? OPLYNXProgressView {
            oplynxProgressView.endProgress()
        }
        super.runError(errorMessage: errorMessage)
    }
    
}
