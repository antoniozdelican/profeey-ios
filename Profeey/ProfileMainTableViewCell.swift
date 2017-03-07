//
//  ProfileMain2TableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ProfileMainTableViewCellDelegate: class {
    func numberOfPostsButtonTapped()
    func numberOfFollowersButtonTapped()
    func numberOfCategoriesButtonTapped()
    func followButtonTapped()
    func messageButtonTapped()
}

class ProfileMainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var numberOfPostsButton: UIButton!
    @IBOutlet weak var numberOfFollowersButton: UIButton!
    @IBOutlet weak var numberOfCategoriesButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var messageButtonWidthConstraint: NSLayoutConstraint!
    
    weak var profileMainTableViewCellDelegate: ProfileMainTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        
        // Set buttons.
        self.followButton.setBackgroundImage(UIImage(named: "btn_disabled_resizable"), for: UIControlState.normal)
        self.messageButton.setBackgroundImage(UIImage(named: "btn_follow_resizable"), for: UIControlState.normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setEditButton() {
        UIView.performWithoutAnimation {
            self.followButton.setTitle("Edit Profile", for: UIControlState())
            self.followButton.setTitleColor(Colors.grey, for: UIControlState())
            self.followButton.setBackgroundImage(UIImage(named: "btn_edit_profile_resizable"), for: UIControlState.normal)
            self.followButton.layoutIfNeeded()
        }
    }
    
    func setFollowButton() {
        UIView.performWithoutAnimation {
            self.followButton.setTitle("Follow", for: UIControlState())
            self.followButton.setTitleColor(Colors.blue, for: UIControlState())
            self.followButton.setBackgroundImage(UIImage(named: "btn_follow_resizable"), for: UIControlState.normal)
            self.followButton.layoutIfNeeded()
        }
    }
    
    func setFollowingButton() {
        UIView.performWithoutAnimation {
            self.followButton.setTitle("Following", for: UIControlState())
            self.followButton.setTitleColor(UIColor.white, for: UIControlState())
            self.followButton.setBackgroundImage(UIImage(named: "btn_following_resizable"), for: UIControlState.normal)
            self.followButton.layoutIfNeeded()
        }
    }
    
    func setBlockingButton() {
        UIView.performWithoutAnimation {
            self.followButton.setTitle("Blocked", for: UIControlState())
            self.followButton.setTitleColor(Colors.red, for: UIControlState())
            self.followButton.setBackgroundImage(UIImage(named: "btn_block_resizable"), for: UIControlState.normal)
            self.followButton.layoutIfNeeded()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func numberOfPostsButtonTapped(_ sender: AnyObject) {
        self.profileMainTableViewCellDelegate?.numberOfPostsButtonTapped()
    }
    
    @IBAction func numberOfFollowersButtonTapped(_ sender: AnyObject) {
        self.profileMainTableViewCellDelegate?.numberOfFollowersButtonTapped()
    }
    
    @IBAction func numberOfCategoriesButtonTapped(_ sender: AnyObject) {
        self.profileMainTableViewCellDelegate?.numberOfCategoriesButtonTapped()
    }
    
    @IBAction func messageButtonTapped(_ sender: AnyObject) {
        self.profileMainTableViewCellDelegate?.messageButtonTapped()
    }
    
    @IBAction func followButtonTapped(_ sender: AnyObject) {
        self.profileMainTableViewCellDelegate?.followButtonTapped()
    }
    

}
