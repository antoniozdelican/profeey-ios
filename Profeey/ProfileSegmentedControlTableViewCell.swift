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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setPostsButtonActive() {
        self.postsButton.setTitleColor(Colors.black, forState: UIControlState.Normal)
        self.aboutButton.setTitleColor(Colors.greyDark, forState: UIControlState.Normal)
    }
    
    func setAboutButtonActive() {
        self.postsButton.setTitleColor(Colors.greyDark, forState: UIControlState.Normal)
        self.aboutButton.setTitleColor(Colors.black, forState: UIControlState.Normal)
    }

}
