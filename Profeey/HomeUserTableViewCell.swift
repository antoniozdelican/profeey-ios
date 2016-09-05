//
//  HomeUserTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 03/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class HomeUserTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 20.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
