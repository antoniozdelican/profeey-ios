//
//  ProfileEmptyTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

enum AddButtonType {
    case post
}

protocol ProfileEmptyTableViewCellDelegate: class {
    func addButtonTapped(_ addButtonType: AddButtonType)
}

class ProfileEmptyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var addButtonType: AddButtonType?
    weak var profileEmptyTableViewCellDelegate: ProfileEmptyTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addButton.setBackgroundImage(UIImage(named: "btn_edit_profile_resizable"), for: UIControlState.normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setAddPostButton() {
        UIView.performWithoutAnimation {
            self.addButton.setTitle("Add Post", for: UIControlState.normal)
            self.addButton.layoutIfNeeded()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        guard let addButtonType = self.addButtonType else {
            return
        }
        self.profileEmptyTableViewCellDelegate?.addButtonTapped(addButtonType)
    }
}
