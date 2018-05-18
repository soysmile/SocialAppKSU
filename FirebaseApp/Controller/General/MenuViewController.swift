//
//  ViewController.swift
//  FirebaseDemo
//
//  Created by George Heints on 22.03.2018.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit
import Firebase

class MenuViewController: UIViewController {

    var users = [User]()

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        // Add the background gradient
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    //
    func setCourse() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }

        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)

            }

        }, withCancel: nil)
    }

    //Save user as User and set up data
    func saveProfileAsUser(completion: @escaping ((_ success:Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let creationDate = Auth.auth().currentUser?.metadata.creationDate else { return }
        let databaseRef = Database.database().reference().child("users/\(uid)")
        print(creationDate)
        let userObject = [
            "role": "user",
            "creationDate" : "\(creationDate)"
            ] as [String:Any]
        
        databaseRef.updateChildValues(userObject) { error, ref in
            completion(error == nil)
        }
    }

    //Save user as Guest and set up data
    func saveProfileAsGuest(completion: @escaping ((_ success:Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let creationDate = Auth.auth().currentUser?.metadata.creationDate else { return }
        let databaseRef = Database.database().reference().child("users/\(uid)")
        let userObject = [
            "role": "guest",
            "creationDate" : "\(creationDate)"
            ] as [String:Any]
        
        databaseRef.updateChildValues(userObject) { error, ref in
            completion(error == nil)
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = Auth.auth().currentUser {
            
            let userID = Auth.auth().currentUser!.uid
            
            //Show user ID to console
            print("userID: \(userID)")
            let ref = Database.database().reference().child("users").child(userID)
            
            if let user = Auth.auth().currentUser {
                
                ref.observe(.value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let userR = User(dictionary: dictionary)
                        userR.id = snapshot.key
                        self.users.append(userR)
                        let isAdmin = "admin"
                        let isUser = "user"
                        var role = ""
                        let currentUser = Auth.auth().currentUser!.uid
                        let emailExist = user.email
                        var emailArray = [NSMutableArray]()
                        
                        //this will crash because of background thread, so lets use dispatch_async to fix
                        DispatchQueue.main.async(execute: {
                            //self.tableView.reloadData()
                        })
                        Auth.auth().addStateDidChangeListener { auth, user in
                            Auth.auth().currentUser?.reload()
                            if let user = user {
                                
                                // Email Verified
                                if user.isEmailVerified {
                                    
                                    //Get user role
                                    role = userR.role!
                                    
                                    //If email exists in Administration Database
                                    let refEmail = Database.database().reference().child("registeredEmailList")
                                    refEmail.observe(.value, with: { (snapshotEmail) in
                                        
                                        if let emailDictionary = snapshotEmail.value as? [String: AnyObject]{
                                            var emails = emailDictionary["email"] as? [String]
                                            if (emails?.contains(emailExist!))!{
                                                
                                                //Change role request
                                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                                changeRequest?.commitChanges { error in
                                                    if error == nil {
                                                                                                                
                                                        self.saveProfileAsUser() { success in
                                                            if success {
                                                                
                                                                print("Операция успешно завершена, вы Пользователь")
                                                            } else {
                                                                
                                                                print("Что то пошло не так")
                                                            }
                                                        }
                                                        
                                                    } else {
                                                        print("Error: \(error!.localizedDescription)")
                                                    }
                                                }
                                                
                                                self.performSegue(withIdentifier: "toHomeScreen", sender: self)
                                                print("\nПользователь существует в базе данных\n")
                                            }else{
                                                
                                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                                changeRequest?.commitChanges { error in
                                                    if error == nil {
                                                        
                                                        self.saveProfileAsGuest() { success in
                                                            if success {

                                                                print("Операция успешно завершена, вы Гость")
                                                            } else {
                                                                
                                                                print("Что то пошло не так")
                                                            }
                                                        }
                                                        
                                                    } else {
                                                        print("Error: \(error!.localizedDescription)")
                                                    }
                                                }
                                                
                                                self.performSegue(withIdentifier: "toHomeScreen", sender: self)
                                                print("\nПользователь не внесен в базу данных, получает статус Абитуриент(Guest)\n")
                                            }
                                        }
                                    })

                                } else {

                                }
                                
                            } else {

                            }
                            
                        }
                        
                        
                    }
                    
                }, withCancel: nil)
            //
            
            
        }
    }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
}
