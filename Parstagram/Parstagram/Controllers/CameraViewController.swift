//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Super MattMatt on 11/10/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Props
    
    @IBOutlet var picImageView: UIImageView!
    @IBOutlet var commentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    
    @IBAction func onCaptionSubmit(_ sender: Any) {
        let post = PFObject(className: "Posts")
        
        post["caption"] = commentTextField.text!
        post["author"] = PFUser.current()!
        
        let imageData = picImageView.image!.pngData()
        let file = PFFileObject(data: imageData!)
        post["image"] = file
        
        post.saveInBackground { (success, error) in
            if success {
                print("saved post success to parse")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error: \(error?.localizedDescription ?? "Error Saving Post")")
            }
            
        }
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        picImageView.image = scaledImage
        dismiss(animated: true, completion: nil)
    }
    
    
}
