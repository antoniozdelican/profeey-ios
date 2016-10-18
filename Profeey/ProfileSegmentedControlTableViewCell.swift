//
//  ProfileSegmentedControlTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 28/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ProfileSegmentedControlTableViewCellDelegate {
    func segmentChanged(profileSegment: ProfileSegment)
}

class ProfileSegmentedControlTableViewCell: UITableViewCell {

    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var experienceButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var postsButtonBorderView: UIView!
    @IBOutlet weak var experienceButtonBorderView: UIView!
    @IBOutlet weak var contactButtonBorderView: UIView!
    
    var profileSegmentedControlTableViewCellDelegate: ProfileSegmentedControlTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initial.
        self.setPostsButtonActive()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    fileprivate func setPostsButtonActive() {
        self.postsButton.setTitleColor(Colors.black, for: UIControlState())
        self.experienceButton.setTitleColor(Colors.greyDark, for: UIControlState())
        self.contactButton.setTitleColor(Colors.greyDark, for: UIControlState())
        self.postsButtonBorderView.isHidden = false
        self.experienceButtonBorderView.isHidden = true
        self.contactButtonBorderView.isHidden = true
    }
    
    fileprivate func setExperienceButtonActive() {
        self.postsButton.setTitleColor(Colors.greyDark, for: UIControlState())
        self.experienceButton.setTitleColor(Colors.black, for: UIControlState())
        self.contactButton.setTitleColor(Colors.greyDark, for: UIControlState())
        self.postsButtonBorderView.isHidden = true
        self.experienceButtonBorderView.isHidden = false
        self.contactButtonBorderView.isHidden = true
    }
    
    fileprivate func setContactButtonActive() {
        self.postsButton.setTitleColor(Colors.greyDark, for: UIControlState())
        self.experienceButton.setTitleColor(Colors.greyDark, for: UIControlState())
        self.contactButton.setTitleColor(Colors.black, for: UIControlState())
        self.postsButtonBorderView.isHidden = true
        self.experienceButtonBorderView.isHidden = true
        self.contactButtonBorderView.isHidden = false
    }
    
    // MARK: IBActions
    
    @IBAction func postsButtonTapped(_ sender: AnyObject) {
        self.setPostsButtonActive()
        self.profileSegmentedControlTableViewCellDelegate?.segmentChanged(profileSegment: ProfileSegment.posts)
    }
    
    @IBAction func experienceButtonTapped(_ sender: AnyObject) {
        self.setExperienceButtonActive()
        self.profileSegmentedControlTableViewCellDelegate?.segmentChanged(profileSegment: ProfileSegment.experience)
    }
    
    @IBAction func contactButtonTapped(_ sender: AnyObject) {
        self.setContactButtonActive()
        self.profileSegmentedControlTableViewCellDelegate?.segmentChanged(profileSegment: ProfileSegment.contact)
    }
    

}
