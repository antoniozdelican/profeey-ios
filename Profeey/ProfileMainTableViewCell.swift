//
//  ProfileMainTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 03/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ProfileMainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 40.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
