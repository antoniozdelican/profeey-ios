//
//  UserWelcomeTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class UserWelcomeTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionsLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setFollowButton() {
        self.followButton.setTitle("Follow", forState: .Normal)
        self.followButton.setTitleColor(Colors.greyDark, forState: .Normal)
        self.followButton.setBackgroundImage(UIImage(named: "btn_grey_small"), forState: .Normal)
    }
    
    func setFollowingButton() {
        self.followButton.setTitle("Following", forState: .Normal)
        self.followButton.setTitleColor(Colors.green, forState: .Normal)
        self.followButton.setBackgroundImage(UIImage(named: "btn_green_small"), forState: .Normal)
    }

}
