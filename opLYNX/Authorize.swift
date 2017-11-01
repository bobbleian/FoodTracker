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
    
    public static func RegisterAsset(assetName: String) {
        
        let headers = ["content-type": "application/json"]
        
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
                        print(httpResponse)

                        if httpResponse.statusCode == 200 {
                            let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                            if let assetToken = parsedData["data"] as! String? {
                                // Save the Asset Token
                                do {
                                    try LocalSettings.updateSettingsValue(db: Database.DB(), Key: LocalSettings.AUTHORIZE_ASSET_TOKEN_KEY, Value: assetToken)
                                }
                                catch {
                                    
                                }
                            }
                            for (key, value) in parsedData {
                                print("\(key): \(value)")
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
