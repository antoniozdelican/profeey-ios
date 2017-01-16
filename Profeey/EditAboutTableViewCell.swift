//
//  EditAboutTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditAboutTableViewCellDelegate: class {
    func textViewDidChange(_ textView: UITextView)
}

class EditAboutTableViewCell: UITableViewCell {
    
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var aboutPlaceholderLabel: UILabel!
    
    weak var editAboutTableViewCellDelegate: EditAboutTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.aboutTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension EditAboutTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.aboutPlaceholderLabel.isHidden = !textView.text.isEmpty
        self.editAboutTableViewCellDelegate?.textViewDidChange(textView)
    }
}
