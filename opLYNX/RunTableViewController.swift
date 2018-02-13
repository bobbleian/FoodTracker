//
//  RunTableViewController.swift
//  opLYNX
//
//  Created by Ian Campbell on 2018-02-06.
//  Copyright © 2018 CIS. All rights reserved.
//

import UIKit

class RunTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    public var selectedRun: Run?
    private var allRuns = [Run]()
    private var filteredRuns = [Run]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Try to set the last run that was logged into by the previous user
        loadRunList()
        
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
        searchController.searchBar.delegate = self
        searchController.searchBar.setValue("Done", forKey: "_cancelButtonText")
        
        //TODO
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let runName = selectedRun?.Name, let i = allRuns.index(where: { $0.Name == runName }) {
            tableView.selectRow(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: .top)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return isFiltering() ? filteredRuns.count : allRuns.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowTableViewCell", for: indexPath)
        
        // Fetch the Run for the data source layout
        let currentRun: Run
        if isFiltering() {
            currentRun = filteredRuns[indexPath.row]
        }
        else {
            currentRun = allRuns[indexPath.row]
        }
        
        cell.textLabel?.text = currentRun.Name
        if currentRun.Name == selectedRun?.Name
        {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        selectedRun = isFiltering() ? filteredRuns[indexPath.row] : allRuns[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
    }
    
    //MARK: UISearchResultsUpdating interface
    func updateSearchResults(for searchController: UISearchController) {
        filterRunsForSearch(searchText: searchController.searchBar.text!)
        let currentRuns = isFiltering() ? filteredRuns : allRuns
        if let runName = selectedRun?.Name, let i = currentRuns.index(where: { $0.Name == runName }) {
            tableView.selectRow(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: .top)
        }
        
    }
    
    //MARK: Utility functions
    func loadRunList() {
        
        // Try to set the last run that was logged into by the previous user
        do {
            allRuns = try Run.loadActiveRuns(db: Database.DB())
        }
        catch {
        }
    }
    
    private func filterRunsForSearch(searchText: String) {
        // Filter the array using the filter method
        if allRuns.count == 0 {
            filteredRuns.removeAll()
        }
        else {
            filteredRuns = allRuns.filter({( run: Run) -> Bool in
                // Filter on Run name
                return searchBarIsEmpty() ||
                    run.Name.lowercased().contains(searchText.lowercased())
            })
        }
        tableView.reloadData()
    }

    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
}
