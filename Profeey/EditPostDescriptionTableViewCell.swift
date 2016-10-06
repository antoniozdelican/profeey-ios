//
//  EditPostDescriptionTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 04/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditPostDescriptionTableViewCellDelegate {
    func textViewDidChange(_ textView: UITextView)
}

class EditPostDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionPlaceholderLabel: UILabel!
    
    var editPostDescriptionTableViewCellDelegate: EditPostDescriptionTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.descriptionTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension EditPostDescriptionTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.descriptionPlaceholderLabel.isHidden = !textView.text.isEmpty
        self.editPostDescriptionTableViewCellDelegate?.textViewDidChange(textView)
    }
}
