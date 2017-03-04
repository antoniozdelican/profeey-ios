//
//  ProfileSegmentedControlSectionHeader3.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

//protocol ProfileSegmentedControlSectionHeaderDelegate: class {
//    func segmentChanged(_ profileSegment: ProfileSegment)
//}

class ProfileSegmentedControlSectionHeader3: UITableViewHeaderFooterView {
    
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var experienceButton: UIButton!
    @IBOutlet weak var skillsButton: UIButton!
    @IBOutlet weak var postsButtonBorderView: UIView!
    @IBOutlet weak var experienceButtonBorderView: UIView!
    @IBOutlet weak var skillsButtonBorderView: UIView!
    
    weak var profileSegmentedControlSectionHeaderDelegate: ProfileSegmentedControlSectionHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setPostsButtonActive()
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
        self.profileSegmentedControlSectionHeaderDelegate?.segmentChanged(ProfileSegment.posts)
    }
    
    @IBAction func experienceButtonTapped(_ sender: AnyObject) {
        self.setExperienceButtonActive()
        //self.profileSegmentedControlSectionHeaderDelegate?.segmentChanged(ProfileSegment.experience)
    }
    
    @IBAction func skillsButtonTapped(_ sender: AnyObject) {
        self.setSkillsButtonActive()
        self.profileSegmentedControlSectionHeaderDelegate?.segmentChanged(ProfileSegment.skills)
    }

}
