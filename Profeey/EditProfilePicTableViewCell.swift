//
//  EditProfilePicTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditProfilePicTableViewCellDelegate {
    func editButtonTapped()
}

class EditProfilePicTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    var editProfilePicTableViewCellDelegate: EditProfilePicTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func editButtonTapped(_ sender: Any) {
        self.editProfilePicTableViewCellDelegate?.editButtonTapped()
    }

}
