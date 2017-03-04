//
//  ProfileSegmentedControlSectionHeader2.swift
//  Profeey
//
//  Created by Antonio Zdelican on 03/03/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

class ProfileSegmentedControlSectionHeader2: UITableViewHeaderFooterView {
    
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var skillsButton: UIButton!
    @IBOutlet weak var postsButtonBorderView: UIView!
    @IBOutlet weak var skillsButtonBorderView: UIView!
    
    weak var profileSegmentedControlSectionHeaderDelegate: ProfileSegmentedControlSectionHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setPostsButtonActive()
    }
    
    fileprivate func setPostsButtonActive() {
        self.postsButton.setTitleColor(Colors.blue, for: UIControlState())
        self.skillsButton.setTitleColor(Colors.grey, for: UIControlState())
        self.postsButtonBorderView.isHidden = true
        self.skillsButtonBorderView.isHidden = true
    }
    
    fileprivate func setSkillsButtonActive() {
        self.postsButton.setTitleColor(Colors.grey, for: UIControlState())
        self.skillsButton.setTitleColor(Colors.blue, for: UIControlState())
        self.postsButtonBorderView.isHidden = true
        self.skillsButtonBorderView.isHidden = true
    }
    
    // MARK: IBActions
    
    @IBAction func postsButtonTapped(_ sender: AnyObject) {
        self.setPostsButtonActive()
        self.profileSegmentedControlSectionHeaderDelegate?.segmentChanged(ProfileSegment.posts)
    }
    
    @IBAction func skillsButtonTapped(_ sender: AnyObject) {
        self.setSkillsButtonActive()
        self.profileSegmentedControlSectionHeaderDelegate?.segmentChanged(ProfileSegment.skills)
    }

}
