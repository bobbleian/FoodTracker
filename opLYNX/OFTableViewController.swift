//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-08-21.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import os.log
import SQLite
import Foundation

class OFTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    //MARK: Properties
    let mercury = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
    var operationalForms = [OperationalForm]()
    var filteredOperationalForms = [OperationalForm]()
    enum FilterMode: String {
        case All, Nearby
    }
    
    var filterMode = FilterMode.All
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load meal data from SQLLite
        do {
            try operationalForms = OperationalForm.loadOperationalFormsWithKeysFromDB()
        }
        catch {
            os_log("Unable to load Operational Forms from database", log: OSLog.default, type: .error)
            operationalForms.removeAll()
        }
        
        // Seatup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        //searchController.searchBar.scopeButtonTitles = [FilterMode.All.rawValue, FilterMode.Nearby.rawValue]
        searchController.searchBar.delegate = self
        searchController.searchBar.setValue("Done", forKey: "_cancelButtonText")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        // Fetch the meal for the data source layout
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        cell.dueDateLabel.text = dateFormatter.string(from: operationalForm.Due_Date)

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? OFViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            guard let selectedMealCell = sender as? OFTableViewCell else {
                fatalError("Unexpected sender \(sender ?? "")")
            }
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedMeal = operationalForms[indexPath.section]
            mealDetailViewController.operationalForm = selectedMeal
        default:
            fatalError("Unexpected segue identifier; \(segue.identifier ?? "")")
        }
    }
    
    //MARK: Actions
    @IBAction func unwindToOFTableView(sender: UIStoryboardSegue) {
        switch (sender.identifier ?? "") {
        case "Save":
            if let sourceViewController = sender.source as? OFViewController {
                
                let meal = sourceViewController.operationalForm
                let entryControls = sourceViewController.getEntryControlSubviews()
                
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    do {
                        for entryControl in entryControls {
                            try OFElementData.updateOFElementValue(db: Database.DB(), OFNumber: (meal?.OFNumber)!, OFElement_ID: entryControl.elementID, Value: entryControl.value)
                        }
                        tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    }
                    catch {
                        fatalError("Unable to update operational form in database")
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
                    dateFormatter.string(from: operationalForm.Due_Date).lowercased().contains(searchText.lowercased())
            })
        }
        tableView.reloadData()
    }
}
