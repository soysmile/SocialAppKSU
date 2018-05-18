//
//  Email.swift
//  FirebaseApp
//
//  Created by George Heints on 22.03.2018.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

class registeredEmailList: NSObject {
    var email: [String?]
    init(dictionary: [String: AnyObject]) {
        self.email = (dictionary["email"] as? [String])!
    }
}

