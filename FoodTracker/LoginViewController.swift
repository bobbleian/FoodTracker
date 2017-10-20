//
//  LoginViewController.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-08-30.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import CryptoSwift

class LoginViewController: UIViewController {
    
    static let LAST_USER_KEY = "LastUserLoggedIntoOplynx"

    //MARK: Properties
    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            if let lastUser = try LocalSettings.loadSettingsValue(db: Database.DB(), Key: LoginViewController.LAST_USER_KEY) {
                userNameTextField.text = lastUser
            }
        }
        catch {
            
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
    
    //MARK: Actions
    @IBAction func StartRun(_ sender: UIButton) {
        // Save the user name
        do {
            try LocalSettings.updateSettingsValue(db: Database.DB(), Key: LoginViewController.LAST_USER_KEY, Value: userNameTextField.text!)
        }
        catch {
            
        }
        let password: Array<UInt8> = Array("infoH@WK20".utf8)
        let salt: Array<UInt8> = Array("nacllcan".utf8)
        do {
            try PKCS5.PBKDF2(password: password, salt: salt, iterations: 0x3e8, keyLength: 128, variant: .sha1)
        }
        catch {
            
        }
        performSegue(withIdentifier: "ShowOperationalFormList", sender: self)
    }
    

}
