//
//  ProfileSegmentedControlTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 28/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ProfileSegmentedControlTableViewCell: UITableViewCell {

    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setPostsButtonActive() {
        self.postsButton.setTitleColor(Colors.black, for: UIControlState())
        self.aboutButton.setTitleColor(Colors.greyDark, for: UIControlState())
        self.contactButton.setTitleColor(Colors.greyDark, for: UIControlState())
    }
    
    func setAboutButtonActive() {
        self.postsButton.setTitleColor(Colors.greyDark, for: UIControlState())
        self.aboutButton.setTitleColor(Colors.black, for: UIControlState())
        self.contactButton.setTitleColor(Colors.greyDark, for: UIControlState())
    }
    
    func setContactButtonActive() {
        self.postsButton.setTitleColor(Colors.greyDark, for: UIControlState())
        self.aboutButton.setTitleColor(Colors.greyDark, for: UIControlState())
        self.contactButton.setTitleColor(Colors.black, for: UIControlState())
    }

}
