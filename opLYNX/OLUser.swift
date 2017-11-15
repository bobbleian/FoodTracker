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
        
        if let passwordValue = try db.pluck(OLUserTable.select(PasswordExp).filter(UserNameExp == UserName)) {
            return passwordValue[PasswordExp]
        }
        return nil
    }
    
    public static func loadUser(db: Connection, UserName: String) throws -> OLUser? {
        let OLUserTable = Table("OLUser")
        let OLUser_IDExp = Expression<Int64>("OLUser_ID")
        let Run_IDExp = Expression<Int64>("Run_ID")
        let UserNameExp = Expression<String>("UserName")
        let PasswordExp = Expression<String>("Password")
        let FirstNameExp = Expression<String>("FirstName")
        let LastNameExp = Expression<String>("LastName")
        let PhoneNumberExp = Expression<String>("PhoneNumber")
        let MobileNumberExp = Expression<String>("MobileNumber")
        let EmailAddressExp = Expression<String>("EmailAddress")
        let ActiveExp = Expression<Bool>("Active")
        let LastUpdateExp = Expression<Date>("LastUpdate")
        
        guard let userRecord = try db.pluck(OLUserTable.filter(UserNameExp == UserName)) else {
            // No user record found for this user name
            return nil
        }
        
        return OLUser(OLUser_ID: Int(exactly: userRecord[OLUser_IDExp]) ?? 0, Run_ID: Int(exactly: userRecord[Run_IDExp]) ?? 0, UserName: userRecord[UserNameExp], Password: userRecord[PasswordExp], FirstName: userRecord[FirstNameExp], LastName: userRecord[LastNameExp], PhoneNumber: userRecord[PhoneNumberExp], MobileNumber: userRecord[MobileNumberExp], EmailAddress: userRecord[EmailAddressExp], Active: userRecord[ActiveExp], LastUpdate: userRecord[LastUpdateExp])
        
    }
    
    public func updateUser(db: Connection) throws {
        let OLUserTable = Table("OLUser")
        let OLUser_IDExp = Expression<Int64>("OLUser_ID")
        let Run_IDExp = Expression<Int64>("Run_ID")
        let UserNameExp = Expression<String>("UserName")
        let PasswordExp = Expression<String>("Password")
        let FirstNameExp = Expression<String>("FirstName")
        let LastNameExp = Expression<String>("LastName")
        let PhoneNumberExp = Expression<String>("PhoneNumber")
        let MobileNumberExp = Expression<String>("MobileNumber")
        let EmailAddressExp = Expression<String>("EmailAddress")
        let ActiveExp = Expression<Bool>("Active")
        let LastUpdateExp = Expression<Date>("LastUpdate")
        
        // First try updating the entry
        if try db.run(OLUserTable.filter(OLUser_IDExp == Int64(OLUser_ID)).update(Run_IDExp <- Int64(Run_ID),
                                                                                  UserNameExp <- UserName,
                                                                                  PasswordExp <- Password,
                                                                                  FirstNameExp <- FirstName,
                                                                                  LastNameExp <- LastName,
                                                                                  PhoneNumberExp <- PhoneNumber,
                                                                                  MobileNumberExp <- MobileNumber,
                                                                                  EmailAddressExp <- EmailAddress,
                                                                                  ActiveExp <- Active,
                                                                                  LastUpdateExp <- Date())) == 0 {
            // No records updated, try an insert
            try db.run(OLUserTable.insert(OLUser_IDExp <- Int64(OLUser_ID),
                                          Run_IDExp <- Int64(Run_ID),
                                          UserNameExp <- UserName,
                                          PasswordExp <- Password,
                                          FirstNameExp <- FirstName,
                                          LastNameExp <- LastName,
                                          PhoneNumberExp <- PhoneNumber,
                                          MobileNumberExp <- MobileNumber,
                                          EmailAddressExp <- EmailAddress,
                                          ActiveExp <- Active,
                                          LastUpdateExp <- Date()))
        }
    }
    
}
