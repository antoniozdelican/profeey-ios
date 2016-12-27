//
//  ProfileInfoTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ProfileInfoTableViewCellDelegate {
    func websiteButtonTapped()
}

class ProfileInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var websiteButtonHeightConstraint: NSLayoutConstraint!
    
    var profileInfoTableViewCellDelegate: ProfileInfoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func websiteButtonTapped(_ sender: Any) {
        self.profileInfoTableViewCellDelegate?.websiteButtonTapped()
    }
}
