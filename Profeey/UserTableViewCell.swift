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
    @IBOutlet weak var professionsLabel: UILabel!
    @IBOutlet weak var followButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setFollowButton() {
        self.followButton?.setTitle("FOLLOW", forState: UIControlState.Normal)
        self.followButton?.setTitleColor(Colors.blue, forState: UIControlState.Normal)
        self.followButton?.setImage(UIImage(named: "ic_add_blue"), forState: UIControlState.Normal)
        self.followButton?.setBackgroundImage(UIImage(named: "btn_blue_small"), forState: UIControlState.Normal)
    }
    
    func setFollowingButton() {
        self.followButton?.setTitle("FOLLOWING", forState: UIControlState.Normal)
        self.followButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.followButton?.setImage(UIImage(named: "ic_check_white"), forState: UIControlState.Normal)
        self.followButton?.setBackgroundImage(UIImage(named: "btn_blue_small_selected"), forState: UIControlState.Normal)
    }

}
