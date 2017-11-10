//
//  LoginViewController.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-08-30.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import CryptoSwift

class LoginViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    //MARK: Properties
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var runTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeField: UITextField?
    
    
    let runPickerView = UIPickerView()
    var runs = [Run]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            if let lastUser = try LocalSettings.loadSettingsValue(db: Database.DB(), Key: LocalSettings.LOGIN_LAST_USER_KEY) {
                userNameTextField.text = lastUser
            }
        }
        catch {
            
        }
        
        do {
            if let lastRun = try LocalSettings.loadSettingsValue(db: Database.DB(), Key: LocalSettings.LOGIN_CURRENT_RUN_KEY) {
                runTextField.text = lastRun
            }
        }
        catch {
            
        }
        
        do {
            runs = try Run.loadActiveRuns(db: Database.DB())
        }
        catch {
            
        }
        
        registerForKeyboardNotifications()
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
        runPickerView.dataSource = self
        runPickerView.delegate = self
        
        runTextField.inputView = runPickerView
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
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
        
        // Get the user name's hashed password from the database
        do {
            guard let hashedPassword = try OLUser.loadUserPassword(db: Database.DB(), UserName: userNameTextField.text!) else {
                // TODO: error message here
                return
            }
            let hashMatches = PasswordHasher.VerifyHashedPassword(base64HashedPassword: hashedPassword, password: passwordTextField.text!)
            if (hashMatches) {
                // Save the user name & run
                do {
                    try LocalSettings.updateSettingsValue(db: Database.DB(), Key: LocalSettings.LOGIN_LAST_USER_KEY, Value: userNameTextField.text!)
                    //TODO: Handle data sync case
                    try LocalSettings.updateSettingsValue(db: Database.DB(), Key: LocalSettings.LOGIN_CURRENT_RUN_KEY, Value: runTextField.text!)
                }
                catch {
                }
                performSegue(withIdentifier: "ShowOperationalFormList", sender: self)
                return
            }
            // TODO: error message here
        }
        catch {
            // TODO: error message here
            return
        }
        
        // Password was not verified, display alert
        let alert = UIAlertController(title: "User name and password do not match", message: "Try logging in again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func EndRun(_ sender: UIButton) {
        
        // Load AssetSoftwareInfo
        do {
            // Load current Asset from local database
            let db = try Database.DB()
            guard let asset = try Asset.loadAsset(db: db) else {
                // TODO: Error message
                return
            }
            // Create a task for loading asset software info
            let loadAssetSoftwareInfoTask = OPLYNXServerTask(module: "asset", method: "loadassetsoftwareinfo", httpMethod: "GET")
            loadAssetSoftwareInfoTask.addParameter(name: "asset_id", value: String(asset.Asset_ID))
            loadAssetSoftwareInfoTask.addParameter(name: "software_id", value: String(AssetSoftwareInfo.SOFTWARE_ID))
            loadAssetSoftwareInfoTask.taskDelegate = ConfigSync.LoadAssetSoftwareInfoHandler(viewController: self)
            
            // Create a task for loading Server DateTime
            let loadDateTimeUTCTask = OPLYNXServerTask(module: "common", method: "serverdatetimenowutc", httpMethod: "GET")
            loadDateTimeUTCTask.taskDelegate = ConfigSync.GetDateTimeUTCHandler(viewController: self)
                        
            // Create a task for loading users
            let loadUserTask = ConfigSync.ConfigSyncServerTask(module: "user", method: "getusersbylastupdate", httpMethod: "GET")
            loadUserTask.taskDelegate = ConfigSync.LoadUsersHandler(viewController: self)
            
            // Create a task for loading runs
            let loadRunTask = ConfigSync.ConfigSyncServerTask(module: "fd", method: "getrunsbylastupdate", httpMethod: "GET")
            loadRunTask.taskDelegate = ConfigSync.LoadRunsHandler(viewController: self)
            
            // Create a task for saving AssetSoftwareInfo
            let saveAssetSoftwareInfoTask = SaveAssetSoftwareInfoTask(viewController: self)
            
            // Chain the Config Sync tasks together
            loadAssetSoftwareInfoTask.nextOsonoTask = loadDateTimeUTCTask
            loadDateTimeUTCTask.nextOsonoTask = loadUserTask
            loadUserTask.nextOsonoTask = loadRunTask
            loadRunTask.nextOsonoTask = saveAssetSoftwareInfoTask
            
            // Run the Osono Task Chain
            loadAssetSoftwareInfoTask.Run()
        }
        catch {
            // TODO: Error message
        }
        
        /*
        // Create a task for registering the asset
        let registerAssetTask = OPLYNXServerTask(module: "auth", method: "registerasset")
        registerAssetTask.addParameter(name: "asset_name", value: "CIS9")
        registerAssetTask.addParameter(name: "client_id", value: Authorize.CLIENT_ID)
        registerAssetTask.taskDelegate = Authorize.RegisterAssetHandler(viewController: self)
        
        // Create a task for loading the asset data
        let loadAssetTask = OPLYNXServerTask(module: "asset", method: "loadassetbyname")
        loadAssetTask.addParameter(name: "asset_name", value: "CIS9")
        loadAssetTask.taskDelegate = Authorize.LoadAssetHandler(viewController: self)
        
        // Chain the tasks & run
        registerAssetTask.nextOsonoTask = loadAssetTask
        registerAssetTask.Run()
        */
    }
    
    //MARK: UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == userNameTextField {
            passwordTextField.text = ""
        }
        return true
    }
    
    //MARK: UIPickerViewDataSource interface
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return runs.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return runs[row].Name        
    }
    
    //MARK: UIPickerViewDelegate interface
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        runTextField.text = runs[row].Name
        runTextField.resignFirstResponder()
    }
    
    //MARK: Keyboard/ScrollView managing
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        //let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        //self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }

    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}
