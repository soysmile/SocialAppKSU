//
//  SettingsTableViewCell.swift
//  FirebaseApp
//
//  Created by George Heints on 18.04.2018.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var settingsProfileTag: UILabel!
    @IBOutlet weak var settingsProfileEmail: UILabel!
    @IBOutlet weak var settingsProfileUsername: UILabel!
    @IBOutlet weak var settingsProfileImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        settingsProfileImg.image = UIImage(named: "testuser")

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
