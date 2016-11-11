//
//  DiscoverUserTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol DiscoverUserTableViewCellDelegate {
    func followButtonTapped(_ cell: DiscoverUserTableViewCell)
}

class DiscoverUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var preferredUsernameLabel: UILabel!
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var discoverUserTableViewCellDelegate: DiscoverUserTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 20.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setFollowButton() {
        self.followButton.setTitle("FOLLOW", for: UIControlState())
        self.followButton.setTitleColor(Colors.blue, for: UIControlState())
    }
    
    func setFollowingButton() {
        self.followButton.setTitle("FOLLOWING", for: UIControlState())
        self.followButton.setTitleColor(Colors.blue, for: UIControlState())
    }
    
    // MARK: IBActions
    
    @IBAction func followButtonTapped(_ sender: AnyObject) {
        self.discoverUserTableViewCellDelegate?.followButtonTapped(self)
    }
}
