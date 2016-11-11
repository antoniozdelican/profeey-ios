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
    case experience
}

protocol ProfileEmptyTableViewCellDelegate {
    func addButtonTapped(_ addButtonType: AddButtonType)
}

class ProfileEmptyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var addButtonType: AddButtonType?
    var profileEmptyTableViewCellDelegate: ProfileEmptyTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        guard let addButtonType = self.addButtonType else {
            return
        }
        self.profileEmptyTableViewCellDelegate?.addButtonTapped(addButtonType)
    }
}
