//
//  SettingsViewController.swift
//  FirebaseApp
//
//  Created by George Heints on 11.04.2018.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController{
    
    
    @IBOutlet weak var dataDisplayView: UIView!
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        profileUsername.setNeedsDisplay()
        UserSetup()
        themeSetup()
        userInteraction()
        hideKeyboard()
        
    }

    func themeSetup(){
        self.title = "Настройки"
        self.tabBarController?.tabBar.isHidden = false
        self.view.backgroundColor = UIColor(red: 24.0/255.0, green: 34.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        profileImage.isUserInteractionEnabled = true
    }
    
    func userInteraction(){
        let tapDataChange = UITapGestureRecognizer(target: self, action: #selector(self.touchTapped(_:)))
        dataDisplayView.addGestureRecognizer(tapDataChange)
    }
    
    @objc func touchTapped(_ sender: UITapGestureRecognizer) {
        var nextVC = self.storyboard?.instantiateViewController(withIdentifier: "changeDataVC") as! UIViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "changeData")
        self.present(vc, animated: true, completion: nil)
    }
    
    func UserSetup() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.fillData(user)
            }
            
        }, withCancel: nil)
    }
    
    func fillData(_ user: User){
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.cornerRadius = 39
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
        profileName.text = user.name
        profileEmail.text = user.email
        profileUsername.text = user.id
        if let profileImageUrl = user.profileImageUrl {
            profileImage.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
    }

}
