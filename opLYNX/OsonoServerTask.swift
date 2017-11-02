//
//  OsonoServerTask.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-11-02.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

class OsonoServerTask {
    
    // Required properties
    private let serverIP: String
    private let serverPort: String?
    private let serverMethod: String
    private let application: String
    private let module: String?
    private let method: String
    private var parameters = [String:String]()
    private var parameterKeys = [String]()
    
    
    // Initialize the Osono server task with basic parameters
    init(serverIP: String, serverPort: String?, serverMethod: String, application: String, module: String?, method: String) {
        self.serverIP = serverIP
        self.serverPort = serverPort
        self.serverMethod = serverMethod
        self.application = application
        self.module = module
        self.method = method
    }
    
    // Add a parameter to be passed into the Osono server call
    func addParameter(name: String, value: String) {
        parameters[name] = value
        parameterKeys.append(name)
    }
    
    // Generate the URL string
    func generateURLString() -> String {
        // Start with server IP
        var url = serverMethod + "://" + serverIP
        
        // Add optional server Port
        if let serverPort = serverPort {
            url += ":" + serverPort
        }
        
        // Add server application
        url += "/" + application
        
        // Add optional server module
        if let module = module {
            url += "/" + module
        }
        
        // Add server method
        url += "/" + method
        
        // Add parameters
        var parmOperator = "?"
        for (name) in parameterKeys {
            if let value = parameters[name] {
                url += parmOperator + name + "=" + value
                parmOperator = "&"
            }
        }
        
        return url
    }
    
}
