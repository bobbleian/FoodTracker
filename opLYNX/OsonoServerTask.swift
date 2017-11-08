//
//  OsonoServerTask.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-11-02.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import os.log

protocol OsonoTaskDelegate {
    func success()
    func error(message: String)
    func processData(data: Any) throws
}

enum OsonoError : Error {
    case Message(String)
}

class OsonoServerTask {
    
    // Static properties
    public static var ASSET_TOKEN: String {
        get {
            if let cachedAssetToken = cachedAssetToken {
                return cachedAssetToken
            }
            else {
                // Try loading from the local database
                do {
                    if let dbAssetToken = try LocalSettings.loadSettingsValue(db: Database.DB(), Key: LocalSettings.AUTHORIZE_ASSET_TOKEN_KEY) {
                        OsonoServerTask.cachedAssetToken = dbAssetToken
                        return dbAssetToken
                    }
                }
                catch { }
            }
            return ""
        }
        set {
            // Store in local database and update the cached value
            do {
                try LocalSettings.updateSettingsValue(db: Database.DB(), Key: LocalSettings.AUTHORIZE_ASSET_TOKEN_KEY, Value: newValue)
                OsonoServerTask.cachedAssetToken = newValue
            }
            catch { }
        }
    }
    private static var cachedAssetToken: String?
    
    // Required properties
    private let serverIP: String
    private let serverPort: String?
    private let serverMethod: String
    private let application: String
    private let module: String?
    private let method: String
    private var parameters = [String:String]()
    private var parameterKeys = [String]()
    
    // Completion Handler
    public var taskDelegate: OsonoTaskDelegate?
    
    // Osono Task Chaining
    public var nextOsonoTask: OsonoServerTask?
    
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
    
    
    func Run() {
        
        var errorMessage = "Unknown Error"
        
        let headers = ["content-type": "application/json", "authorization": "Bearer " + OsonoServerTask.ASSET_TOKEN]

        if let url = URL(string: generateURLString()) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    os_log("Server request error", log: OSLog.default, type: .error)
                    errorMessage = "Server Error"
                }
                else {
                    do {
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                if let parsedData = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                                    for (key, value) in parsedData {
                                        print("\(key): \(value)")
                                    }
                                    // Check Osono error package
                                    if let error = parsedData["error"] as? [String:Any] {
                                        // See if there is an error message
                                        if let code = error["code"] as? Int, let message = error["message"] as? String {
                                            os_log("osono server error code=%d message=%@", log: OSLog.default, type: .error, code, message)
                                            self.taskDelegate?.error(message: message)
                                            return
                                        }
                                    }
                                    
                                    // Process Osono data payload
                                    if let dataPayload = parsedData["data"] {
                                        do {
                                            try self.taskDelegate?.processData(data: dataPayload)
                                            self.taskDelegate?.success()
                                            // Run the next Osono Task, if necessary
                                            self.nextOsonoTask?.Run()
                                            return
                                        }
                                        catch OsonoError.Message(let osonoErrorMessage){
                                            // Set the Osono Error Message
                                            errorMessage = osonoErrorMessage
                                        }
                                    }
                                    else {
                                        // Unable to extract the Osono data payload as a String
                                        errorMessage = "Error parsing server data"
                                    }
                                }
                                else {
                                    // Unable to deserialize the JSON object sent back from the Osono server
                                    errorMessage = "Error parsing server data"
                                }
                            }
                            else {
                                // HTTP error code (non-200 response)
                                os_log("HTTP Error: %d", log: OSLog.default, type: .error, httpResponse.statusCode)
                                errorMessage = "Error contacting server"
                            }
                        }
                        else {
                            // Unable to process response as HTTP Response
                            errorMessage = "Error contacting server"
                        }
                    }
                    catch {
                        print(error)
                    }
                }
                // If we've gotten this far, then the Osono data payload was not processed successfully
                // Return the error message through the callback delegate
                self.taskDelegate?.error(message: errorMessage)
            }.resume()
        }
    }
    
}
