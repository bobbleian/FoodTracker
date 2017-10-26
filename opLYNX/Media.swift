//
//  Asset.swift
//  opLYNX
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
    init(MediaNumber: String, Description: String, ImageContent: UIImage?) {
        self.MediaNumber = MediaNumber
        self.Description = Description
        self.ImageContent = ImageContent
    }
    
    
    //MARK: Database interface
    public static func loadMediaFromDB(db: Connection, OFNumber: String, OFElement_ID: Int) throws -> [Media] {
        var media = [Media]()
        let MediaTable = Table("Media")
        let OFLinkMediaTable = Table("OFLinkMedia")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let DescriptionExp = Expression<String>("Description")
        let ContentExp = Expression<SQLite.Blob?>("Content")
        let MediaType_IDExp = Expression<Int64>("MediaType_ID")
        let OFNumberExp = Expression<String>("OFNumber")
        let OFElement_IDExp = Expression<Int64>("OFElement_ID")
        
        for mediaRecord in try db.prepare(MediaTable.join(
            OFLinkMediaTable, on: MediaTable[MediaNumberExp] == OFLinkMediaTable[MediaNumberExp]).filter(
                MediaType_IDExp == Int64(MediaType_ID_PNG) &&
                OFNumberExp == OFNumber &&
                OFElement_IDExp == Int64(OFElement_ID)).select(MediaTable[*])) {
                
            let mediaItem = Media(
                MediaNumber: mediaRecord[MediaNumberExp],
                Description: mediaRecord[DescriptionExp],
                ImageContent: mediaRecord[ContentExp] != nil ? UIImage(data: Data.fromDatatypeValue(mediaRecord[ContentExp]!)) : nil)
            media += [mediaItem]
        }
        return media
    }
    
    public static func insertMediaToDB(db: Connection, media: Media) throws {
        let MediaTable = Table("Media")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let Media_DateExp = Expression<Date>("Media_Date")
        let Asset_IDExp = Expression<Int64>("Asset_ID")
        let UniqueMediaNumberExp = Expression<Int64>("UniqueMediaNumber")
        let MediaType_IDExp = Expression<Int64>("MediaType_ID")
        let UrlEXP = Expression<String>("Url")
        let DescriptionExp = Expression<String>("Description")
        let Create_DateExp = Expression<Date>("Create_Date")
        let CreateUser_IDExp = Expression<Int64>("CreateUser_ID")
        let GPSLocationExp = Expression<String>("GPSLocation")
        let LastUpdateExp = Expression<Date>("LastUpdate")
        let DirtyExp = Expression<Bool>("Dirty")
        let ContentExp = Expression<SQLite.Blob?>("Content")
        
        try db.run(MediaTable.insert(MediaNumberExp <- media.MediaNumber,
                                     Media_DateExp <- Date(),
                                     Asset_IDExp <- 0,
                                     UniqueMediaNumberExp <- 0,
                                     MediaType_IDExp <- Int64(MediaType_ID_PNG),
                                     UrlEXP <- "",
                                     DescriptionExp <- media.Description,
                                     Create_DateExp <- Date(),
                                     CreateUser_IDExp <- 0,
                                     GPSLocationExp <- "",
                                     LastUpdateExp <- Date(),
                                     DirtyExp <- true,
                                     ContentExp <- (media.ImageContent != nil ? UIImagePNGRepresentation(media.ImageContent!)!.datatypeValue : nil)))
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
    
    public static func deleteMediaFromDB(db: Connection, media: Media) throws {
        let MediaTable = Table("Media")
        let MediaNumberExp = Expression<String>("MediaNumber")
        
        try db.run(MediaTable.filter(MediaNumberExp == media.MediaNumber).delete())
        
    }
    
}

