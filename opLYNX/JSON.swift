//
//  JSON.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-26.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

/*
 * Sending a JSON formatted image to the server
 let imageData = UIImagePNGRepresentation(newMeal.photo!)!
 let imageBase64 = imageData.base64EncodedString()
 
 let json: [String: Any] = ["Contents": imageBase64, "MediaNumber": "QK2AHSAAC"]
 let jsonData = try? JSONSerialization.data(withJSONObject: json)
 
 let headers = ["content-type": "application/json", "Authorization": "Bearer [token]"]
 
 let urlString = "http://100.100.102.113:13616/opLYNXJSON/image"
 let url = URL(string: urlString)!
 var request = URLRequest(url: url)
 request.httpMethod = "POST"
 request.httpBody = jsonData
 request.allHTTPHeaderFields = headers
 */

/*
 URLSession.shared.dataTask(with: request) { (data, response, error) in
 if error != nil {
 os_log(error as! StaticString, log: OSLog.default, type: .error)
 }
 else {
 do {
 let httpResponse = response as? HTTPURLResponse
 print(httpResponse!)
 let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
 for (key, value) in parsedData {
 print("\(key): \(value)")
 }
 }
 catch {
 print(error)
 }
 }
 }.resume()
 */



// Messing around with JSON
/*
 let urlString = "http://100.100.102.113:13616/opLYNXJSON/operationalform/UEFAXSAAB"
 let url = URL(string: urlString)
 URLSession.shared.dataTask(with: url!) { (data, response, error) in
 if error != nil {
 os_log(error as! StaticString, log: OSLog.default, type: .error)
 }
 else {
 do {
 let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
 for (key, value) in parsedData {
 print("\(key): \(value)")
 }
 }
 catch {
 print(error)
 }
 }
 }.resume()
 */
/*
 let json: [String: Any] = ["Number1": "2", "Number2": "3"]
 let jsonData = try? JSONSerialization.data(withJSONObject: json)
 
 let headers = ["content-type": "application/json"]
 
 let urlString = "http://100.100.102.113:13616/opLYNXJSON/add"
 let url = URL(string: urlString)!
 var request = URLRequest(url: url)
 request.httpMethod = "POST"
 request.httpBody = jsonData
 request.allHTTPHeaderFields = headers
 
 URLSession.shared.dataTask(with: request) { (data, response, error) in
 if error != nil {
 os_log(error as! StaticString, log: OSLog.default, type: .error)
 }
 else {
 do {
 let httpResponse = response as? HTTPURLResponse
 print(httpResponse)
 let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
 for (key, value) in parsedData {
 print("\(key): \(value)")
 }
 }
 catch {
 print(error)
 }
 }
 }.resume()
 */

