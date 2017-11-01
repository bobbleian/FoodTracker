//
//  EntryControl.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-08-28.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit

@IBDesignable class EntryControl: UIStackView, UIPickerViewDataSource, UIPickerViewDelegate {

    //MARK: Properties
    private let nonmandatoryColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    private let readonlyColor = UIColor(red: 175/255, green: 175/255, blue: 175/255, alpha: 1.0)
    
    private let backGroundView = UIControl()
    private let entryTitle = UILabel()
    private let entryValue = UILabel()
    
    var globalList:[String] = []
    @IBInspectable var pickerDataString: String = "" {
        didSet {
            globalList = pickerDataString.components(separatedBy: ";")
        }
    }
    
    
    // Picker View Testing
    var pickerView: UIPickerView?
    
    @IBInspectable var title: String = "Title" {
        didSet {
            refreshControl()
        }
    }
    @IBInspectable var value: String = "empty" {
        didSet {
            refreshControl()
        }
    }
    @IBInspectable var mandatory: Bool = false {
        didSet {
            refreshControl()
        }
    }
    @IBInspectable var readonly: Bool = false {
        didSet {
            refreshControl()
        }
    }
    @IBInspectable var name: String = "Name" {
        didSet {
            
        }
    }
    @IBInspectable var elementID: Int = 0 {
        didSet {
            
        }
    }
    @IBInspectable var dataEntryTypeName: String = "Text" {
        didSet {
            
        }
    }
    
    var ofNumber: String = ""
    
    
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
        
        // Set the insets
        layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        isLayoutMarginsRelativeArrangement = true
        
        // Set the spacing between labels
        spacing = 5.0
        
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
        entryTitle.translatesAutoresizingMaskIntoConstraints = false
        entryTitle.adjustsFontSizeToFitWidth = true
        entryTitle.font = UIFont.boldSystemFont(ofSize: 16.0)
        //entryTitle.heightAnchor.constraint(equalToConstant: 40).isActive = true
        //entryTitle.layer.borderWidth = 1.0
        //entryTitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
        //entryTitle.widthAnchor.constraint(equalToConstant: 20).isActive = true
        addArrangedSubview(entryTitle)
        
        entryValue.textAlignment = .center
        entryValue.translatesAutoresizingMaskIntoConstraints = false
        //entryValue.heightAnchor.constraint(equalToConstant: 40).isActive = true
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
        entryValue.text = value.isEmpty ? "empty" : value
        entryValue.alpha = value.isEmpty ? 0.5 : 1.0
        if mandatory {
            if value.isEmpty {
                backGroundView.backgroundColor = .orange
            }
            else {
                backGroundView.backgroundColor = .green
            }
        }
        else if readonly {
            backGroundView.backgroundColor = readonlyColor
        }
        else {
            backGroundView.backgroundColor = nonmandatoryColor
        }
    }
    
    func ecTapped(entryControl: EntryControl) {
        if !readonly {
            viewController?.performSegue(withIdentifier: "editData", sender: self)
        }
    }
    
    //MARK: UIPickerViewDelegate, UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return globalList.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < globalList.count else {
            return ""
        }
        return globalList[row]
    }
    
}

extension EntryControl {
    var viewController : OFViewController? {
        var responder: UIResponder? = self
        while (responder != nil) {
            if let responder = responder as? OFViewController {
                return responder
            }
            responder = responder?.next
        }
        return nil
    }
}

