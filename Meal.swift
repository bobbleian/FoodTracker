//
//  Meal.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-08-21.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit

class Meal {
    //MARK: Properties
    var name: String
    var photo: UIImage?
    var rating: Int
    var type: String = "type"
    var dueDate: String = "due date"
    var key1: String = "key 1"
    var key2: String = "key 2"
    var key3: String = "key 3"
    
    //MARK: Initialization
    init?(name: String, photo: UIImage?, rating: Int, type: String, dueDate: String, key1: String, key2: String, key3: String) {
        
        // Initialization fails if name is empty
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialization fails if rating is out of range
        guard rating >= 0 && rating <= 5 else {
            return nil
        }
        
        self.name = name
        self.photo = photo
        self.rating = rating
        self.type = type
        self.dueDate = dueDate
        self.key1 = key1
        self.key2 = key2
        self.key3 = key3
    }
}
