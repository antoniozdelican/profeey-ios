//
//  ProfilePicTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 28/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ProfilePicTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
