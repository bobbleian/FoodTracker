//
//  Authorize.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-31.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import os.log

class Authorize {
    
    private static let CLIENT_ID = "ba91fecd-7371-4466-a11e-8b44a99ee809"
    
    public static func RegisterAsset(assetName: String, completion: @escaping (Bool) -> Void) {
        
        let headers = ["content-type": "application/json", "authorization": "Bearer " + OsonoServerTask.ASSET_TOKEN]
        
        let urlBase = "http://199.180.29.38:13616/opLYNXJSON/auth/registerasset"
        let parameters = "asset_name=" + assetName + "&client_id=" + CLIENT_ID
        let urlString = urlBase + "?" + parameters
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                os_log(error as! StaticString, log: OSLog.default, type: .error)
            }
            else {
                do {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let parsedData = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                                for (key, value) in parsedData {
                                    print("\(key): \(value)")
                                }
                                // Check for Error message passed back in OSON
                                if let error = parsedData["error"] as? [String:Any] {
                                    // See if there is an error message
                                    if let code = error["code"] as? Int, let message = error["message"] as? String {
                                        os_log("osono server error code=%d message=%s", log: OSLog.default, type: .error, code, message)
                                        completion(false)
                                        return
                                    }
                                }
                                
                                if let data = parsedData["data"] as? String {
                                    // Save the Asset Token
                                    do {
                                        try LocalSettings.updateSettingsValue(db: Database.DB(), Key: LocalSettings.AUTHORIZE_ASSET_TOKEN_KEY, Value: data)
                                        OsonoServerTask.ASSET_TOKEN = data
                                        completion(true)
                                    }
                                    catch {
                                        completion(false)
                                    }
                                }
                                else {
                                    completion(false)
                                }
                            }
                            else {
                                completion(false)
                            }
                        }
                        else {
                            os_log("Http Error", log: OSLog.default, type: .error)
                            completion(false)
                        }
                    }
                    else {
                        completion(false)
                    }
                }
                catch {
                    print(error)
                    completion(false)
                }
            }
        }.resume()
    }
    
    public static func LoadAssetByName(assetName: String, completion: @escaping (Bool) -> Void) {
        
        let headers = ["content-type": "application/json", "authorization": "Bearer " + OsonoServerTask.ASSET_TOKEN]
        
        let urlBase = "http://199.180.29.38:13616/opLYNXJSON/asset/loadassetbyname"
        let parameters = "asset_name=" + assetName
        let urlString = urlBase + "?" + parameters
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                os_log(error as! StaticString, log: OSLog.default, type: .error)
            }
            else {
                do {
                    if let httpResponse = response as? HTTPURLResponse {
                        print(httpResponse)
                        
                        if httpResponse.statusCode == 200 {
                            if let parsedData = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                                for (key, value) in parsedData {
                                    print("\(key): \(value)")
                                }
                                // Check for Error message passed back in OSON
                                if let error = parsedData["error"] as? [String:Any] {
                                    // See if there is an error message
                                    if let code = error["code"] as? Int, let message = error["message"] as? String {
                                        completion(false)
                                        return
                                    }
                                }
                                
                                if let data = parsedData["data"] as? [String:Any] {
                                    if let Asset_ID = data["id"] as? Int, let Name = data["name"] as? String {
                                        // Save the Asset record to the database
                                        do {
                                            let db = try Database.DB()
                                            try Asset.deleteAllAsset(db: db)
                                            try Asset.updateAsset(db: db, Asset_ID: Asset_ID, Name: Name)
                                            completion(true)
                                        }
                                        catch {
                                            completion(false)
                                        }
                                    }
                                }
                                else {
                                    completion(false)
                                }
                            }
                            else {
                                completion(false)
                            }
                        }
                        else {
                            os_log("Http Error", log: OSLog.default, type: .error)
                        }
                    }
                }
                catch {
                    print(error)
                }
            }
            }.resume()
    }
    
    public static func AuthorizeUser(grantType: String, userName: String) {
        
    }
    
}
