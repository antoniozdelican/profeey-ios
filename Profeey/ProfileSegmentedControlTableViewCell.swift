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
    @IBOutlet weak var skillsButton: UIButton!
    @IBOutlet weak var postsButtonBorderView: UIView!
    @IBOutlet weak var experienceButtonBorderView: UIView!
    @IBOutlet weak var skillsButtonBorderView: UIView!
    
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
        self.experienceButton.setTitleColor(Colors.grey, for: UIControlState())
        self.skillsButton.setTitleColor(Colors.grey, for: UIControlState())
        self.postsButtonBorderView.isHidden = false
        self.experienceButtonBorderView.isHidden = true
        self.skillsButtonBorderView.isHidden = true
    }
    
    fileprivate func setExperienceButtonActive() {
        self.postsButton.setTitleColor(Colors.grey, for: UIControlState())
        self.experienceButton.setTitleColor(Colors.black, for: UIControlState())
        self.skillsButton.setTitleColor(Colors.grey, for: UIControlState())
        self.postsButtonBorderView.isHidden = true
        self.experienceButtonBorderView.isHidden = false
        self.skillsButtonBorderView.isHidden = true
    }
    
    fileprivate func setSkillsButtonActive() {
        self.postsButton.setTitleColor(Colors.grey, for: UIControlState())
        self.experienceButton.setTitleColor(Colors.grey, for: UIControlState())
        self.skillsButton.setTitleColor(Colors.black, for: UIControlState())
        self.postsButtonBorderView.isHidden = true
        self.experienceButtonBorderView.isHidden = true
        self.skillsButtonBorderView.isHidden = false
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
    
    @IBAction func skillsButtonTapped(_ sender: AnyObject) {
        self.setSkillsButtonActive()
        self.profileSegmentedControlTableViewCellDelegate?.segmentChanged(profileSegment: ProfileSegment.skills)
    }
    

}
