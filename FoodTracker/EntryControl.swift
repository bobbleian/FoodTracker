//
//  EntryControl.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-08-28.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit

@IBDesignable class EntryControl: UIStackView, UIPickerViewDataSource, UIPickerViewDelegate {

    //MARK: Properties
    let mercury = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
    let backGroundView = UIControl()
    let entryTitle = UILabel()
    let entryValue = UILabel()
    
    var pickerData:[String] = []
    @IBInspectable var pickerDataString: String = "" {
        didSet {
            pickerData = pickerDataString.components(separatedBy: ";")
        }
    }
    
    
    // Picker View Testing
    var pickerView: UIPickerView?
    
    @IBInspectable var title: String = " " {
        didSet {
            refreshControl()
        }
    }
    @IBInspectable var value: String = " " {
        didSet {
            refreshControl()
        }
    }
    @IBInspectable var mandatory: Bool = false {
        didSet {
            refreshControl()
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
        backGroundView.backgroundColor = .blue
        backGroundView.translatesAutoresizingMaskIntoConstraints = false
        backGroundView.layer.cornerRadius = 5
        backGroundView.layer.masksToBounds = true
        backGroundView.layer.borderWidth = 1.0
        addSubview(backGroundView)
        backGroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backGroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backGroundView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        backGroundView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        entryTitle.textAlignment = .center
        //entryTitle.adjustsFontSizeToFitWidth = true
        //entryTitle.layer.borderWidth = 1.0
        //entryTitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
        //entryTitle.widthAnchor.constraint(equalToConstant: 20).isActive = true
        addArrangedSubview(entryTitle)
        
        entryValue.textAlignment = .center
        //entryValue.backgroundColor = .white
        //entryValue.layer.borderWidth = 1.0
        //entryValue.heightAnchor.constraint(equalToConstant: 20).isActive = true
        //entryValue.widthAnchor.constraint(equalToConstant: 20).isActive = true
        addArrangedSubview(entryValue)
        
        // Setup the Tap action
        backGroundView.addTarget(self, action: #selector(EntryControl.ecTapped(entryControl:)), for: .touchUpInside)
        
        refreshControl()
        
    }
    
    private func refreshControl() {
        entryTitle.text = title
        entryValue.text = value
        if mandatory {
            if entryValue.text != nil && !(entryValue.text?.isEmpty)!  && entryValue.text != " " {
                backGroundView.backgroundColor = .green
            }
            else {
                backGroundView.backgroundColor = .orange
            }
        }
        else {
            backGroundView.backgroundColor = mercury
        }
    }
    
    func ecTapped(entryControl: EntryControl) {
        //Create the AlertController
        /*
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 60))
        
        pickerView?.dataSource = self
        pickerView?.delegate = self
        alertController.view.addSubview(pickerView!)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        let vc = ECDataEntryViewController()
        vc.modalPresentationStyle = .popover
        
        viewController?.present(vc, animated: true, completion: nil)
        vc.popoverPresentationController?.sourceView = viewController?.view
        vc.popoverPresentationController?.sourceRect = entryControl.frame
        */
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "alert") as? ECDataEntryViewController
        myAlert?.entryControl = self
        myAlert?.modalPresentationStyle = .overCurrentContext
        myAlert?.modalTransitionStyle = .coverVertical
        viewController?.present(myAlert!, animated: true, completion: nil)
    }
    
    
    func ecTapped2(entryControl: EntryControl) {
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
    
    //MARK: UIPickerViewDelegate, UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < pickerData.count else {
            return ""
        }
        return pickerData[row]
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

