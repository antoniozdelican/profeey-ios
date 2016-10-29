//
//  EditAboutTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class EditAboutTableViewCell: UITableViewCell {
    
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var aboutFakePlaceholderLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension EditAboutTableViewCell: EditAboutDelegate {
    
    func toggleAboutFakePlaceholderLabel(_ hidden: Bool) {
        self.aboutFakePlaceholderLabel.isHidden = hidden
    }
}
