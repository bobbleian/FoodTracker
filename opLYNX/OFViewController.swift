//
//  OFViewController.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-08-11.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import SQLite
import os.log

class OFViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var containerViewA: UIView!
    @IBOutlet weak var containerViewB: UIView!
    @IBOutlet weak var containerViewC: UIView!
    @IBOutlet weak var containerViewD: UIView!
    @IBOutlet weak var containerViewE: UIView!
    

	// This value is set by the OFTableViewController in the prepare function
    var operationalForm: OperationalForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up views for editing an Operational Form
        if let operationalForm = operationalForm {
            navigationItem.title = operationalForm.OFNumber
        
            // Load Entry Control values from the database
            let entryControls = getEntryControlSubviews(v: view)
            for entryControl in entryControls {
                do {
                    entryControl.value = try OFElementData.loadOFElementValue(db: Database.DB(), OFNumber: operationalForm.OFNumber, OFElement_ID: entryControl.elementID)
                    entryControl.ofNumber = operationalForm.OFNumber
                }
                catch {
                    os_log("Unable to load OFDataValues from database", log: OSLog.default, type: .error)
                }
            }
        }
    }
    
    // Get all EntryControl controls by traversing the view hierarchy
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
    
    // Public function to return all EntryControl controls
    public func getEntryControlSubviews() -> [EntryControl] {
        return getEntryControlSubviews(v: self.view)
    }
    
    //MARK: Navigation
    
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
            ecDataEntryViewController.OFNumber = (operationalForm?.OFNumber)!
        default:
            //os_log("Unexpected segue identifier; \(segue.identifier ?? "")", log: OSLog.default, type: .error)
            os_log("Unexpected segue identifier", log: OSLog.default, type: .error)
        }
        
    }
    
    //MARK: Actions
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
    
    @IBAction func saveOperationalForm(_ sender: UIBarButtonItem) {
            
        if let operationalForm = operationalForm {
            let entryControls = getEntryControlSubviews()
            
            var ofElementDatas = [OFElementData]()
            do {
                for entryControl in entryControls {
                    if let ofElementData = OFElementData(OFNumber: operationalForm.OFNumber, OFElement_ID: entryControl.elementID, Value: entryControl.value) {
                        try ofElementData.insertOrUpdatepdateOFElementValue(db: Database.DB())
                        ofElementDatas.append(ofElementData)
                    }
                }
                try OperationalForm.updateOFDirty(db: Database.DB(), OFNumber: operationalForm.OFNumber, Dirty: true)
                operationalForm.Dirty = true
            }
            catch {
                // TODO: Handle database error
                os_log("Unable to save Operational Form Data to database OFNumber=%@", log: OSLog.default, type: .error, operationalForm.OFNumber)
            }
            
            operationalForm.ElementData = ofElementDatas
        
            // Update Form status
            // Ask user if they want the status to be set to Complete (TODO: ONLY if all mandatory fields are complete)
            // Only present option to user if the Form is complete
            if operationalForm.isFormComplete() {
                let alert = UIAlertController(title: "Form Status", message: "Would you like to mark this operational form as COMPLETE?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action -> Void in
                    operationalForm.OFStatus_ID = OperationalForm.OF_STATUS_INPROGRESS
                    try? OperationalForm.updateOFStatus(db: Database.DB(), OFNumber: operationalForm.OFNumber, OFStatus_ID: OperationalForm.OF_STATUS_INPROGRESS)
                    self.performSegue(withIdentifier: "Save", sender: self)
                }))
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action -> Void in
                    // TODO: Set Complete Date?
                    operationalForm.OFStatus_ID = OperationalForm.OF_STATUS_COMPLETE
                    try? OperationalForm.updateOFStatus(db: Database.DB(), OFNumber: operationalForm.OFNumber, OFStatus_ID: OperationalForm.OF_STATUS_COMPLETE)
                    self.performSegue(withIdentifier: "Save", sender: self)
                }))
                present(alert, animated: true, completion: nil)
                return
            }
            // If Form is not complete, set status to InProgress
            else {
                operationalForm.OFStatus_ID = OperationalForm.OF_STATUS_INPROGRESS
                try? OperationalForm.updateOFStatus(db: Database.DB(), OFNumber: operationalForm.OFNumber, OFStatus_ID: OperationalForm.OF_STATUS_INPROGRESS)
                self.performSegue(withIdentifier: "Save", sender: self)
            }
        }
        
        // This should never happen - navigate back as Cancel
        self.performSegue(withIdentifier: "Cancel", sender: self)
 
    }
    
}

