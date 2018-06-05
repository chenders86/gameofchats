//
//  ViewController.swift
//  gameofchats
//
//  Created by Casey Henderson on 5/18/18.
//  Copyright © 2018 Casey Henderson. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        checkIfUserIsLoggedIn()
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        } else {
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    //self.navigationItem.title = dictionary["name"] as? String
                    
                    let user = User()
                    user.setValuesForKeys(dictionary)
                    self.setupNavBarWithUser(user: user)
                }
                
            }, withCancel: nil)
        }
    }
    
    func setupNavBarWithUser(user: User) {
        //let titleView = UIView()
        //titleView.translatesAutoresizingMaskIntoConstraints = false
        //titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40) // Unnecessary if setting as titleView
        
        let containerView = UIView()
        //titleView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        //containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 40) // Delete this if you uncomment out all the other comments.
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        containerView.addSubview(profileImageView)
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 8).isActive = true // can opt to remove constant
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        //containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        //containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = containerView
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        navigationItem.title = nil
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}

