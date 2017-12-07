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

class MediaTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Properties
    private var media = [Media]()
    private var ofLinkMedia = [OFLinkMedia]()
    
    var entryControl: EntryControl?
    
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        DispatchQueue.main.async {
            // Load Operational Form data from local database
            self.loadMedia()
            
            // Update the UI
            self.tableView.reloadData()
            
            // Build Osono tasks for loading any missing media
            var firstLoadMediaTask: LoadMediaTask? = nil
            var currentLoadMediaTask: LoadMediaTask? = nil
            
            for ofLinkMediaItem in self.ofLinkMedia {
                if self.media.first(where: { $0.MediaNumber == ofLinkMediaItem.MediaNumber }) == nil {
                    let nextLoadMediaTask = LoadMediaTask(ofLinkMediaItem.MediaNumber, mediaTableViewController: self)
                    if firstLoadMediaTask == nil {
                        firstLoadMediaTask = nextLoadMediaTask
                        currentLoadMediaTask = nextLoadMediaTask
                    }
                    else {
                        currentLoadMediaTask?.insertOsonoTask(nextLoadMediaTask)
                        currentLoadMediaTask = nextLoadMediaTask
                    }
                }
            }
            firstLoadMediaTask?.RunTask()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMedia() {
        // Ensure Media data model is empty
        media.removeAll()
        ofLinkMedia.removeAll()
        
        // Load the media items to display
        if let entryControl = entryControl {
            do {
                ofLinkMedia = try OFLinkMedia.loadOFLinkMedia(db: Database.DB(), OFNumber: entryControl.ofNumber, OFElement_ID: entryControl.elementID)
                media = try Media.loadMediaFromDB(db: Database.DB(), OFNumber: entryControl.ofNumber, OFElement_ID: entryControl.elementID)
            }
            catch {
                os_log("Unable to load media from database", log: OSLog.default, type: .error)
            }
        }
    }
    
    func appendMedia(_ mediaItem: Media) {
        media.append(mediaItem)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ofLinkMedia.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MediaTableViewCell", for: indexPath) as? MediaTableViewCell else {
            os_log("Dequeued cell is not MediaTableViewCell", log: OSLog.default, type: .error)
            return tableView.dequeueReusableCell(withIdentifier: "MediaTableViewCell", for: indexPath)
        }
        
        cell.mediaCommentsTextView.layer.cornerRadius = 5
        cell.mediaCommentsTextView.layer.masksToBounds = true
        cell.mediaCommentsTextView.layer.borderWidth = 1.0
        
        cell.mediaImageView.layer.cornerRadius = 5
        cell.mediaImageView.layer.masksToBounds = true
        cell.mediaImageView.layer.borderWidth = 1.0
        
        let ofLinkMediaItem = ofLinkMedia[indexPath.row]
        let mediaItem = media.first(where: { $0.MediaNumber == ofLinkMediaItem.MediaNumber } )
        
        if let mediaItem = mediaItem {
            cell.loadingLabel.isHidden = true
            cell.loadingAvtivityIndicator.isHidden = true
            cell.loadingAvtivityIndicator.stopAnimating()
            cell.mediaCommentsTextView.isHidden = false
            cell.mediaImageView.isHidden = false
            cell.mediaCommentsTextView.text = mediaItem.Description
            cell.mediaImageView.image = mediaItem.Content
            cell.cellContentView.backgroundColor = EntryControl.EC_NONMANDATORY_COLOR
        }
        else {
            cell.loadingLabel.isHidden = false
            cell.loadingAvtivityIndicator.isHidden = false
            cell.loadingAvtivityIndicator.startAnimating()
            cell.mediaCommentsTextView.isHidden = true
            cell.mediaImageView.isHidden = true
            cell.mediaCommentsTextView.text = ""
            cell.mediaImageView.image = UIImage(named: "noimage")
            cell.cellContentView.backgroundColor = EntryControl.EC_NONMANDATORY_COLOR
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let ofLinkMediaItem = ofLinkMedia[indexPath.row]
        guard media.first(where: { $0.MediaNumber == ofLinkMediaItem.MediaNumber }) != nil else {
            return nil
        }
        return indexPath
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let ofLinkMediaItem = ofLinkMedia[indexPath.row]
            
            do {
                // TODO: delete media record from local database
                
                // Delete the OFLinkMedia records from the local database
                try ofLinkMediaItem.deleteFromDB(db: Database.DB())
                
                // Delete the row from the data source
                ofLinkMedia.remove(at: indexPath.row)
                
                // Update the sort order for all remaining OFLinkMedia items
                var currentSortOrder = indexPath.row
                for currentOFLinkMediaItem in ofLinkMedia[indexPath.row...] {
                    currentOFLinkMediaItem.SortOrder = currentSortOrder
                    currentSortOrder += 1
                    try currentOFLinkMediaItem.deleteFromDB(db: Database.DB())
                    try currentOFLinkMediaItem.insertMediaToDB(db: Database.DB())
                }
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                entryControl?.hasMedia = ofLinkMedia.count > 0
            }
            catch {
                os_log("Unable to save media to the database", log: OSLog.default, type: .error)
            }
            
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
            if let mediaDetailViewController = segue.destination as? MediaViewController, let selectedMediaTableViewCell = sender as? MediaTableViewCell, let indexPath = tableView.indexPath(for: selectedMediaTableViewCell) {
                // Set the media on the Media View Controller
                let ofLinkMediaItem = ofLinkMedia[indexPath.row]
                let selectedMedia = media.first(where: { $0.MediaNumber == ofLinkMediaItem.MediaNumber } )
                mediaDetailViewController.media = selectedMedia
            }
 
        case "ShowAddImage":
            os_log("Adding a new image", log: OSLog.default, type: .error)
            if let mediaDetailViewController = segue.destination as? MediaViewController, let selectedImage = selectedImage {
                // Set the Image on the Media View Controller
                mediaDetailViewController.selectedImage = selectedImage.resizeImage(newWidth: 400.0)
            }
        default:
            os_log("unknown segue identifier", log: OSLog.default, type: .error)
        }
    }
    
    //MARK: Actions
    @IBAction func unwindToMediaTableView(sender: UIStoryboardSegue) {
        
        // At this point we need to have an OFElement.  If not, return
        guard let entryControl = entryControl else {
            // TODO: Log error
            return
        }
        
        switch (sender.identifier ?? "") {
        case "Save":
            if let sourceViewController = sender.source as? MediaViewController, let image = sourceViewController.mediaImageView.image, let description = sourceViewController.mediaCommentsTextView.text {
                
                if let selectedIndexPath = tableView.indexPathForSelectedRow, let sourceMedia = sourceViewController.media {
                    // Update the source media description & image
                    sourceMedia.Description = description
                    sourceMedia.Content = image
                    do {
                        try Media.updateMediaToDB(db: Database.DB(), media: sourceMedia)
                        if let mediaIndex = media.index(where: { $0.MediaNumber == sourceMedia.MediaNumber}) {
                            media.insert(sourceMedia, at: mediaIndex)
                        }
                        else {
                            media.append(sourceMedia)
                        }
                        tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    }
                    catch {
                        os_log("Unable to update media to the database", log: OSLog.default, type: .error)
                    }
                }
                else if let ofLinkMediaItem = OFLinkMedia(OFNumber: entryControl.ofNumber, MediaNumber: UUID().uuidString, OFElement_ID: entryControl.elementID, SortOrder: ofLinkMedia.count) {
                    let sourceMedia = Media(MediaNumber: ofLinkMediaItem.MediaNumber, Media_Date: Date(), Asset_ID: Authorize.ASSET?.Asset_ID ?? 0, UniqueMediaNumber: 0, MediaType_ID: Media.MEDIA_TYPE_ID_PNG, Url: "", Description: description, Create_Date: Date(), CreateUser_ID: Authorize.CURRENT_USER?.OLUser_ID ?? 0, GPSLocation: sourceViewController.gpsLocation ?? "", LastUpdate: Date(), Dirty: true, Content: image)
                    do {
                        // Add a new media image
                        try sourceMedia.insertMediaToDB(db: Database.DB())
                        try ofLinkMediaItem.insertMediaToDB(db: Database.DB())
                        let newIndexPath = IndexPath(row: ofLinkMedia.count, section: 0)
                        ofLinkMedia.append(ofLinkMediaItem)
                        media.append(sourceMedia)
                        tableView.insertRows(at: [newIndexPath], with: .automatic)
                        entryControl.hasMedia = true
                    }
                    catch {
                        os_log("Unable to save media to the database", log: OSLog.default, type: .error)
                    }
                }
            }
        case "Cancel":
            os_log("Cancel segue - nothing to do", log: OSLog.default, type: .info)
        default:
            os_log("Unknown segue identifier", log: OSLog.default, type: .error)
        }
    }
    @IBAction func addImage(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Image", message: "Choose an image source", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {alert in
            // UIImagePickerController is a view controller that lets a user pick media from their photo library
            let imagePickerController = UIImagePickerController()
            // Only allow photos to be selected, not taken
            imagePickerController.sourceType = .camera
            // make sure the viewcontroller is notified when the user picks an image
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {alert in
            // UIImagePickerController is a view controller that lets a user pick media from their photo library
            let imagePickerController = UIImagePickerController()
            // Only allow photos to be selected, not taken
            imagePickerController.sourceType = .photoLibrary
            // make sure the viewcontroller is notified when the user picks an image
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // use original image
        selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
        
        // Navigate to the MediaViewController
        performSegue(withIdentifier: "ShowAddImage", sender: self)
    }
    
}
