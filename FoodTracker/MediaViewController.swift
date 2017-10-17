//
//  MediaViewController.swift
//  FoodTracker
//
//  Created by oplynx developer on 2017-10-13.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit

class MediaViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Outlets
    @IBOutlet weak var mediaCommentsTextView: UITextView!
    @IBOutlet weak var mediaImageView: UIImageView!
    
    /*
     This value is either passed by MediaTableViewController in prepare(for:sender:)
     or constructed as part of adding a new image/media item
     */
    var media: Media?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up views if editing an existing Meal
        if let media = media {
            mediaCommentsTextView.text = media.Description
            mediaImageView.image = media.ImageContent
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        // Hide keyboard
        //nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library
        let imagePickerController = UIImagePickerController()
        // Only allow photos to be selected, not taken
        imagePickerController.sourceType = .camera
        // make sure the viewcontroller is notified when the user picks an image
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // use original image
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else
        {
            fatalError("Expected a dictionary containing an image but was provided the following: \(info)")
        }
        
        // Set the photoImageView to display the selected image
        mediaImageView.image = selectedImage
        
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
