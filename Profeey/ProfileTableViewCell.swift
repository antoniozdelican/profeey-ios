//
//  ProfileTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 04/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var recommendationsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setEditButton() {
        self.followButton.setTitle("EDIT", forState: UIControlState.Normal)
        self.followButton.setTitleColor(Colors.greyDark, forState: UIControlState.Normal)
        self.followButton.setBackgroundImage(UIImage(named: "btn_grey_small"), forState: UIControlState.Normal)
    }
    
    func setFollowButton() {
        self.followButton.setTitle("FOLLOW", forState: UIControlState.Normal)
        self.followButton.setTitleColor(Colors.blue, forState: UIControlState.Normal)
        self.followButton.setBackgroundImage(UIImage(named: "btn_blue_small"), forState: UIControlState.Normal)
    }
    
    func setFollowingButton() {
        self.followButton.setTitle("FOLLOWING", forState: UIControlState.Normal)
        self.followButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.followButton.setBackgroundImage(UIImage(named: "btn_blue_small_selected"), forState: UIControlState.Normal)
    }

}
