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
    
    init(module: String?, method: String, httpMethod: String) {
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
        if let oplynxServerTaskDelegate = taskDelegate as? OPLYNXServerTaskDelegate, let viewController = oplynxServerTaskDelegate.viewController, let header = oplynxServerTaskDelegate.taskTitle, let footer = oplynxServerTaskDelegate.taskDescription {
            DispatchQueue.main.async {
                JustHUD.shared.showInView(view: viewController.view, withHeader: header, andFooter: footer)
            }
        }
        
        // Run the task
        super.RunTask()
    }
}

class OPLYNXServerTaskDelegate : OsonoTaskDelegate {
    
    //MARK: Properties
    let taskTitle: String?
    let taskDescription: String?
    let viewController: UIViewController?
    
    //MARK: Initializers
    init(viewController: UIViewController?, taskTitle: String?, taskDescription: String?) {
        self.viewController = viewController
        self.taskTitle = taskTitle
        self.taskDescription = taskDescription
    }
    
    //MARK: OsonoTaskDelegate Protocol
    func success() {
        DispatchQueue.main.async {
            JustHUD.shared.hide()
        }
    }
    
    func error(message: String) {
        DispatchQueue.main.async {
            JustHUD.shared.hide()
        }
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    func processData(data: Any) throws {
        
    }
}


