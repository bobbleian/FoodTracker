//
//  MediaTableViewController.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-12.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import os.log
import SQLite

class MediaTableViewController: UITableViewController {

    //MARK: Properties
    private var media = [Media]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Load the media items to display
        do {
            try loadMediaFromDB()
        }
        catch {
            os_log("Unable to load media from database", log: OSLog.default, type: .error)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return media.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MediaTableViewCell", for: indexPath) as? MediaTableViewCell else {
            fatalError("Dequeued cell is not MediaTableViewCell")
        }
        
        let mediaItem = media[indexPath.row]
        
        cell.mediaCommentsTextView.text = mediaItem.Description
        cell.mediaImageView.image = mediaItem.ImageContent

        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
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
        case "ShowEditImage":
            os_log("Editing an existing image", log: OSLog.default, type: .debug)
            guard let mediaDetailViewController = segue.destination as? MediaViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            guard let selectedMediaTableViewCell = sender as? MediaTableViewCell else {
                fatalError("Unexpected sender \(sender ?? "")")
            }
            guard let indexPath = tableView.indexPath(for: selectedMediaTableViewCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let mediaIndex = indexPath.row
            let selectedMedia = media[mediaIndex]
            mediaDetailViewController.media = selectedMedia
 
        default:
            os_log("unknown segue identifier", log: OSLog.default, type: .error)
        }
    }
    
    //MARK: Actions
    @IBAction func unwindToMediaList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MediaViewController {
            
            let sourceMedia = sourceViewController.media!
            sourceMedia.Description = sourceViewController.mediaCommentsTextView.text
            sourceMedia.ImageContent = sourceViewController.mediaImageView.image
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                do {
                    try Media.updateMediaToDB(db: Database.DB(), media: sourceMedia)
                    self.media[selectedIndexPath.row] = sourceMedia
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                }
                catch {
                    fatalError("Unable to update media to the database")
                }
            }
            /*
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
             */
        }
    }
    
    @IBAction func cancelToMediaList(sender: UIStoryboardSegue) {
    }
    
    //MARK: Load data
    private func loadMediaFromDB() throws {
        self.media = try Media.loadMediaFromDB(db: Database.DB())
    }

}
