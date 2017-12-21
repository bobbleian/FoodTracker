//
//  ECDataEntryViewController.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-09-05.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import os.log

class ECDataEntryViewController: UIViewController, UITextViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textView: UITextView!
    
    var OFElement_ID = 0
    var OFNumber = ""
    
    var entryControl: EntryControl? {
        didSet {
            pickerView?.dataSource = entryControl
            pickerView?.delegate = entryControl
            title = entryControl?.name
            OFElement_ID = (entryControl?.elementID)!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (entryControl != nil) {
            // Set the title of the Navigation Bar
            title = entryControl?.title
            
            // Set up the view, depending on the Entry Control's data entry type
            switch (entryControl?.dataEntryTypeName ?? "") {
            case "OptionList":
                pickerView.isHidden = false
                textView.isHidden = true
                
                // Configure the Picker View
                pickerView.dataSource = entryControl
                pickerView.delegate = entryControl
                if let index = entryControl?.globalList.index(of: (entryControl?.value)!) {
                    pickerView.selectRow(index, inComponent: 0, animated: false)
                }
            case "Numeric":
                textView.keyboardType = .numberPad
                setGenericTextEntry()
            case "Decimal":
                textView.keyboardType = .decimalPad
                setGenericTextEntry()
            case "Text":
                fallthrough
            default:
                setGenericTextEntry()
            }
            
        }
    }
    
    private func setGenericTextEntry() {
        pickerView.isHidden = true
        textView.isHidden = false
        
        // Configure the Text View
        textView.delegate = self
        textView.text = entryControl?.value
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Set up the view, depending on the Entry Control's data entry type
        switch (entryControl?.dataEntryTypeName) {
        case "OptionList"?: ()
        case "Text"?, "Numeric"?:
            fallthrough
        default:
            textView.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // This method lets you configure a view controller before it's presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "EditMediaList":
            guard let mediaTableViewController = segue.destination as? MediaTableViewController else {
                os_log("No MediaTableViewController found", log: OSLog.default, type: .debug)
                return
            }
            mediaTableViewController.entryControl = entryControl
        default:
            os_log("Unknown segue identifier: %@", log: OSLog.default, type: .error, segue.identifier ?? "")
        }
        
    }
    
    //MARK: Action Handlers
    @IBAction func doneNavButtonTapped(_ sender: UIBarButtonItem) {
        if (entryControl != nil) {
            // Save value to the Entry Control, based on the Data Entry Type
            switch (entryControl?.dataEntryTypeName) {
            case "OptionList"?:
                let row = pickerView.selectedRow(inComponent: 0)
                entryControl?.value = (entryControl?.pickerView(pickerView, titleForRow: row, forComponent: 0))!
            case "Text"?, "Numeric"?:
                fallthrough
            default:
                entryControl?.value = textView.text
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Clear Entry Control", message: "Please confirm you want to clear this entry control.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Clear Entry Control", style: .default, handler: { action -> Void in
            self.entryControl?.value = ""
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Continue Editing", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
