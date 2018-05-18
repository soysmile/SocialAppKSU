//
//  AdminViewCViewController.swift
//  FirebaseApp
//
//  Created by George Heints on 24.03.2018.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit
import Firebase

class AdminViewCViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func adminLogOut(_ sender: Any) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }


}
