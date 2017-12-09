//
//  EntryControl.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-08-28.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit

@IBDesignable class EntryControl: UIStackView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //MARK: Static Properties
    private static let nilValue = "~"

    public static let EC_NONMANDATORY_COLOR = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    public static let EC_READONLY_COLOR = UIColor(red: 175/255, green: 175/255, blue: 175/255, alpha: 1.0)
    public static let EC_MANDATORY_EMPTY_COLOR = UIColor.orange
    public static let EC_MANDATORY_COMPLETE_COLOR = UIColor.green
    
    //MARK: Properties
    private let backGroundView = BackgroundControl()
    private let entryTitle = UILabel()
    private let entryValue = UILabel()
    
    private let mediaFlagImageView = UIImageView()
    private let mediaFlagImage = UIImage(named: "mediaindicator")
    
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
    @IBInspectable var value: String = nilValue {
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
            backGroundView.readOnly = readonly
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
    @IBInspectable var hasMedia: Bool = false {
        didSet {
            refreshControl()
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
        backGroundView.readOnly = readonly
        backGroundView.translatesAutoresizingMaskIntoConstraints = false
        backGroundView.layer.cornerRadius = 5
        backGroundView.layer.masksToBounds = true
        backGroundView.layer.borderWidth = 1.0
        addSubview(backGroundView)
        backGroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backGroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backGroundView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        backGroundView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        // Set up the media indicator
        mediaFlagImageView.image = UIImage()
        mediaFlagImageView.translatesAutoresizingMaskIntoConstraints = false
        mediaFlagImageView.widthAnchor.constraint(equalToConstant: 16.0).isActive = true
        mediaFlagImageView.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        
        let blankView = UIView()
        blankView.widthAnchor.constraint(equalToConstant: 16.0).isActive = true
        blankView.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        
        entryTitle.textAlignment = .center
        entryTitle.translatesAutoresizingMaskIntoConstraints = false
        entryTitle.adjustsFontSizeToFitWidth = true
        entryTitle.font = UIFont.boldSystemFont(ofSize: 16.0)

        let titleStackView = UIStackView()
        titleStackView.axis = .horizontal
        titleStackView.isUserInteractionEnabled = false
        titleStackView.addArrangedSubview(mediaFlagImageView)
        titleStackView.addArrangedSubview(entryTitle)
        titleStackView.addArrangedSubview(blankView)
        addArrangedSubview(titleStackView)
        
        entryValue.textAlignment = .center
        entryValue.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(entryValue)
        
        // Setup the Tap action
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(EntryControl.ecTapped(recognizer:)))
        let longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(EntryControl.ecLongTapped(recognizer:)))
        longTapRecognizer.minimumPressDuration = 0.75
        backGroundView.addGestureRecognizer(tapRecognizer)
        backGroundView.addGestureRecognizer(longTapRecognizer)
        
        refreshControl()
        
    }
    
    private func refreshControl() {
        entryTitle.text = title
        entryValue.text = value.isEmpty ? EntryControl.nilValue : value
        entryValue.alpha = value.isEmpty ? 0.5 : 1.0
        if mandatory {
            if value.isEmpty {
                backGroundView.setBackGroundColor(EntryControl.EC_MANDATORY_EMPTY_COLOR)
            }
            else {
                backGroundView.setBackGroundColor(EntryControl.EC_MANDATORY_COMPLETE_COLOR)
            }
        }
        else if readonly {
            backGroundView.setBackGroundColor(EntryControl.EC_READONLY_COLOR)
        }
        else {
            backGroundView.setBackGroundColor(EntryControl.EC_NONMANDATORY_COLOR)
        }
        
        if hasMedia {
            mediaFlagImageView.image = mediaFlagImage
        }
        else {
            mediaFlagImageView.image = UIImage()
        }
    }
    
    @objc func ecTapped(recognizer: UIGestureRecognizer) {
        if !readonly {
            viewController?.performSegue(withIdentifier: "EditECData", sender: self)
        }
    }
    
    @objc func ecLongTapped(recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
            if !readonly {
                viewController?.performSegue(withIdentifier: "EditECMedia", sender: self)
            }
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

class BackgroundControl: UIControl {
    var originalBackgroundColor: UIColor!
    var readOnly: Bool = false
    
    func setBackGroundColor(_ color: UIColor) {
        originalBackgroundColor = color
        backgroundColor = color
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard let originalBackgroundColor = originalBackgroundColor, !readOnly else {
                return
            }
            backgroundColor = isHighlighted ? darkenColor(color: originalBackgroundColor) : originalBackgroundColor
        }
    }
    
    // Darken a color
    func darkenColor(color: UIColor) -> UIColor {
        
        var red = CGFloat(), green = CGFloat(), blue = CGFloat(), alpha = CGFloat()
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        red = max(red - 0.5, 0.0)
        green = max(green - 0.5, 0.0)
        blue = max(blue - 0.5, 0.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
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

