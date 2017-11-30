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
    
    private var selectedRun: Run?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Try to set user text field based on the previous user name
        if let lastUser = try? LocalSettings.loadSettingsValue(db: Database.DB(), Key: LocalSettings.LOGIN_LAST_USER_KEY) {
            userNameTextField.text = lastUser
        }
        
        // TESTING ONLY TODO: Remove
        if userNameTextField.text == "admin" {
            passwordTextField.text = "admin"
        }
        
        // Try to set the last run that was logged into by the previous user
        loadRunList()
        
        // Setup to scroll the view if the keyboard pops up
        registerForKeyboardNotifications()
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Handle run picker view selection
        runPickerView.showsSelectionIndicator = true
        runPickerView.dataSource = self
        runPickerView.delegate = self
        if let i = runs.index(where: { $0.Name == runTextField.text }) {
            runPickerView.selectRow(i, inComponent: 0, animated: false)
        }
        
        runTextField.inputView = runPickerView
        
        // Run Config Sync
        DispatchQueue.main.async {
            ConfigSync.RunConfigSync(viewController: self)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Utility functions
    func loadRunList() {
        
        // Try to set the last run that was logged into by the previous user
        do {
            runs = try Run.loadActiveRuns(db: Database.DB())
            if let lastRun = try LocalSettings.loadSettingsValue(db: Database.DB(), Key: LocalSettings.LOGIN_CURRENT_RUN_KEY) {
                Authorize.CURRENT_RUN = runs.first(where: {$0.Name == lastRun})
                if Authorize.CURRENT_RUN != nil {
                    runTextField.text = lastRun
                    selectedRun = Authorize.CURRENT_RUN
                }
                else {
                    runTextField.text = ""
                    selectedRun = nil
                }
            }
        }
        catch {
        }
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
        
        // Clear the current user
        Authorize.CURRENT_USER = nil
        
        // Ensure there is a selected run
        guard let selectedRun = selectedRun else {
            let alert = UIAlertController(title: "No Run Selected", message: "Select a Run before logging in", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Get the user name's hashed password from the database
        guard let olUserTmp = try? OLUser.loadUser(db: Database.DB(), UserName: userNameTextField.text!), let olUser = olUserTmp, olUser.Active == true else {
            // Unable to find active user in local database
            showLoginError()
            return
        }
        
        // Verify the user name and password
        guard PasswordHasher.VerifyHashedPassword(base64HashedPassword: olUser.Password, password: passwordTextField.text!) else {
            // User name and password do not match
            showLoginError()
            return
        }
        
        // Save the user name
        try? LocalSettings.updateSettingsValue(db: Database.DB(), Key: LocalSettings.LOGIN_LAST_USER_KEY, Value: userNameTextField.text!)
        
        // Set the current user
        Authorize.CURRENT_USER = olUser
        
        // Run Data Sync.  If it completes successfully, navigate to Operational Form List view
        DataSync.RunDataSync(selectedRun: selectedRun, viewController: self, finalTask: ShowOperationalFormListTask(self))
        
    }
    
    private func showLoginError() {
        // Password was not verified, display alert
        let alert = UIAlertController(title: "User name and password do not match", message: "Try logging in again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func EndRun(_ sender: UIButton) {
        ConfigSync.RunConfigSync(viewController: self)
        
        
        // TEMP ONLY DELETE ALL MEDIA
        //try? Database.DB().execute("DELETE FROM Media")
        //try? Database.DB().execute("DELETE FROM OFLinkMedia")
        
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
        selectedRun = runs[row]
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
    
    class ShowOperationalFormListTask: OPLYNXGenericTask {
        private let viewController: UIViewController
        
        init(_ viewController: UIViewController) {
            self.viewController = viewController
            super.init()
        }
        override func RunTask() {
            DispatchQueue.main.async {
                // Navigate to the OF list screen
                self.viewController.performSegue(withIdentifier: "ShowOperationalFormList", sender: self.viewController)
            }
        }
    }
    

}
