//
//  Asset.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-04.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import SQLite

class OLUser {
    
    //MARK: Properties
    var OLUser_ID: Int
    var Run_ID: Int
    var UserName: String
    var Password: String
    var FirstName: String
    var LastName: String
    var PhoneNumber: String
    var MobileNumber: String
    var EmailAddress: String
    var Active: Bool
    var LastUpdate: Date
    
    //MARK: Initialization
    init?(OLUser_ID: Int, Run_ID: Int, UserName: String, Password: String, FirstName: String, LastName: String, PhoneNumber: String, MobileNumber: String,
          EmailAddress: String, Active: Bool, LastUpdate: Date) {
        
        // Initialization fails if OFLinkType_ID is negative
        guard OLUser_ID >= 0 else {
            return nil
        }
        
        // Initialization fails if OFLinkType_ID is negative
        guard Run_ID >= 0 else {
            return nil
        }
        
        // Initialization fails if UserName is empty
        guard !UserName.isEmpty else {
            return nil
        }
        
        // Initialization fails if Password is empty
        guard !Password.isEmpty else {
            return nil
        }
        
        self.OLUser_ID = OLUser_ID
        self.Run_ID = Run_ID
        self.UserName = UserName
        self.Password = Password
        self.FirstName = FirstName
        self.LastName = LastName
        self.PhoneNumber = PhoneNumber
        self.MobileNumber = MobileNumber
        self.EmailAddress = EmailAddress
        self.Active = Active
        self.LastUpdate = LastUpdate
        
    }
    
    //MARK: Database interface
    public static func loadUserPassword(db: Connection, UserName: String) throws -> String? {
        let OLUserTable = Table("OLUser")
        let UserNameExp = Expression<String>("UserName")
        let PasswordExp = Expression<String>("Password")
        
        for passwordValue in try db.prepare(OLUserTable.select(PasswordExp).filter(UserNameExp == UserName)) {
            return passwordValue[PasswordExp]
        }
        return nil
    }
    
}
