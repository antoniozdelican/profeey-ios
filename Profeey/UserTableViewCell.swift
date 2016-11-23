//
//  UserTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var preferredUsernameLabel: UILabel!
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        
        // Loading button.
        self.followButton.layer.cornerRadius = 4.0
        self.followButton.layer.borderWidth = 1.0
        self.followButton.layer.borderColor = Colors.disabled.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setFollowButton() {
        self.followButton.setTitle("Follow", for: UIControlState())
        self.followButton.setTitleColor(Colors.blue, for: UIControlState())
        self.followButton.layer.borderColor = Colors.blue.cgColor
        self.followButton.backgroundColor = UIColor.clear
    }
    
    func setFollowingButton() {
        self.followButton.setTitle("Following", for: UIControlState())
        self.followButton.setTitleColor(UIColor.white, for: UIControlState())
        self.followButton.layer.borderColor = Colors.blue.cgColor
        self.followButton.backgroundColor = Colors.blue
    }
}
