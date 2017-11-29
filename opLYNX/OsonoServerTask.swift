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
    
    //MARK: Static properties
    private static var cachedAssetToken: String?
    private static var cachedUserToken: String?
    
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
                catch {
                    os_log("Unable to load asset token from local database", log: OSLog.default, type: .error)
                }
            }
            return ""
        }
    }
    
    static func setAssetToken(newValue: String) throws {// Store in local database and update the cached value
        try LocalSettings.updateSettingsValue(db: Database.DB(), Key: LocalSettings.AUTHORIZE_ASSET_TOKEN_KEY, Value: newValue)
        cachedAssetToken = newValue
    }
    
    
    // Static properties
    public static var USER_TOKEN: String {
        get {
            if let cachedUserToken = cachedUserToken {
                return cachedUserToken
            }
            else {
                // Try loading from the local database
                do {
                    if let dbUserToken = try LocalSettings.loadSettingsValue(db: Database.DB(), Key: LocalSettings.AUTHORIZE_USER_TOKEN_KEY) {
                        cachedUserToken = dbUserToken
                        return dbUserToken
                    }
                }
                catch {
                    os_log("Unable to load user token from local database", log: OSLog.default, type: .error)
                }
            }
            return ""
        }
    }
    static func setUserToken(newValue: String) throws {// Store in local database and update the cached value
        try LocalSettings.updateSettingsValue(db: Database.DB(), Key: LocalSettings.AUTHORIZE_USER_TOKEN_KEY, Value: newValue)
        cachedUserToken = newValue
    }
    
        
    // Required properties
    private let serverIP: String
    private let serverPort: String?
    private let serverMethod: String
    private let application: String
    private let module: String?
    private let method: String
    private let httpMethod: String
    private var parameters = [String:String]()
    private var parameterKeys = [String]()
    private var dataPayload: Any?
    
    // Completion Handler
    public var taskDelegate: OsonoTaskDelegate?
    
    // Osono Task Chaining
    private var nextOsonoTask: OsonoServerTask?
    
    // Initialize the Osono server task with basic parameters
    init(serverIP: String, serverPort: String?, serverMethod: String, application: String, module: String?, method: String, httpMethod: String) {
        self.serverIP = serverIP
        self.serverPort = serverPort
        self.serverMethod = serverMethod
        self.application = application
        self.module = module
        self.method = method
        self.httpMethod = httpMethod
    }
    
    // Add a parameter to be passed into the Osono server call
    func addParameter(name: String, value: String) {
        parameters[name] = value
        parameterKeys.append(name)
    }
    
    // Set the next Osono Task
    func insertOsonoTask(_ osonoTask: OsonoServerTask) {
        osonoTask.nextOsonoTask = self.nextOsonoTask
        self.nextOsonoTask = osonoTask
    }
    
    // Set the Osono Data payload
    func setDataPayload(dataPayload: [String: Any]) {
        self.dataPayload = dataPayload
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
            if let value = parameters[name], let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                url += parmOperator + encodedName + "=" + encodedValue
                parmOperator = "&"
            }
        }
        
        print(url)
        return url
    }
    
    // Function returns Bearer token - to be implemented by subclasses as necessary
    func GetBearerToken() -> String {
        return ""
    }
    
    
    func RunTask() {
        
        var errorMessage = "Unknown Error"
        
        let headers = ["content-type": "application/json", "authorization": "Bearer " + GetBearerToken()]

        if let url = URL(string: generateURLString()) {
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod
            request.allHTTPHeaderFields = headers
            print(headers)
            
            // Format the Data Payload in Osono Format
            //if let dataPayload = dataPayload, let jsonData = try? JSONSerialization.data(withJSONObject: dataPayload) {
            if let dataPayload = dataPayload {
                var osonoDataPayload = [String:Any]()
                osonoDataPayload["data"] = dataPayload
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: osonoDataPayload) {
                    request.httpBody = jsonData
                }
            }
            
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
                                            self.runNextTask()
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
    
    // Run the next task on a new thread?
    public func runNextTask() {
        self.nextOsonoTask?.RunTask()
    }
    
}

// Extension to String for Osono Parameter Date Formatting
extension Date {
    init?(jsonDate: String) {
        let prefix = "/Date("
        let suffix = ")/"
        
        // Check for correct format
        guard jsonDate.hasPrefix(prefix) && jsonDate.hasSuffix(suffix) else { return nil }
        
        // Extract the number as a string
        let from = jsonDate.index(jsonDate.startIndex, offsetBy: prefix.count)
        let to = jsonDate.index(jsonDate.endIndex, offsetBy: -suffix.count)
        
        // Convert from milliseconds to double
        guard let milliSeconds = Double(jsonDate[from ..< to]) else { return nil }
        
        // Create Date with this UNIX stamp
        self.init(timeIntervalSince1970: milliSeconds/1000.0)
    }
    
    func formatJsonDate() -> String {
        let prefix = "/Date("
        let suffix = ")/"
        let millisecondsSince1970 = Int(timeIntervalSince1970 * 1000)
        return prefix + String(millisecondsSince1970) + suffix
    }
}
