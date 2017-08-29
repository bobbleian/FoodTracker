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
    
    //MARK: Initialization
    init?(name: String, photo: UIImage?, rating: Int) {
        
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
    }
}
