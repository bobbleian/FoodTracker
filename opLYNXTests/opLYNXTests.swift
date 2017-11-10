//
//  opLYNXTests.swift
//  opLYNXTests
//
//  Created by oplynx developer on 2017-11-01.
//  Copyright © 2017 CIS. All rights reserved.
//

import XCTest
@testable import opLYNX

class opLYNXTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Test the Password Hash function against known values
    func testPasswordHasher() {
        XCTAssertTrue(PasswordHasher.VerifyHashedPassword(base64HashedPassword: "AAyjKXBE1f2FFO3vyss9St8Xc8oPOEffyu73uXi9akdznG2zwjCIIhX/fHfumiiIwA==", password: "test"))
        XCTAssertTrue(PasswordHasher.VerifyHashedPassword(base64HashedPassword: "AIAubpsxSDvqiOcnH/vgS+9bOPS6dGtpmX0uAf+vfDJzP1ExkHrKEgM/e5UIpQ7IGg==", password: "d4"))
        XCTAssertTrue(PasswordHasher.VerifyHashedPassword(base64HashedPassword: "AO110rX5nZpqDYs08RJPr5uU9QRfuanzggITVgEF0JY4CGM6u8uXysdhC4FdOGG7Gg==", password: "this is a long test"))
        XCTAssertTrue(PasswordHasher.VerifyHashedPassword(base64HashedPassword: "ALR2YrZQnbQ9P8Puvgyfv5HH926LlbO6/fQzJpYj+KrI4IyCR+g/+OqhfpRNeOKyZw==", password: "hello world"))
        XCTAssertTrue(PasswordHasher.VerifyHashedPassword(base64HashedPassword: "AMsPWS5rqlqnTm79Z5f3ecg5AtopqphJOrE79iLl4KUYDUDgJOX7hA8pHn8OA7Lz1A==", password: "!Hello@25$"))
        XCTAssertFalse(PasswordHasher.VerifyHashedPassword(base64HashedPassword: "This should", password: "not match"))
    }
    
    // Test OsonoServerTask URL creation against known values
    func testOsonoServerTaskGenerateURL() {
        let osonoTask = OsonoServerTask(serverIP: "199.180.29.38", serverPort: "13616", serverMethod: "http", application: "opLYNXJSON", module: "auth", method: "registerasset")
        osonoTask.addParameter(name: "asset_name", value: "CIS9")
        osonoTask.addParameter(name: "client_id", value: "ba91fecd-7371-4466-a11e-8b44a99ee809")
        XCTAssertEqual(osonoTask.generateURLString(), "http://199.180.29.38:13616/opLYNXJSON/auth/registerasset?asset_name=CIS9&client_id=ba91fecd-7371-4466-a11e-8b44a99ee809")
    }
    
    // Test JSON date formatting extension (For UTC Epoch time since 1970)
    func testJSONDateFormatting() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateString = "Jan 1, 2000"
        if let date = dateFormatter.date(from: dateString) {
            // Test generating the JSON/Microsoft formatted string from a date object
            XCTAssertEqual(date.formatJsonDate(), "/Date(946710000000)/")
            
            // Test generating a Date object from a JSON/Microsoft formatted string
            let jsonCreatedDate = Date(jsonDate: "/Date(946710000000)/")
            XCTAssertNotNil(jsonCreatedDate)
            XCTAssertEqual(jsonCreatedDate!, date)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}


