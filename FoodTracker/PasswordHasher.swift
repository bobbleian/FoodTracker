//
//  PasswordHasher.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-23.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import CryptoSwift

class PasswordHasher {
    static func VerifyHashedPassword(base64HashedPassword: String, password: String) -> Bool {
        
        // Constants
        let saltStart = 0x1
        let saltLength = 0x10
        let hashLength = 0x20
        let pbkdf2Iterations = 0x3e8
        let pbkdf2KeyLength = 128
        
        var result = false
        
        let passwordBytes: Array<UInt8> = Array(password.utf8)
        
        guard let base64DecodedDotNetHash = Data(base64Encoded: base64HashedPassword) else {
            return false
        }
        
        let thecount = base64DecodedDotNetHash.count
        guard thecount >= saltStart + saltLength + hashLength else {
            return false
        }
        
        var salt: Array<UInt8> = Array<UInt8>()
        for i in saltStart..<saltStart+saltLength {
            salt.append(base64DecodedDotNetHash[i])
        }
        
        var decodedhash: Array<UInt8> = Array<UInt8>()
        for i in saltStart+saltLength..<saltStart+saltLength+hashLength {
            decodedhash.append(base64DecodedDotNetHash[i])
        }
        
        var newhashedpassword: Array<UInt8> = Array<UInt8>()
        var hashMatches = true
        do {
            newhashedpassword = try PKCS5.PBKDF2(password: passwordBytes, salt: salt, iterations: pbkdf2Iterations, keyLength: pbkdf2KeyLength, variant: .sha1).calculate()
            for i in 0..<hashLength {
                if newhashedpassword[i] != decodedhash[i] {
                    hashMatches = false
                    break
                }
            }
        }
        catch {
            hashMatches = false
        }
        return hashMatches
    }
}
