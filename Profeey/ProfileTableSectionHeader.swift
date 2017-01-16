//
//  ProfileTableSectionHeader.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ProfileTableSectionHeaderDelegate: class {
    func editButtonTapped()
}

class ProfileTableSectionHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var editButton: UIButton?
    
    weak var profileTableSectionHeaderDelegate: ProfileTableSectionHeaderDelegate?
    
    // MARK: IBActions
    
    @IBAction func editButtonTapped(_ sender: AnyObject) {
        self.profileTableSectionHeaderDelegate?.editButtonTapped()
    }
}
