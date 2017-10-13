//
//  MealViewController.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-08-11.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import SQLite
import os.log

class MealViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var containerViewA: UIView!
    @IBOutlet weak var containerViewB: UIView!
    @IBOutlet weak var containerViewC: UIView!
    @IBOutlet weak var containerViewD: UIView!
    @IBOutlet weak var containerViewE: UIView!
    
    /*
     This value is either passed by MealTableViewController in prepare(for:sender:)
     or constructed as part of adding a new meal
     */
    var meal: OperationalForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up views if editing an existing Meal
        if let meal = meal {
            navigationItem.title = meal.OFNumber
            //nameTextField.text = meal.name
            //photoImageView.image = meal.photo
            //ratingControl.rating = meal.rating
        }
        
        // Load Entry Control values from the database
        let entryControls = getEntryControlSubviews(v: view)
        for entryControl in entryControls {
            do {
                let dbFile = try MealTableViewController.makeWritableCopy(named: "oplynx.db", ofResourceFile: "oplynx.db")
                let db = try Connection(dbFile.path)
                entryControl.value = try OFElementData.loadOFElementValue(db: db, OFNumber: (meal?.OFNumber)!, OFElement_ID: entryControl.elementID)
            }
            catch {
                os_log("Unable to load OFDataValues from database", log: OSLog.default, type: .error)
            }
        }
        
        // Enable Save button only if the Meal has a valid name
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the save button while editing
        saveButton.isEnabled = false
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // use original image
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else
        {
            fatalError("Expected a dictionary containing an image but was provided the following: \(info)")
        }
        
        // Set the photoImageView to display the selected image
        //photoImageView.image = selectedImage
        
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Dismiss view based on type of presentation (modal vs. push)
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if (isPresentingInAddMealMode) {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller")
        }
        
    }
    
    
    // This method lets you configure a view controller before it's presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "editData":
            guard let entryControl = sender as? EntryControl else {
                os_log("No EntryControl object passed as sender", log: OSLog.default, type: .debug)
                return
            }
            guard let ecDataEntryNavigationController = segue.destination as? ECDataEntryNavigationController else {
                os_log("No ECDataEntryNavigationController found", log: OSLog.default, type: .debug)
                return
            }
            guard let ecDataEntryViewController = ecDataEntryNavigationController.viewControllers[0] as? ECDataEntryViewController else {
                os_log("No ECDataEntryViewController found", log: OSLog.default, type: .debug)
                return
            }
            ecDataEntryViewController.entryControl = entryControl
        default:
            //os_log("Unexpected segue identifier; \(segue.identifier ?? "")", log: OSLog.default, type: .error)
            os_log("Unexpected segue identifier", log: OSLog.default, type: .error)
        }
        
    }
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide keyboard
        //nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library
        let imagePickerController = UIImagePickerController()
        // Only allow photos to be selected, not taken
        imagePickerController.sourceType = .photoLibrary
        // make sure the viewcontroller is notified when the user picks an image
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func showActionSheetTapped(sender: AnyObject) {
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
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func showContainerView(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UIView.animate(withDuration: 0.5, animations: {
                self.containerViewA.alpha = 1
                self.containerViewB.alpha = 0
                self.containerViewC.alpha = 0
                self.containerViewD.alpha = 0
                self.containerViewE.alpha = 0
            })
        case 1:
            UIView.animate(withDuration: 0.5, animations: {
                self.containerViewA.alpha = 0
                self.containerViewB.alpha = 1
                self.containerViewC.alpha = 0
                self.containerViewD.alpha = 0
                self.containerViewE.alpha = 0
            })
        case 2:
            UIView.animate(withDuration: 0.5, animations: {
                self.containerViewA.alpha = 0
                self.containerViewB.alpha = 0
                self.containerViewC.alpha = 1
                self.containerViewD.alpha = 0
                self.containerViewE.alpha = 0
            })
        case 3:
            UIView.animate(withDuration: 0.5, animations: {
                self.containerViewA.alpha = 0
                self.containerViewB.alpha = 0
                self.containerViewC.alpha = 0
                self.containerViewD.alpha = 1
                self.containerViewE.alpha = 0
            })
        case 4:
            UIView.animate(withDuration: 0.5, animations: {
                self.containerViewA.alpha = 0
                self.containerViewB.alpha = 0
                self.containerViewC.alpha = 0
                self.containerViewD.alpha = 0
                self.containerViewE.alpha = 1
            })
        default:
            UIView.animate(withDuration: 0.5, animations: {
                self.containerViewA.alpha = 1
                self.containerViewB.alpha = 0
                self.containerViewC.alpha = 0
                self.containerViewD.alpha = 0
                self.containerViewE.alpha = 0
            })
        }
    }
    
    //MARK: Private
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty
        //let text = nameTextField.text ?? ""
        //saveButton.isEnabled = !text.isEmpty
    }
    
    private func getEntryControlSubviews(v: UIView) -> [EntryControl] {
        var entryControls = [EntryControl]()
        for subview in v.subviews {
            entryControls += getEntryControlSubviews(v: subview)
            if (subview is EntryControl) {
                entryControls.append(subview as! EntryControl)
            }
        }
        return entryControls
    }
    
    public func getEntryControlSubviews() -> [EntryControl] {
        return getEntryControlSubviews(v: self.view)
    }
    
}

