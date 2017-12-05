//
//  LoadMediaTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-27.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class LoadMediaTask: OPLYNXUserServerTask {
    
    //MARK: Initializer
    init(_ mediaNumber: String, mediaTableViewController: MediaTableViewController?) {
        super.init(module: "media", method: "get", httpMethod: "GET", viewController: mediaTableViewController, taskTitle: nil, taskDescription: nil)
        addParameter(name: "media_number", value: mediaNumber)
    }
    
    override func processData(data: Any) throws {
        if let data = data as? [String:Any] {
            if let Asset_ID = data["ai"] as? Int,
                let Create_DateString = data["cd"] as? String,
                let Create_Date = Date(jsonDate: Create_DateString),
                let base64Contents = data["contents"] as? String,
                let dataContents = Data(base64Encoded: base64Contents),
                let CreateUser_ID = data["cui"] as? Int,
                let Description = data["des"] as? String,
                let GPSLocation = data["gps"] as? String,
                let Media_DateString = data["md"] as? String,
                let Media_Date = Date(jsonDate: Media_DateString),
                let MediaNumber = data["mn"] as? String,
                let MediaType_ID = data["mti"] as? Int,
                let UniqueMediaNumber = data["umn"] as? Int,
                let Url = data["url"] as? String {
                
                let Contents = UIImage(data: dataContents)
                
                let media = Media(MediaNumber: MediaNumber, Media_Date: Media_Date, Asset_ID: Asset_ID, UniqueMediaNumber: UniqueMediaNumber, MediaType_ID: MediaType_ID, Url: Url, Description: Description, Create_Date: Create_Date, CreateUser_ID: CreateUser_ID, GPSLocation: GPSLocation, LastUpdate: Date(), Dirty: false, Content: Contents)
                
                // Save the Media record to the database
                do {
                    try media.insertMediaToDB(db: Database.DB())
                    if let mediaTableViewController = viewController as? MediaTableViewController {
                        mediaTableViewController.appendMedia(media)
                        DispatchQueue.main.async {
                            mediaTableViewController.tableView.reloadData()
                        }
                    }
                }
                catch {
                    // Unable to save the Asset Token to the database
                    throw OsonoError.Message("Error saving Media locally")
                }
            }
        }
        else {
            // Unable to parse server data
            throw OsonoError.Message("Error Loading Media from Server")
        }
    }
    
}

