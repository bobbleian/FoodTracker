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
            if let data = data as? Bool {
                // Unable to parse server data
                if !data {
                    throw OsonoError.Message("Error Saving Media to Server")
                }
            }
        }
        
        // Update Dirty status of Form to false
        override func success() {
            try? media.updateMediaDirty(db: Database.DB(), Dirty: false)
        }
    }
    
}
