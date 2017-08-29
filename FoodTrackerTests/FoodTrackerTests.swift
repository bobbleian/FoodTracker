//
//  FoodTrackerTests.swift
//  FoodTrackerTests
//
//  Created by oplynx developer on 2017-08-11.
//  Copyright © 2017 CIS. All rights reserved.
//

import XCTest
@testable import FoodTracker

class FoodTrackerTests: XCTestCase {
    
    //MARK: Meal Class Tests
    
    // Confirm meal initializer returns a Meal object when passed valid parameters
    func testMealInitializationSucceeds() {
        // Zero Rating
        let zeroRatingMeal = Meal.init(name: "Zero", photo: nil, rating: 0)
        XCTAssertNotNil(zeroRatingMeal)
        
        // Highest Rating
        let positiveRatingMeal = Meal.init(name: "Positive", photo: nil, rating: 5)
        XCTAssertNotNil(positiveRatingMeal)
    }
    
    // Confirm Meal initializer fails when passes an empty name or negative rating
    func testMealInitializerFails() {
        // Negative rating
        let negativeRatingMeal = Meal.init(name: "Negative", photo: nil, rating: -1)
        XCTAssertNil(negativeRatingMeal)
        
        // Empty name
        let emptyStringMeal = Meal.init(name: "", photo: nil, rating: 1)
        XCTAssertNil(emptyStringMeal)
        
        // Rating exceeds maximum
        let largeRatingMeal = Meal.init(name: "Large", photo: nil, rating: 6)
        XCTAssertNil(largeRatingMeal)
       
        
    }
    
}
