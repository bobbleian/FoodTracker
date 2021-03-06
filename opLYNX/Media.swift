//
//  Asset.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
/*
// TEMP ONLY DELETE ALL MEDIA
try? Database.DB().execute("DELETE FROM Media")
try? Database.DB().execute("DELETE FROM OFLinkMedia")
 */
//

import UIKit
import Foundation
import SQLite

class Media {
    
    //MARK: Static Properties
    public static let MEDIA_TYPE_ID_PNG = 51
    
    //MARK: Properties
    var MediaNumber: String
    var Media_Date: Date
    var Asset_ID: Int
    var UniqueMediaNumber: Int
    var MediaType_ID: Int
    var Url: String
    var Description: String
    var Create_Date: Date
    var CreateUser_ID: Int
    var GPSLocation: String
    var LastUpdate: Date
    var Dirty: Bool
    var Content: UIImage?
    
    //MARK: Initialization
    init(MediaNumber: String, Media_Date: Date, Asset_ID: Int, UniqueMediaNumber: Int, MediaType_ID: Int, Url: String, Description: String, Create_Date: Date, CreateUser_ID: Int, GPSLocation: String, LastUpdate: Date, Dirty: Bool, Content: UIImage?) {
        self.MediaNumber = MediaNumber
        self.Media_Date = Media_Date
        self.Asset_ID = Asset_ID
        self.UniqueMediaNumber = UniqueMediaNumber
        self.MediaType_ID = MediaType_ID
        self.Url = Url
        self.Description = Description
        self.Create_Date = Create_Date
        self.CreateUser_ID = CreateUser_ID
        self.GPSLocation = GPSLocation
        self.LastUpdate = LastUpdate
        self.Dirty = Dirty
        self.Content = Content
    }
    
    
    //MARK: Database interface
    public static func loadMediaFromDB(db: Connection, OFNumber: String, OFElement_ID: Int) throws -> [Media] {
        var media = [Media]()
        let MediaTable = Table("Media")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let Media_DateExp = Expression<Date>("Media_Date")
        let Asset_IDExp = Expression<Int>("Asset_ID")
        let UniqueMediaNumberExp = Expression<Int>("UniqueMediaNumber")
        let MediaType_IDExp = Expression<Int>("MediaType_ID")
        let UrlEXP = Expression<String>("Url")
        let DescriptionExp = Expression<String>("Description")
        let Create_DateExp = Expression<Date>("Create_Date")
        let CreateUser_IDExp = Expression<Int>("CreateUser_ID")
        let GPSLocationExp = Expression<String>("GPSLocation")
        let LastUpdateExp = Expression<Date>("LastUpdate")
        let DirtyExp = Expression<Bool>("Dirty")
        let ContentExp = Expression<SQLite.Blob?>("Content")
        
        let OFLinkMediaTable = Table("OFLinkMedia")
        let OFNumberExp = Expression<String>("OFNumber")
        let OFElement_IDExp = Expression<Int>("OFElement_ID")
        
        for mediaRecord in try db.prepare(MediaTable.join(
            OFLinkMediaTable, on: MediaTable[MediaNumberExp] == OFLinkMediaTable[MediaNumberExp]).filter(
                MediaType_IDExp == MEDIA_TYPE_ID_PNG &&
                OFNumberExp == OFNumber &&
                OFElement_IDExp == OFElement_ID).select(MediaTable[*])) {
                    
                    // Get the Media
                    var content: UIImage? = nil
                    if let contentBlob = mediaRecord[ContentExp] {
                        content = UIImage(data: Data.fromDatatypeValue(contentBlob))
                    }
                
                    let mediaItem = Media(MediaNumber: mediaRecord[MediaNumberExp],
                                          Media_Date: mediaRecord[Media_DateExp],
                                          Asset_ID: mediaRecord[Asset_IDExp],
                                          UniqueMediaNumber: mediaRecord[UniqueMediaNumberExp],
                                          MediaType_ID: mediaRecord[MediaType_IDExp],
                                          Url: mediaRecord[UrlEXP],
                                          Description: mediaRecord[DescriptionExp],
                                          Create_Date: mediaRecord[Create_DateExp],
                                          CreateUser_ID: mediaRecord[CreateUser_IDExp],
                                          GPSLocation: mediaRecord[GPSLocationExp],
                                          LastUpdate: mediaRecord[LastUpdateExp],
                                          Dirty: mediaRecord[DirtyExp],
                                          Content: content)
                    
                    media += [mediaItem]
        }
        return media
    }
    
