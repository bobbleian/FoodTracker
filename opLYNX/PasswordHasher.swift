//
//  PasswordHasher.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-23.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation
import CryptoSwift

class PasswordHasher {
    static func VerifyHashedPassword(base64HashedPassword: String, password: String) -> Bool {
        
        // Constants for PBKDF2 hashing
        let saltStart = 0x1
        let saltLength = 0x10
        let hashLength = 0x20
        let pbkdf2Iterations = 0x3e8
        let pbkdf2KeyLength = 128
        
        // Convert password to array of bytes
        let passwordBytes: Array<UInt8> = Array(password.utf8)
        
        // Base64 decode the hashed password value
        guard let base64DecodedDotNetHash = Data(base64Encoded: base64HashedPassword) else {
            return false
        }
        
        // Check that the decoded hashed password is the correct minimum length
        guard base64DecodedDotNetHash.count >= saltStart + saltLength + hashLength else {
            return false
        }
        
        // Extract the salt value
        var salt: Array<UInt8> = Array<UInt8>()
        for i in saltStart..<saltStart+saltLength {
            salt.append(base64DecodedDotNetHash[i])
        }
        
        // Extract the hashed password value
        var decodedhash: Array<UInt8> = Array<UInt8>()
        for i in saltStart+saltLength..<saltStart+saltLength+hashLength {
            decodedhash.append(base64DecodedDotNetHash[i])
        }
        
        // Generate the equivalent hash of the password passed in, using the extracted salt value
        var newhashedpassword: Array<UInt8> = Array<UInt8>()
        var hashMatches = true
        do {
            let newhashedpassword = try PKCS5.PBKDF2(password: passwordBytes, salt: salt, iterations: pbkdf2Iterations, keyLength: pbkdf2KeyLength, variant: .sha1).calculate()
            // Compare the generated hash to the original hash
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
