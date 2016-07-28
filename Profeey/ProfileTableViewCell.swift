//
//  ProfileTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionsLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var postsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