    public static func loadDirtyMediaFromDB(db: Connection) throws -> [Media] {
        var media = [Media]()
        let MediaTable = Table("Media")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let Media_DateExp = Expression<Date>("Media_Date")
        let Asset_IDExp = Expression<Int>("Asset_ID")
        let UniqueMediaNumberExp = Expression<Int>("UniqueMediaNumber")
        let MediaType_IDExp = Expression<Int>("MediaType_ID")
        let UrlEXP = Expression<String>("Url")
        let DescriptionExp = Expression<String>("Description")
        let Create_DateExp = Expression<Date>("Create_Date")
        let CreateUser_IDExp = Expression<Int>("CreateUser_ID")
        let GPSLocationExp = Expression<String>("GPSLocation")
        let LastUpdateExp = Expression<Date>("LastUpdate")
        let DirtyExp = Expression<Bool>("Dirty")
        let ContentExp = Expression<SQLite.Blob?>("Content")
        
        for mediaRecord in try db.prepare(MediaTable.filter(MediaType_IDExp == MEDIA_TYPE_ID_PNG && DirtyExp == true)) {
                        
                        // Get the Media
                        var content: UIImage? = nil
                        if let contentBlob = mediaRecord[ContentExp] {
                            content = UIImage(data: Data.fromDatatypeValue(contentBlob))
                        }
                        
                        let mediaItem = Media(MediaNumber: mediaRecord[MediaNumberExp],
                                              Media_Date: mediaRecord[Media_DateExp],
                                              Asset_ID: mediaRecord[Asset_IDExp],
                                              UniqueMediaNumber: mediaRecord[UniqueMediaNumberExp],
                                              MediaType_ID: mediaRecord[MediaType_IDExp],
                                              Url: mediaRecord[UrlEXP],
                                              Description: mediaRecord[DescriptionExp],
                                              Create_Date: mediaRecord[Create_DateExp],
                                              CreateUser_ID: mediaRecord[CreateUser_IDExp],
                                              GPSLocation: mediaRecord[GPSLocationExp],
                                              LastUpdate: mediaRecord[LastUpdateExp],
                                              Dirty: mediaRecord[DirtyExp],
                                              Content: content)
                        
                        media += [mediaItem]
        }
        return media
    }
    
    public func insertMediaToDB(db: Connection) throws {
        let MediaTable = Table("Media")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let Media_DateExp = Expression<Date>("Media_Date")
        let Asset_IDExp = Expression<Int>("Asset_ID")
        let UniqueMediaNumberExp = Expression<Int>("UniqueMediaNumber")
        let MediaType_IDExp = Expression<Int>("MediaType_ID")
        let UrlEXP = Expression<String>("Url")
        let DescriptionExp = Expression<String>("Description")
        let Create_DateExp = Expression<Date>("Create_Date")
        let CreateUser_IDExp = Expression<Int>("CreateUser_ID")
        let GPSLocationExp = Expression<String>("GPSLocation")
        let LastUpdateExp = Expression<Date>("LastUpdate")
        let DirtyExp = Expression<Bool>("Dirty")
        let ContentExp = Expression<SQLite.Blob?>("Content")
        
        // PNG image
        var contentBlob: Blob? = nil
        if let content = Content, let pngContent = UIImagePNGRepresentation(content) {
            contentBlob = pngContent.datatypeValue
        }
        
        try db.run(MediaTable.insert(MediaNumberExp <- MediaNumber,
                                     Media_DateExp <- Media_Date,
                                     Asset_IDExp <- Asset_ID,
                                     UniqueMediaNumberExp <- UniqueMediaNumber,
                                     MediaType_IDExp <- Media.MEDIA_TYPE_ID_PNG,
                                     UrlEXP <- Url,
                                     DescriptionExp <- Description,
                                     Create_DateExp <- Create_Date,
                                     CreateUser_IDExp <- CreateUser_ID,
                                     GPSLocationExp <- GPSLocation,
                                     LastUpdateExp <- LastUpdate,
                                     DirtyExp <- Dirty,
                                     ContentExp <- contentBlob))
    }
    
