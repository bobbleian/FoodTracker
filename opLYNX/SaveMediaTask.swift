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
    
    //MARK: Initializer
    init(_ media: Media, viewController: UIViewController?) {
        super.init(module: "media", method: "save", httpMethod: "POST")
        setDataPayload(dataPayload: media.convertToOsono())
        taskDelegate = SaveMediaHandler(media, viewController: viewController)
    }
    
    // Save SaveOperationalForm Handler
    class SaveMediaHandler: OPLYNXServerTaskDelegate {
        
        private let media: Media
        
        //MARK: Initializers
        init(_ media: Media, viewController: UIViewController?) {
            self.media = media
            super.init(taskTitle: "Uploading Media", viewController: viewController)
        }
        
        //MARK: OsonoTaskDelegate Protocol
        override func processData(data: Any) throws {
            
            // Parse out the returned Media number
            guard let data = data as? [String:Any], let NewMediaNumber = data["mn"] as? String else {
                // Unable to parse server data
                throw OsonoError.Message("Error Saving Media To Server")
            }
                
            // Save the Asset record to the database
            do {
                let db = try Database.DB()
                try media.updateMediaNumber(db: db, NewMediaNumber: NewMediaNumber)
                try media.updateMediaDirty(db: db, Dirty: false)
            }
            catch {
                // Unable to save the Asset Token to the database
                throw OsonoError.Message("Error Saving Media Data")
            }
            
        }

    }
    
}
