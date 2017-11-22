//
//  OFTableViewController.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-08-21.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import os.log
import SQLite
import Foundation
import CoreLocation

class OFTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, CLLocationManagerDelegate {
    
    //MARK: Static Properties
    static let OF_STATUS_COMPLETE_COLOR = UIColor.green
    static let OF_STATUS_CREATED_COLOR = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    static let OF_STATUS_INPROGRESS_COLOR = UIColor.orange
    
    // Classic Poopy colours
//    static let OF_STATUS_CREATED_COLOR = UIColor(red: 0.82, green: 0.65, blue: 0.47, alpha: 1.0)
//    static let OF_STATUS_CREATED_COLOR = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
//    static let OF_STATUS_INPROGRESS_COLOR = UIColor(red: 0.49, green: 0.67, blue: 0.96, alpha: 1.0)
    
    // Proximity threshold for nearby mode
    static let NEARBY_DISTANCE_THRESHOLD = 250.0
    
    //MARK: Outlets
    @IBOutlet weak var nearbyButton: UIBarButtonItem!
    
    //MARK: Properties
    private static let mercury = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
    
    // Operatrional Form data
    var operationalForms: [OperationalForm] {
        get {
            return filterMode == .All ? allOperationalForms : nearbyOperationalForms
        }
    }
    private var allOperationalForms = [OperationalForm]()
    private var nearbyOperationalForms = [OperationalForm]()
    private var filteredOperationalForms = [OperationalForm]()
    enum FilterMode: String {
        case All, Nearby
    }
    private var filterMode = FilterMode.All
    
    // Location
    private let locationManager = CLLocationManager()
    
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Operational Form data from local database
        loadAllOperationalForms()
        
        // Seatup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        //searchController.searchBar.scopeButtonTitles = [FilterMode.All.rawValue, FilterMode.Nearby.rawValue]
        searchController.searchBar.delegate = self
        searchController.searchBar.setValue("Done", forKey: "_cancelButtonText")
        
