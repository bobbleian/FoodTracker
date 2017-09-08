//
//  ECGridViewController.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-09-07.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import os.log

class ECGridViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let entryControl = sender as? EntryControl else {
            os_log("No EntryControl object passed as sender", log: OSLog.default, type: .debug)
            return
        }
        
        switch (segue.identifier ?? "") {
        case "editData":
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
            fatalError("Unexpected segue identifier; \(segue.identifier ?? "")")
        }
        
    }
    

}
