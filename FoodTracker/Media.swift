//
//  Asset.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import Foundation
import SQLite

class Media {
    
    static let MediaType_ID_PNG = 51
    
    //MARK: Properties
    var MediaNumber: String
    var Description: String
    var ImageContent: UIImage?
    
    //MARK: Initialization
    init?(MediaNumber: String, Description: String, ImageContent: UIImage?) {
        
        // Initialization fails if name is empty
        guard !MediaNumber.isEmpty else {
            return nil
        }
        
        self.MediaNumber = MediaNumber
        self.Description = Description
        self.ImageContent = ImageContent
    }
    
    
    //MARK: Database interface
    public static func loadMediaFromDB(db: Connection) throws -> [Media] {
        var media = [Media]()
        let MediaTable = Table("Media")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let DescriptionExp = Expression<String>("Description")
        let ContentExp = Expression<SQLite.Blob?>("Content")
        let MediaType_IDExp = Expression<Int64>("MediaType_ID")
        
        for mediaRecord in try db.prepare(MediaTable.filter(MediaType_IDExp == Int64(MediaType_ID_PNG))) {
            guard let mediaItem = Media(
                MediaNumber: mediaRecord[MediaNumberExp],
                Description: mediaRecord[DescriptionExp],
                ImageContent: mediaRecord[ContentExp] != nil ? UIImage(data: Data.fromDatatypeValue(mediaRecord[ContentExp]!)) : nil)
                /*
                OFNumber: operationalFormRecord[OFNumber],
                //photo: meal[photo] != nil ? UIImage(data: Data.fromDatatypeValue(meal[photo]!)) : nil,
                photo: nil,
                OFType_ID: Int(exactly: operationalFormRecord[OFType_ID]) ?? 0,
                type: "Type",
                Due_Date: operationalFormRecord[Due_Date],
                key1: "Surface Location",
                key2: "Location Name",
                key3: "UWI")
                 */
                else {
                    fatalError("Unable to load media from database")
            }
            media += [mediaItem]
        }
        return media
    }
    
    
    public static func updateMediaToDB(db: Connection, media: Media) throws {
        let MediaTable = Table("Media")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let DescriptionExp = Expression<String>("Description")
        let ContentExp = Expression<SQLite.Blob?>("Content")
        let MediaType_IDExp = Expression<Int64>("MediaType_ID")
        
        try db.run(MediaTable.filter(MediaNumberExp == media.MediaNumber).update(DescriptionExp <- media.Description,
                                                                                 ContentExp <- (media.ImageContent != nil ? UIImagePNGRepresentation(media.ImageContent!)!.datatypeValue : nil),
                                                                                 MediaType_IDExp <- Int64(MediaType_ID_PNG)))

    }
    
}

