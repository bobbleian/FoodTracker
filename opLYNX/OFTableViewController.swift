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

class OFTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, CLLocationManagerDelegate, OPLYNXProgressView {
    
    //MARK: Static Properties
    static let OF_STATUS_COMPLETE_COLOR = UIColor.green
    static let OF_STATUS_CREATED_COLOR = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    static let OF_STATUS_INPROGRESS_COLOR = UIColor.orange
    
    // Proximity threshold for nearby mode
    static let NEARBY_DISTANCE_THRESHOLD = 250.0
    
    //MARK: Outlets
    @IBOutlet weak var nearbyButton: UIBarButtonItem!
    
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
    
    private let myHUD = JustHUD()
    
    enum SearchScope: String {
        case all = "All"
        case created = "Created"
        case inprogress = "In Progress"
        case completed = "Completed"
        case modified = "Modified"
    }
    private var searchScope = SearchScope.all
    
    // Location
    private let locationManager = CLLocationManager()
    
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Seatup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        searchController.searchBar.scopeButtonTitles = [SearchScope.all.rawValue, SearchScope.inprogress.rawValue, SearchScope.completed.rawValue, SearchScope.modified.rawValue]
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
        
        DispatchQueue.main.async {
            // Load Operational Form data from local database
            self.loadAllOperationalForms()
            
            // Update the UI
            self.tableView.reloadData()
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Update OperationalForm list from database
    public func loadAllOperationalForms() {
        do {
            try allOperationalForms = OperationalForm.loadOperationalFormsWithKeysFromDB(db: Database.DB())
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OFTableViewCell", for: indexPath) as? OFTableViewCell else {
            os_log("Dequeued cell is not OFTableViewCell", log: OSLog.default, type: .error)
            return tableView.dequeueReusableCell(withIdentifier: "OFTableViewCell", for: indexPath)
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
        cell.dueDateLabel.adjustsFontSizeToFitWidth = true
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
                guard let formLocation = operationalForm.formLocation else {
                    return false
                }
                return formLocation.distance(from: manager.location!) <= OFTableViewController.NEARBY_DISTANCE_THRESHOLD
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
                os_log("Unexpected destination", log: OSLog.default, type: .error)
                return
            }
            guard let selectedOFTableViewCell = sender as? OFTableViewCell else {
                os_log("Unexpected sender", log: OSLog.default, type: .error)
                return
            }
            guard let indexPath = tableView.indexPath(for: selectedOFTableViewCell) else {
                os_log("The selected cell is not being displayed by the table", log: OSLog.default, type: .error)
                return
            }
            let selectedOperationalForm = isFiltering() ? filteredOperationalForms[indexPath.section] : operationalForms[indexPath.section]
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
        if let currentRun = Authorize.CURRENT_RUN {
            DataSync.RunDataSync(selectedRun: currentRun, viewController: self, successTask: ShowDataSyncSuccessTask(self), errorTask: ShowDataSyncErrorTask(self))
        }
    }
    
    @IBAction func unwindToOFTableView(sender: UIStoryboardSegue) {
        switch (sender.identifier ?? "") {
        case "Save":
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
        case "Cancel":
            os_log("Cancel segue - nothing to do", log: OSLog.default, type: .info)
        default:
            os_log("OFTableViewController: Unknown segue identifier", log: OSLog.default, type: .error)
        }
    }
    
    //MARK: UISearchResultsUpdating interface
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchText: searchController.searchBar.text!)
    }
    
    //MARK: UISearchBarDelegate interface
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    {
        searchScope = SearchScope(rawValue: searchBar.scopeButtonTitles![selectedScope])!
        filterContentForSearch(searchText: searchController.searchBar.text!)
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && (!searchBarIsEmpty() || searchScope != .all)
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
                
                // Filter on status first
                if searchScope == .completed && operationalForm.OFStatus_ID != OperationalForm.OF_STATUS_COMPLETE {
                    return false
                }
                if searchScope == .inprogress && operationalForm.OFStatus_ID != OperationalForm.OF_STATUS_INPROGRESS {
                    return false
                }
                if searchScope == .created && operationalForm.OFStatus_ID != OperationalForm.OF_STATUS_CREATED {
                    return false
                }
                if searchScope == .modified && !operationalForm.Dirty {
                    return false
                }
                
                // If we got this far, status is OK, now filter on search text
                return searchBarIsEmpty() ||
                    OFType.GetDisplayNameFromID(OLType_ID: operationalForm.OFType_ID).lowercased().contains(searchText.lowercased()) ||
                    operationalForm.key1.lowercased().contains(searchText.lowercased()) ||
                    operationalForm.key2.lowercased().contains(searchText.lowercased()) ||
                    operationalForm.key3.lowercased().contains(searchText.lowercased()) ||
                    dateFormatter.string(from: operationalForm.Due_Date).lowercased().contains(searchText.lowercased())
            })
        }
        tableView.reloadData()
    }
    
    class ShowDataSyncSuccessTask: OPLYNXGenericTask {
        
        init(_ viewController: UIViewController) {
            super.init(viewController: viewController)
        }
        
        override func RunTask() {
            success()
            DispatchQueue.main.async {
                if let ofTableViewController = self.viewController as? OFTableViewController {
                    ofTableViewController.loadAllOperationalForms()
                    ofTableViewController.tableView.reloadData()
                }
                let alert = UIAlertController(title: "Data Sync Success", message: "All forms have been synced.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.viewController?.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    class ShowDataSyncErrorTask: OPLYNXErrorTask {
        
        init(_ viewController: UIViewController) {
            super.init(viewController: viewController)
        }
        
        override func RunTask() {
            DispatchQueue.main.async {
                if let ofTableViewController = self.viewController as? OFTableViewController {
                    ofTableViewController.loadAllOperationalForms()
                    ofTableViewController.tableView.reloadData()
                }
                let alert = UIAlertController(title: "Data Sync Error", message: "Try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.viewController?.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    //MARK: OPLYNXProgressView protocol
    func updateProgress(title: String?, description: String?) {
        self.myHUD.showInView(view: self.view, withHeader: title, andFooter: description)
    }
    
    func endProgress() {
        self.myHUD.hide()
    }
    
    
}
