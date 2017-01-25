//
//  NewMessageUserTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

class NewMessageUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var preferredUsernameLabel: UILabel!
    @IBOutlet weak var professionNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
