//
//  ECDataEntryViewController.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-09-05.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit

class ECDataEntryViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var pickerView: UIPickerView!
    var entryControl: EntryControl? {
        didSet {
            pickerView?.dataSource = entryControl
            pickerView?.delegate = entryControl
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (entryControl != nil) {
            pickerView?.dataSource = entryControl
            pickerView?.delegate = entryControl
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Action Handlers
    @IBAction func dismissButtonTapped(sender: UIButton) {
        // Set the text on the entry control
        if (entryControl != nil) {
            let row = pickerView.selectedRow(inComponent: 0)
            entryControl?.value = (entryControl?.pickerView(pickerView, titleForRow: row, forComponent: 0))!
        }
        dismiss(animated: true, completion: nil)
    }

}
