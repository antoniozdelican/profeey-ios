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
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var followButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 20.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setFollowButton() {
        self.followButton?.setTitle("FOLLOW", for: UIControlState())
        self.followButton?.setTitleColor(Colors.blue, for: UIControlState())
        self.followButton?.setImage(UIImage(named: "ic_add_blue"), for: UIControlState())
        self.followButton?.setBackgroundImage(UIImage(named: "btn_blue_small"), for: UIControlState())
    }
    
    func setFollowingButton() {
        self.followButton?.setTitle("FOLLOWING", for: UIControlState())
        self.followButton?.setTitleColor(UIColor.white, for: UIControlState())
        self.followButton?.setImage(UIImage(named: "ic_check_white"), for: UIControlState())
        self.followButton?.setBackgroundImage(UIImage(named: "btn_blue_small_selected"), for: UIControlState())
    }

}