    public static func updateMediaToDB(db: Connection, media: Media) throws {
        let MediaTable = Table("Media")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let DescriptionExp = Expression<String>("Description")
        let ContentExp = Expression<SQLite.Blob?>("Content")
        let MediaType_IDExp = Expression<Int>("MediaType_ID")
        let DirtyExp = Expression<Bool>("Dirty")
        
        // PNG image
        var contentBlob: Blob? = nil
        if let content = media.Content, let pngContent = UIImagePNGRepresentation(content) {
            contentBlob = pngContent.datatypeValue
        }
        
        try db.run(MediaTable.filter(MediaNumberExp == media.MediaNumber).update(DescriptionExp <- media.Description, ContentExp <- contentBlob, MediaType_IDExp <- Media.MEDIA_TYPE_ID_PNG, DirtyExp <- true))
    }
    
    public func deleteMediaFromDB(db: Connection) throws {
        let MediaTable = Table("Media")
        let MediaNumberExp = Expression<String>("MediaNumber")
        
        try db.run(MediaTable.filter(MediaNumberExp == MediaNumber).delete())
        
    }
    
    public static func deleteCleanMediaFromDB(db: Connection) throws {
        let MediaTable = Table("Media")
        let DirtyExp = Expression<Bool>("Dirty")
        
        try db.run(MediaTable.filter(DirtyExp == false).delete())
        
    }
    
    // Update Media record's MediaNumber
    public func updateMediaNumber(db: Connection, NewMediaNumber: String, NewUniqueMediaNumber: Int, NewDirty: Bool) throws {
        let MediaTable = Table("Media")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let UniqueMediaNumberExp = Expression<Int>("UniqueMediaNumber")
        let DirtyExp = Expression<Bool>("Dirty")
        
        let OFLinkMediaTable = Table("OFLinkMedia")
        
        // Update the Media and OFLinkMedia tables in a single transaction
        //try db.transaction {
            try db.run(MediaTable.filter(MediaNumberExp == MediaNumber).update(MediaNumberExp <- NewMediaNumber, UniqueMediaNumberExp <- NewUniqueMediaNumber, DirtyExp <- NewDirty))
            try db.run(OFLinkMediaTable.filter(MediaNumberExp == MediaNumber).update(MediaNumberExp <- NewMediaNumber))
        //}
        
        // Update the Media object with the new Media Number, etc
        self.MediaNumber = NewMediaNumber
        self.UniqueMediaNumber = NewUniqueMediaNumber
        self.Dirty = NewDirty
        
    }
    
    // Mark Media as DIRTY so it is part of the list of Media to be sent to the server on a data sync
    public func updateMediaDirty(db: Connection, Dirty: Bool) throws {
        let MediaTable = Table("Media")
        let MediaNumberExp = Expression<String>("MediaNumber")
        let DirtyExp = Expression<Bool>("Dirty")
        try db.run(MediaTable.filter(MediaNumberExp == MediaNumber).update(DirtyExp <- Dirty))
        self.Dirty = Dirty
    }
    
    //MARK: Osono Data Interface
    public func convertToOsono() -> [String: Any] {
        var result = [String: Any]()
        
        // Image contents
        var base64Contents: String = ""
        if let content = Content, let data = UIImagePNGRepresentation(content) {
            print("Image size=\(data.count/1024)kb")
            base64Contents = data.base64EncodedString()
        }
        
        result["ai"] = String(Asset_ID)
        result["cd"] = Create_Date.formatJsonDate()
        result["contents"] = base64Contents
        result["cui"] = String(CreateUser_ID)
        result["des"] = Description
        result["gps"] = GPSLocation
        result["md"] = Media_Date.formatJsonDate()
        result["mn"] = MediaNumber
        result["mti"] = MediaType_ID
        result["umn"] = String(UniqueMediaNumber)
        result["url"] = Url
        
        return result
    }
    
}

