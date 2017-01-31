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
    func numberOfRecommendationsButtonTapped()
    func followButtonTapped()
    func recommendButtonTapped()
}

class ProfileMainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var numberOfPostsButton: UIButton!
    @IBOutlet weak var numberOfFollowersButton: UIButton!
    @IBOutlet weak var numberOfRecommendationsButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var recommendButtonWidthConstraint: NSLayoutConstraint!
    
    weak var profileMainTableViewCellDelegate: ProfileMainTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        
        // Loading buttons.
        self.recommendButton.setBackgroundImage(UIImage(named: "btn_disabled_resizable"), for: UIControlState.normal)
        self.followButton.setBackgroundImage(UIImage(named: "btn_disabled_resizable"), for: UIControlState.normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setRecommendButton() {
        UIView.performWithoutAnimation {
            self.recommendButton.setTitle("Recommend", for: UIControlState())
            self.recommendButton.setTitleColor(Colors.turquoise, for: UIControlState())
            self.recommendButton.setBackgroundImage(UIImage(named: "btn_recommend_resizable"), for: UIControlState.normal)
            self.recommendButton.layoutIfNeeded()
        }
    }
    
    func setRecommendingButton() {
        UIView.performWithoutAnimation {
            self.recommendButton.setTitle("Recommending", for: UIControlState())
            self.recommendButton.setTitleColor(UIColor.white, for: UIControlState())
            self.recommendButton.setBackgroundImage(UIImage(named: "btn_recommending_resizable"), for: UIControlState.normal)
            self.recommendButton.layoutIfNeeded()
        }
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
    
    // MARK: IBActions
    
    @IBAction func numberOfPostsButtonTapped(_ sender: AnyObject) {
        self.profileMainTableViewCellDelegate?.numberOfPostsButtonTapped()
    }
    
    @IBAction func numberOfFollowersButtonTapped(_ sender: AnyObject) {
        self.profileMainTableViewCellDelegate?.numberOfFollowersButtonTapped()
    }
    
    @IBAction func numberOfRecommendationsButtonTapped(_ sender: AnyObject) {
        self.profileMainTableViewCellDelegate?.numberOfRecommendationsButtonTapped()
    }
    
    @IBAction func recommendButtonTapped(_ sender: AnyObject) {
        self.profileMainTableViewCellDelegate?.recommendButtonTapped()
    }
    
    
    @IBAction func followButtonTapped(_ sender: AnyObject) {
        self.profileMainTableViewCellDelegate?.followButtonTapped()
    }
    

}
