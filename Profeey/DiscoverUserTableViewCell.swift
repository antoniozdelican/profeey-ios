//
//  DiscoverUserTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol DiscoverUserTableViewCellDelegate: class {
    func followButtonTapped(_ cell: DiscoverUserTableViewCell)
}

class DiscoverUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var preferredUsernameLabel: UILabel!
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var followButton: UIButton!
    
    weak var discoverUserTableViewCellDelegate: DiscoverUserTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        
        // Loading buttons.
        self.followButton.setBackgroundImage(UIImage(named: "btn_disabled_resizable"), for: UIControlState.normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
    
    @IBAction func followButtonTapped(_ sender: AnyObject) {
        self.discoverUserTableViewCellDelegate?.followButtonTapped(self)
    }
}
