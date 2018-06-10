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
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        // change height of inputContainerView
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // change height of nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        // change height of emailTextField
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        // change height of passwordTextField
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            self.messagesController?.fetchUserAndSetupNavBarTitle()
            
            self.dismiss(animated: true, completion: nil)
            print("Successfully logged in user \(email)")
        }
    }
    
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
                        print(error!.localizedDescription)
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
            
            //self.messagesController?.fetchUserAndSetupNavBarTitle()
            self.messagesController?.navigationItem.title = values["name"] as? String
            
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
