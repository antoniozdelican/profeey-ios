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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setEditButton() {
        self.followButton.setTitle("EDIT PROFILE", for: UIControlState())
        self.followButton.setTitleColor(Colors.greyDark, for: UIControlState())
        self.followButton.setBackgroundImage(UIImage(named: "btn_grey"), for: UIControlState())
    }
    
    func setFollowButton() {
        self.followButton.setTitle("FOLLOW", for: UIControlState())
        self.followButton.setTitleColor(Colors.blue, for: UIControlState())
        self.followButton.setBackgroundImage(UIImage(named: "btn_blue"), for: UIControlState())
    }
    
    func setFollowingButton() {
        self.followButton.setTitle("FOLLOWING", for: UIControlState())
        self.followButton.setTitleColor(UIColor.white, for: UIControlState())
        self.followButton.setBackgroundImage(UIImage(named: "btn_blue_selected"), for: UIControlState())
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
    
    
    
    @IBAction func followButtonTapped(_ sender: AnyObject) {
        self.profileMainTableViewCellDelegate?.followButtonTapped()
    }
    

}