        // Location
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 10
        }
        
        // For now, Nearby Mode is disabled unless user turns it on
        nearbyButton.tintColor = UIColor.red
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Update OperationalForm list from database
    public func loadAllOperationalForms() {
        do {
            try allOperationalForms = OperationalForm.loadOperationalFormsWithKeysFromDB()
        }
        catch {
            os_log("Unable to load Operational Forms from database", log: OSLog.default, type: .error)
            allOperationalForms.removeAll()
        }
    }

    //MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return filteredOperationalForms.count
        }
        return operationalForms.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "OFTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OFTableViewCell else {
            fatalError("The dequeued cell is not an instance of OFTableViewCell.")
        }

        // Fetch the Operational Form for the data source layout
        let operationalForm: OperationalForm
        if isFiltering() {
            operationalForm = filteredOperationalForms[indexPath.section]
        }
        else {
            operationalForm = operationalForms[indexPath.section]
        }
        
        // Set Key labels
        cell.key1Label.text = operationalForm.key1
        cell.key2Label.text = operationalForm.key2
        cell.key3Label.text = operationalForm.key3
        
        cell.typeLabel.text = OFType.GetDisplayNameFromID(OLType_ID: operationalForm.OFType_ID)
        
        cell.dirtyLabel.isHidden = !operationalForm.Dirty
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        cell.dueDateLabel.text = dateFormatter.string(from: operationalForm.Due_Date)
        
        switch operationalForm.OFStatus_ID {
        // Created
        case OperationalForm.OF_STATUS_CREATED:
            cell.labelContainerView.backgroundColor  = OFTableViewController.OF_STATUS_CREATED_COLOR
        // Complete
        case OperationalForm.OF_STATUS_COMPLETE:
            cell.labelContainerView.backgroundColor = OFTableViewController.OF_STATUS_COMPLETE_COLOR
        // InProgress
        case OperationalForm.OF_STATUS_INPROGRESS:
            cell.labelContainerView.backgroundColor  = OFTableViewController.OF_STATUS_INPROGRESS_COLOR
        // Default
        default:
            cell.labelContainerView.backgroundColor  = UIColor.lightGray
        }

        return cell
    }
    
    //MARK: CLLocationManagerDelegate Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue:CLLocationCoordinate2D = manager.location?.coordinate {
            print("locations=\(locValue.latitude) \(locValue.longitude)")
            
            // Update the nearby operational form list
            nearbyOperationalForms = allOperationalForms.filter({( operationalForm: OperationalForm) -> Bool in
                // Get the GPS location from the form
                if let gpsLocation = try? OFElementData.loadOFElementValue(db: Database.DB(), OFNumber: operationalForm.OFNumber, OFElement_ID: OFElementData.OF_ELEMENT_ID_GPS_LOCATION) {
                    let gpsComponents = gpsLocation.components(separatedBy: ";")
                    if gpsComponents.count >= 2 {
                        if let gpsLatitude = Double(gpsComponents[0]), let gpsLongitude = Double(gpsComponents[1]) {
                            let formLocation = CLLocation(latitude: gpsLatitude, longitude: gpsLongitude)
                            return formLocation.distance(from: manager.location!) <= OFTableViewController.NEARBY_DISTANCE_THRESHOLD
                        }
                    }
                }
                return false
            })
            
            // Update the UI
            tableView.reloadData()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "ShowDetail":
            guard let ofViewController = segue.destination as? OFViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            guard let selectedOFTableViewCell = sender as? OFTableViewCell else {
                fatalError("Unexpected sender \(sender ?? "")")
            }
            guard let indexPath = tableView.indexPath(for: selectedOFTableViewCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedOperationalForm = operationalForms[indexPath.section]
            ofViewController.operationalForm = selectedOperationalForm
        default:
            os_log("Unknown segue identifier", log: OSLog.default, type: .error)
        }
    }
    
    //MARK: Actions
    @IBAction func toggleFilterByGPS(_ sender: UIBarButtonItem) {
        if CLLocationManager.locationServicesEnabled() {
            if filterMode == FilterMode.All {
                filterMode = .Nearby
                nearbyButton.tintColor = UIColor.green
                locationManager.startUpdatingLocation()
            }
            else {
                filterMode = .All
                nearbyButton.tintColor = UIColor.red
                nearbyOperationalForms.removeAll()
                locationManager.stopUpdatingLocation()
            }
            tableView.reloadData()
        }
        else if filterMode == .Nearby {
            filterMode = .All
            nearbyButton.tintColor = UIColor.red
            nearbyOperationalForms.removeAll()
            tableView.reloadData()
        }
        else if filterMode == .All {
            let alert = UIAlertController(title: "GPS", message: "Turn on Location Services to enable GPS filtering", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func refreshOperationalForms(_ sender: UIBarButtonItem) {
        DataSync.RunDataSync(viewController: self)
    }
    
    @IBAction func unwindToOFTableView(sender: UIStoryboardSegue) {
        switch (sender.identifier ?? "") {
        case "Save":
            if let sourceViewController = sender.source as? OFViewController {
                
                if let operationalForm = sourceViewController.operationalForm
                {
                    let entryControls = sourceViewController.getEntryControlSubviews()
                    
                    if let selectedIndexPath = tableView.indexPathForSelectedRow {
                        do {
                            for entryControl in entryControls {
                                if let ofElementData = OFElementData(OFNumber: operationalForm.OFNumber, OFElement_ID: entryControl.elementID, Value: entryControl.value) {
                                    try ofElementData.insertOrUpdatepdateOFElementValue(db: Database.DB())
                                }
                            }
                            try OperationalForm.updateOFDirty(db: Database.DB(), OFNumber: operationalForm.OFNumber, Dirty: true)
                            operationalForm.Dirty = true
                            
                            tableView.reloadRows(at: [selectedIndexPath], with: .none)
                        }
                        catch {
                            // TODO: Handle database error
                            os_log("Unable to save Operational Form Data to database OFNumber=%@", log: OSLog.default, type: .error, operationalForm.OFNumber)
                        }
                    }
                }
            }
        case "Cancel":
            os_log("Cancel segue - nothing to do", log: OSLog.default, type: .info)
        default:
            os_log("Unknown segue identifier", log: OSLog.default, type: .error)
        }
    }
    
    //MARK: UISearchResultsUpdating interface
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchText: searchController.searchBar.text!)
    }
    
    //MARK: UISearchBarDelegate interface
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    {
        filterMode = FilterMode(rawValue: searchBar.scopeButtonTitles![selectedScope])!
        filterContentForSearch(searchText: searchController.searchBar.text!)
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearch(searchText: String) {
        // Filter the array using the filter method
        if operationalForms.count == 0 {
            filteredOperationalForms.removeAll()
        }
        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            filteredOperationalForms = operationalForms.filter({( operationalForm: OperationalForm) -> Bool in
                return OFType.GetDisplayNameFromID(OLType_ID: operationalForm.OFType_ID).lowercased().contains(searchText.lowercased()) ||
                    operationalForm.key1.lowercased().contains(searchText.lowercased()) ||
                    operationalForm.key2.lowercased().contains(searchText.lowercased()) ||
                    operationalForm.key3.lowercased().contains(searchText.lowercased()) ||
                    dateFormatter.string(from: operationalForm.Due_Date).lowercased().contains(searchText.lowercased()) ||
                    ("completed".starts(with: searchText.lowercased()) && operationalForm.OFStatus_ID == 2) ||
                    ("inprogress".starts(with: searchText.lowercased()) && operationalForm.OFStatus_ID == 6) ||
                    ("created".starts(with: searchText.lowercased()) && operationalForm.OFStatus_ID == 1)
            })
        }
        tableView.reloadData()
    }
}
