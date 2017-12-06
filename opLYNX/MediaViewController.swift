//
//  MediaViewController.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-13.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit
import os.log

class MediaViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Outlets
    @IBOutlet weak var mediaCommentsTextView: UITextView!
    @IBOutlet weak var mediaStackView: UIStackView!
    @IBOutlet weak var mediaImageView: ScaleAspectFitImageView!
    
    var media: Media?
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = EntryControl.EC_NONMANDATORY_COLOR
        
        // Set up views
        if let media = media {
            mediaCommentsTextView.text = media.Description
            mediaImageView.image = media.Content
        }
        else if let selectedImage = selectedImage {
            mediaImageView.image = selectedImage
        }
        
        // Borders
        mediaCommentsTextView?.layer.cornerRadius = 5
        mediaCommentsTextView?.layer.masksToBounds = true
        mediaCommentsTextView?.layer.borderWidth = 1.0
        mediaImageView?.layer.cornerRadius = 5
        mediaImageView?.layer.masksToBounds = true
        mediaImageView?.layer.borderWidth = 1.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        
        // Hide keyboard
        //nameTextField.resignFirstResponder()
        
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
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else
        {
            os_log("Expected a dictionary containing an image", log: OSLog.default, type: .error)
            dismiss(animated: true, completion: nil)
            return
        }
        
        // Set the photoImageView to display the selected image
        mediaImageView.image = selectedImage.resizeImage(newWidth: 400.0)
        
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

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth/self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
