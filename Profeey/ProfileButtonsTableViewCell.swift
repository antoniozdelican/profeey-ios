//
//  ProfileButtonsTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 28/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ProfileButtonsTableViewCell: UITableViewCell {

    @IBOutlet weak var numberOfPostsButton: UIButton!
    @IBOutlet weak var numberOfFollowersButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setEditButton() {
        self.followButton.setTitle("Edit", for: UIControlState())
        self.followButton.setTitleColor(Colors.greyDark, for: UIControlState())
        self.followButton.setBackgroundImage(UIImage(named: "btn_grey_small"), for: UIControlState())
    }
    
    func setFollowButton() {
        self.followButton.setTitle("Follow", for: UIControlState())
        self.followButton.setTitleColor(Colors.blue, for: UIControlState())
        self.followButton.setBackgroundImage(UIImage(named: "btn_blue_small"), for: UIControlState())
    }
    
    func setFollowingButton() {
        self.followButton.setTitle("Following", for: UIControlState())
        self.followButton.setTitleColor(UIColor.white, for: UIControlState())
        self.followButton.setBackgroundImage(UIImage(named: "btn_blue_small_selected"), for: UIControlState())
    }
    
    func setEnabledNumberOfFollowersButton() {
        self.numberOfFollowersButton.setTitleColor(Colors.black, for: UIControlState())
    }
    
    func setDisabledNumberOfFollowersButton() {
        self.numberOfFollowersButton.setTitleColor(Colors.disabled, for: UIControlState())
    }

}
