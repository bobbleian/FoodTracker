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
    @IBOutlet weak var passwordTextField: UITextField!
    
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
/*
     test
     AAyjKXBE1f2FFO3vyss9St8Xc8oPOEffyu73uXi9akdznG2zwjCIIhX/fHfumiiIwA==
     
     d4
     AIAubpsxSDvqiOcnH/vgS+9bOPS6dGtpmX0uAf+vfDJzP1ExkHrKEgM/e5UIpQ7IGg==
     
     this is a long test
     AO110rX5nZpqDYs08RJPr5uU9QRfuanzggITVgEF0JY4CGM6u8uXysdhC4FdOGG7Gg==
     
     hello world
     ALR2YrZQnbQ9P8Puvgyfv5HH926LlbO6/fQzJpYj+KrI4IyCR+g/+OqhfpRNeOKyZw==
     
     !Hello@25$
     AMsPWS5rqlqnTm79Z5f3ecg5AtopqphJOrE79iLl4KUYDUDgJOX7hA8pHn8OA7Lz1A==
 */
    @IBAction func StartRun(_ sender: UIButton) {
        // Save the user name
        do {
            try LocalSettings.updateSettingsValue(db: Database.DB(), Key: LoginViewController.LAST_USER_KEY, Value: userNameTextField.text!)
        }
        catch {
            
        }
        
        // Get the user name's hashed password from the database
        do {
            guard let hashedPassword = try OLUser.loadUserPassword(db: Database.DB(), UserName: userNameTextField.text!) else {
                // TODO: error message here
                return
            }
            let hashMatches = PasswordHasher.VerifyHashedPassword(base64HashedPassword: hashedPassword, password: passwordTextField.text!)
            if (hashMatches) {
                performSegue(withIdentifier: "ShowOperationalFormList", sender: self)
            }
            // TODO: error message here
        }
        catch {
            // TODO: error message here
            return
        }
        
        
    }
    

}
