//
//  RatingControl.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-08-18.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    //MARK: Properties
    private var ratingButtons = [UIButton]()
    var rating = 0 {
        didSet {
            updateButtonSelectedStates()
        }
    }
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButons()
        }
    }

    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButons()
    }
    
    //MARK: Button Action
    func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button \(button) is not in the rating buttons array \(ratingButtons)")
        }
        
        // calculate the rating of the selected button
        let selectedRating = index + 1
        
        if selectedRating == rating {
            // reset the rating to 0
            rating = 0
        } else {
            // set the rating to the current star
            rating = selectedRating
        }
        
    }
    
    //MARK: Private methods
    private func setupButons() {
        // Clear existing buttons
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        // Load button images
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0..<starCount {
            // Create the button
            let button = UIButton()
            
            // Set the button images
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Setup the button action
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add button to stack
            addArrangedSubview(button)
            
            // Add button to the rating button array
            ratingButtons.append(button)
        }
        
        updateButtonSelectedStates()
    }
    
    private func updateButtonSelectedStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }

}
