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

class MealTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    //MARK: Properties
    let mercury = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
    var meals = [OperationalForm]()
    var mealSearchResults = [OperationalForm]()
    enum FilterMode: String {
        case All, Nearby
    }
    
    var filterMode = FilterMode.All
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use table view controller edit button
        //navigationItem.leftBarButtonItem = editButtonItem
        
        // Load meal data from SQLLite
        
        do {
            try loadMealsFromDB()
            //loadSampleMeals()
        }
        catch {
            os_log("Unable to load meals from database", log: OSLog.default, type: .error)
            // Load sample data
            loadSampleMeals()
        }
        
        // Seatup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        //searchController.searchBar.scopeButtonTitles = [FilterMode.All.rawValue, FilterMode.Nearby.rawValue]
        searchController.searchBar.delegate = self
        searchController.searchBar.setValue("Done", forKey: "_cancelButtonText")
        
        
        // Messing around with JSON
        /*
        let urlString = "http://100.100.102.113:13616/opLYNXJSON/operationalform/UEFAXSAAB"
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                os_log(error as! StaticString, log: OSLog.default, type: .error)
            }
            else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    for (key, value) in parsedData {
                        print("\(key): \(value)")
                    }
                }
                catch {
                    print(error)
                }
            }
        }.resume()
        */
        /*
        let json: [String: Any] = ["Number1": "2", "Number2": "3"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let headers = ["content-type": "application/json"]
        
        let urlString = "http://100.100.102.113:13616/opLYNXJSON/add"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                os_log(error as! StaticString, log: OSLog.default, type: .error)
            }
            else {
                do {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse)
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    for (key, value) in parsedData {
                        print("\(key): \(value)")
                    }
                }
                catch {
                    print(error)
                }
            }
            }.resume()
        */
        
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return mealSearchResults.count
        }
        return meals.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OperationalFormCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }

        // Fetch the meal for the data source layout
        let meal: OperationalForm
        if isFiltering() {
            meal = mealSearchResults[indexPath.section]
        }
        else {
            meal = meals[indexPath.section]
        }
        
        // Set Key labels
        cell.key1Label.text = meal.key1
        cell.key2Label.text = meal.key2
        cell.key3Label.text = meal.key3
        
        cell.typeLabel.text = OFType.GetDisplayNameFromID(OLType_ID: meal.OFType_ID)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        cell.dueDateLabel.text = dateFormatter.string(from: meal.Due_Date)
                
        /*
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating
        */
        
        /*
        cell.backgroundColor = nonmandatoryColor
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1
        cell.clipsToBounds = true
         */
        
        return cell
    }
    

    /*
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    */
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let meal = meals[indexPath.row]
            do {
                // Delete meal from database
                try removeMealFromDB(mealToDelete: meal)
                
                // Delete the row from the data source
                meals.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch {
                fatalError("Unable to delete meal from the database \(meal)")
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            guard let selectedMealCell = sender as? OperationalFormCell else {
                fatalError("Unexpected sender \(sender ?? "")")
            }
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let mealIndex = indexPath.section
            let selectedMeal = meals[indexPath.section]
            mealDetailViewController.meal = selectedMeal
        default:
            fatalError("Unexpected segue identifier; \(segue.identifier ?? "")")
        }
    }
    
    //MARK: Actions
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController {
            
            let meal = sourceViewController.meal
            let entryControls = sourceViewController.getEntryControlSubviews()
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                do {
                    // Update an existing meal
                    //try updateMealToDB(modifiedMeal: meal!)
                    //meals[selectedIndexPath.section] = meal!
                    
                    let dbFile = try MealTableViewController.makeWritableCopy(named: "oplynx.db", ofResourceFile: "oplynx.db")
                    let db = try Connection(dbFile.path)
                    for entryControl in entryControls {
                        try OFElementData.updateOFElementValue(db: db, OFNumber: (meal?.OFNumber)!, OFElement_ID: entryControl.elementID, Value: entryControl.value)
                    }
                    
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                }
                catch {
                    fatalError("Unable to update meal to the database")
                }
            }
            else {
                do {
                    // Add a new meal
                    try addMealToDB(newMeal: meal!)
                    let newIndexPath = IndexPath(row: 0, section: meals.count)
                    meals.append(meal!)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
                catch {
                    fatalError("Unable to save meal to the database")
                }
            }
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
    
    
    //MARK: Private Methods
    private func loadSampleMeals() {
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        guard let meal1 = OperationalForm(OFNumber: "OFABCDEF", photo: photo1, OFType_ID: 4, type: "D13", Due_Date: Date(), key1: "11-10-062-09W4", key2: "Location Name", key3: "UWI") else {
            fatalError("Unable to instantiate meal1")
        }
        guard let meal2 = OperationalForm(OFNumber: "OFABCDEG", photo: photo2, OFType_ID: 5, type: "D13", Due_Date: Date(), key1: "11-10-062-09W4", key2: "Location Name", key3: "UWI") else {
            fatalError("Unable to instantiate meal1")
        }
        guard let meal3 = OperationalForm(OFNumber: "OFABCDEH", photo: photo3, OFType_ID: 2, type: "D13", Due_Date: Date(), key1: "11-10-062-09W4", key2: "Location Name", key3: "UWI") else {
            fatalError("Unable to instantiate meal1")
        }
        
        meals += [meal1, meal2, meal3]
        
    }
    
    private func loadMealsFromDB() throws {
        let dbFile = try MealTableViewController.makeWritableCopy(named: "oplynx.db", ofResourceFile: "oplynx.db")
        let db = try Connection(dbFile.path)
        self.meals = try OperationalForm.loadOperationalFormsFromDB(db: db)
        
        // Load key values from OFElementData table
        for meal in meals {
            let key1Value = try OFElementData.loadOFElementValue(db: db, OFNumber: meal.OFNumber, OFElement_ID: 148)
            meal.key1 = key1Value
            let key2Value = try OFElementData.loadOFElementValue(db: db, OFNumber: meal.OFNumber, OFElement_ID: 149)
            meal.key2 = key2Value
            let key3Value = try OFElementData.loadOFElementValue(db: db, OFNumber: meal.OFNumber, OFElement_ID: 150)
            meal.key3 = key3Value
        }
    }
    
    private func addMealToDB(newMeal: OperationalForm) throws {
        //let documentURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        //let dbFile = documentURL.appendingPathComponent("oplynx.sqlite3")
        let dbFile = try MealTableViewController.makeWritableCopy(named: "oplynx.db", ofResourceFile: "oplynx.db")
        let db = try Connection(dbFile.path)
        
        let meals = Table("meals")
        let name = Expression<String>("name")
        let photo = Expression<SQLite.Blob?>("photo")
        let rating = Expression<Int64>("rating")
        
        try db.run(meals.insert(name <- newMeal.OFNumber, photo <- newMeal.photo != nil ? UIImagePNGRepresentation(newMeal.photo!)!.datatypeValue : nil, rating <- Int64(newMeal.OFType_ID)))
        
        let imageData = UIImagePNGRepresentation(newMeal.photo!)!
        let imageBase64 = imageData.base64EncodedString()
        
        let json: [String: Any] = ["Contents": imageBase64, "MediaNumber": "QK2AHSAAC"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let headers = ["content-type": "application/json", "Authorization": "Bearer [token]"]
        
        let urlString = "http://100.100.102.113:13616/opLYNXJSON/image"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.allHTTPHeaderFields = headers
        
        /*
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                os_log(error as! StaticString, log: OSLog.default, type: .error)
            }
            else {
                do {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse!)
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    for (key, value) in parsedData {
                        print("\(key): \(value)")
                    }
                }
                catch {
                    print(error)
                }
            }
            }.resume()
        */
        
        
    }
    
    private func updateMealToDB(modifiedMeal: OperationalForm) throws {
        //let documentURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        //let dbFile = documentURL.appendingPathComponent("oplynx.sqlite3")
        let dbFile = try MealTableViewController.makeWritableCopy(named: "oplynx.db", ofResourceFile: "oplynx.db")
        let db = try Connection(dbFile.path)
        
        let meals = Table("meals")
        let name = Expression<String>("name")
        let photo = Expression<SQLite.Blob?>("photo")
        let rating = Expression<Int64>("rating")
        
        let filterMeal = meals.filter(name == modifiedMeal.OFNumber)
        
        try db.run(filterMeal.update(photo <- modifiedMeal.photo != nil ? UIImagePNGRepresentation(modifiedMeal.photo!)!.datatypeValue : nil,
                                     rating <- Int64(modifiedMeal.OFType_ID)))
        
    }
    private func removeMealFromDB(mealToDelete: OperationalForm) throws {
        let dbFile = try MealTableViewController.makeWritableCopy(named: "oplynx.db", ofResourceFile: "oplynx.db")
        let db = try Connection(dbFile.path)
        
        let meals = Table("meals")
        let name = Expression<String>("name")
        let photo = Expression<SQLite.Blob?>("photo")
        let rating = Expression<Int64>("rating")
        
        let filterMeal = meals.filter(name == mealToDelete.OFNumber)
        
        try db.run(filterMeal.delete())
        
    }
    
    public class func makeWritableCopy(named destFileName: String, ofResourceFile originalFileName: String) throws -> URL {
        // Get Documents directory in app bundle
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError("No document directory found in application bundle.")
        }
        
        // Get URL for dest file (in Documents directory)
        let writableFileURL = documentsDirectory.appendingPathComponent(destFileName)
        
        // If dest file doesn’t exist yet
        if (try? writableFileURL.checkResourceIsReachable()) == nil {
            // Get original (unwritable) file’s URL
            guard let originalFileURL = Bundle.main.url(forResource: originalFileName, withExtension: nil) else {
                fatalError("Cannot find original file “\(originalFileName)” in application bundle’s resources.")
            }
            
            // Get original file’s contents
            let originalContents = try Data(contentsOf: originalFileURL)
            
            // Write original file’s contents to dest file
            try originalContents.write(to: writableFileURL, options: .atomic)
            print("Made a writable copy of file “\(originalFileName)” in “\(documentsDirectory)\\\(destFileName)”.")
            
        }
        
        // Return dest file URL
        return writableFileURL
    }
    
    //MARK: Search Bar
    private func filterContentForSearch(searchText: String) {
        // Filter the array using the filter method
        if meals.count == 0 {
            mealSearchResults.removeAll()
        }
        else {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            mealSearchResults = meals.filter({( operationalForm: OperationalForm) -> Bool in
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
