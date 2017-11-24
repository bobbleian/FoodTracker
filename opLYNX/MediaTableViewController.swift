//
//  MediaTableViewController.swift
//  opLYNX
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
    
    var ofElement: OFElementData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the media items to display
        do {
            if let ofElement = ofElement {
                media = try Media.loadMediaFromDB(db: Database.DB(), OFNumber: ofElement.OFNumber, OFElement_ID: ofElement.OFElement_ID)
            }
            else {
                media.removeAll()
            }
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
        cell.mediaImageView.image = mediaItem.Content

        // Configure the cell...

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let sourceMedia = media[indexPath.row]
            
            do {
                // delete media record from local database
                try Media.deleteMediaFromDB(db: Database.DB(), media: sourceMedia)
                
                // Delete the row from the data source
                media.remove(at: indexPath.row)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch {
                fatalError("Unable to save media to the database")
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 

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
    @IBAction func unwindToMediaTableView(sender: UIStoryboardSegue) {
        
        switch (sender.identifier ?? "") {
        case "Save":
            if let sourceViewController = sender.source as? MediaViewController, let image = sourceViewController.mediaImageView.image {
                
                // TODO: Save GPS location
                let sourceMedia = sourceViewController.media ?? Media(MediaNumber: UUID().uuidString, Media_Date: Date(), Asset_ID: Authorize.ASSET?.Asset_ID ?? 0, UniqueMediaNumber: UUID().uuidString, MediaType_ID: Media.MEDIA_TYPE_ID_PNG, Url: "", Description: sourceViewController.mediaCommentsTextView.text, Create_Date: Date(), CreateUser_ID: Authorize.CURRENT_USER?.OLUser_ID ?? 0, GPSLocation: "", LastUpdate: Date(), Dirty: true, Content: image)
                
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
                else {
                    do {
                        // Add a new media image
                        try Media.insertMediaToDB(db: Database.DB(), media: sourceMedia)
                        try OFLinkMedia.insertMediaToDB(db: Database.DB(),
                                                        MediaNumber: sourceMedia.MediaNumber,
                                                        OFNumber: (ofElement?.OFNumber)!,
                                                        OFElement_ID: (ofElement?.OFElement_ID)!,
                                                        SortOrder: media.count)
                        let newIndexPath = IndexPath(row: media.count, section: 0)
                        media.append(sourceMedia)
                        tableView.insertRows(at: [newIndexPath], with: .automatic)
                    }
                    catch {
                        fatalError("Unable to save media to the database")
                    }
                }
            }
        case "Cancel":
            os_log("Cancel segue - nothing to do", log: OSLog.default, type: .info)
        default:
            os_log("Unknown segue identifier", log: OSLog.default, type: .error)
        }
    }
    
}
