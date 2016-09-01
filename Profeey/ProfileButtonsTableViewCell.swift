//
//  ProfileButtonsTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 28/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ProfileButtonsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var numberOfPostsButton: UIButton!
    @IBOutlet weak var numberOfFollowersButton: UIButton!
    @IBOutlet weak var numberOfRecommendationsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
