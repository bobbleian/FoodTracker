//
//  EntryControl.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-08-28.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit

@IBDesignable class EntryControl: UIStackView {

    //MARK: Properties
    let entryTitle = UILabel()
    let entryValue = UILabel()
    
    @IBInspectable var title: String = " " {
        didSet {
            entryTitle.text = title
        }
    }
    @IBInspectable var value: String = " " {
        didSet {
            entryValue.text = value
        }
    }
    @IBInspectable var propertyID: Int = 0 {
        didSet {
            
        }
    }
    @IBInspectable var name: String = "Name" {
        didSet {
            
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildEntryControl()
    }
        
    required init(coder: NSCoder) {
        super.init(coder: coder)
        buildEntryControl()
    }
    
    private func buildEntryControl() {
        
        // set the orientation to veritcal
        axis = .vertical
        
        // set up the background
        let backGroundView = UIControl()
        backGroundView.backgroundColor = .white
        backGroundView.translatesAutoresizingMaskIntoConstraints = false
        //backGroundView.layer.cornerRadius = 3
        //backGroundView.layer.masksToBounds = true
        addSubview(backGroundView)
        backGroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backGroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backGroundView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        backGroundView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        entryTitle.text = title
        entryTitle.textAlignment = .center
        entryTitle.backgroundColor = .green
        //entryTitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
        //entryTitle.widthAnchor.constraint(equalToConstant: 20).isActive = true
        addArrangedSubview(entryTitle)
        
        entryValue.text = value
        entryValue.textAlignment = .center
        entryValue.backgroundColor = .white
        //entryValue.heightAnchor.constraint(equalToConstant: 20).isActive = true
        //entryValue.widthAnchor.constraint(equalToConstant: 20).isActive = true
        addArrangedSubview(entryValue)
        
        // Setup the Tap action
        backGroundView.addTarget(self, action: #selector(EntryControl.ecTapped(entryControl:)), for: .touchUpInside)
        
    }
    
    func ecTapped(entryControl: EntryControl) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Inspected?", message: nil, preferredStyle: .actionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            //Do some other stuff
        }
        actionSheetController.addAction(takePictureAction)
        //Create and add a second option action
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "No", style: .default) { action -> Void in
            //Do some other stuff
        }
        actionSheetController.addAction(choosePictureAction)
        
        //We need to provide a popover sourceView when using it on iPad
        //actionSheetController.popoverPresentationController?.sourceView = sender as? UIView;
        
        //Present the AlertController
        viewController?.present(actionSheetController, animated: true, completion: nil)
    }
    

    
}

extension EntryControl {
    var viewController : UIViewController? {
        var responder: UIResponder? = self
        while (responder != nil) {
            if let responder = responder as? UIViewController {
                return responder
            }
            responder = responder?.next
        }
        return nil
    }
}

