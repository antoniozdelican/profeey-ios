//
//  ProfileMain2TableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ProfileMainTableViewCellDelegate {
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
    
    var profileMainTableViewCellDelegate: ProfileMainTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        
        // Loading buttons
        self.recommendButton.layer.cornerRadius = 4.0
        self.recommendButton.layer.borderWidth = 1.0
        self.recommendButton.layer.borderColor = Colors.disabled.cgColor
        self.followButton.layer.cornerRadius = 4.0
        self.followButton.layer.borderWidth = 1.0
        self.followButton.layer.borderColor = Colors.disabled.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setRecommendButton() {
        self.recommendButton.setTitle("Recommend", for: UIControlState())
        self.recommendButton.setTitleColor(Colors.turquoise, for: UIControlState())
        self.recommendButton.layer.borderColor = Colors.turquoise.cgColor
        self.recommendButton.backgroundColor = UIColor.clear
//        self.recommendButton.setBackgroundImage(UIImage(named: "btn_recommend"), for: UIControlState())
    }
    
    func setRecommendingButton() {
        self.recommendButton.setTitle("Recommending", for: UIControlState())
        self.recommendButton.setTitleColor(UIColor.white, for: UIControlState())
        self.recommendButton.layer.borderColor = Colors.turquoise.cgColor
        self.recommendButton.backgroundColor = Colors.turquoise
//        self.recommendButton.setBackgroundImage(UIImage(named: "btn_recommending"), for: UIControlState())
    }
    
    func setEditButton() {
        self.followButton.setTitle("Edit Profile", for: UIControlState())
        self.followButton.setTitleColor(Colors.grey, for: UIControlState())
        self.followButton.layer.borderColor = Colors.grey.cgColor
        self.followButton.backgroundColor = UIColor.clear
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
