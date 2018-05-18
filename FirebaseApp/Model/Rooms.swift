//
//  Rooms.swift
//  FirebaseApp
//
//  Created by George Heints on 10.05.2018.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

class Rooms: NSObject {
    var adminId: String?
    var maxLimit: String?
    var name: String?
    var priority: String?
    var roomID: String?
    var roomImageUrl: String?
    var title: String?
    init(dictionary: [String: AnyObject]) {
        self.adminId = dictionary["adminId"] as? String
        self.maxLimit = dictionary["maxLimit"] as? String
        self.name = dictionary["name"] as? String
        self.priority = dictionary["priority"] as? String
        self.roomID = dictionary["roomID"] as? String
        self.roomImageUrl = dictionary["roomImageUrl"] as? String
        self.title = dictionary["title"] as? String
    }
}

