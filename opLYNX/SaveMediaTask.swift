//
//  SaveMediaTask.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-11-24.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import UIKit
import os.log

class SaveMediaTask: OPLYNXUserServerTask {
    
    //MARK: Properties
    private let media: Media
    
    //MARK: Initializer
    init(_ media: Media, viewController: UIViewController?) {
        self.media = media
        super.init(module: "media", method: "save", httpMethod: "POST", viewController: viewController, taskTitle: "Data Sync", taskDescription: "Uploading Media")
        setDataPayload(dataPayload: media.convertToOsono())
    }
    
    override func processData(data: Any) throws {
        
        // Parse out the returned Media number
        guard let data = data as? [String:Any], let NewMediaNumber = data["mn"] as? String, let NewUniqueMediaNumber = data["umn"] as? Int else {
            // Unable to parse server data
            throw OsonoError.Message("Error Saving Media To Server")
        }
        
        // After a successul upload to the server, delete the Media record from the local database
        do {
            let db = try Database.DB()
            try media.updateMediaNumber(db: db, NewMediaNumber: NewMediaNumber, NewUniqueMediaNumber: NewUniqueMediaNumber, NewDirty: false)
            try media.deleteMediaFromDB(db: db)
        }
        catch {
            // Unable to save the Asset Token to the database
            throw OsonoError.Message("Error Saving Media Data")
        }
        
    }
    
}
