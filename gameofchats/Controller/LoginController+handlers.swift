//
//  LoginController+handlers.swift
//  gameofchats
//
//  Created by Casey Henderson on 5/29/18.
//  Copyright © 2018 Casey Henderson. All rights reserved.
//

import UIKit
import Firebase


extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in // Creates account in Auth
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) { // Uploads image into storage database
            
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String: AnyObject])
                    }
                })
            }
        }
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = Firebase.Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in // Creates/saves user info in database
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    @objc func handleSelectProfileImageVIew() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
}
