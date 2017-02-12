//
//  ProfileSegmentedControlSectionHeader.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

protocol ProfileSegmentedControlSectionHeaderDelegate: class {
    func segmentChanged(_ profileSegment: ProfileSegment)
}

class ProfileSegmentedControlSectionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    weak var profileSegmentedControlSectionHeaderDelegate: ProfileSegmentedControlSectionHeaderDelegate?

    // MARK: IBActions
    
    @IBAction func segmentedControlValueChanged(_ sender: AnyObject) {
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            self.profileSegmentedControlSectionHeaderDelegate?.segmentChanged(ProfileSegment.posts)
        case 1:
            self.profileSegmentedControlSectionHeaderDelegate?.segmentChanged(ProfileSegment.experience)
        case 2:
            self.profileSegmentedControlSectionHeaderDelegate?.segmentChanged(ProfileSegment.skills)
        default:
            return
        }
    
    }

}
