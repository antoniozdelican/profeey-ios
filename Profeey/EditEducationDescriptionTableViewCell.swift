//
//  EditEducationDescriptionTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditEducationDescriptionTableViewCellDelegate: class {
    func textViewDidBeginEditing(_ textView: UITextView)
    func textViewDidChange(_ textView: UITextView)
}

class EditEducationDescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var educationDescriptionTextView: UITextView!
    @IBOutlet weak var educationDescriptionFakePlaceholderLabel: UILabel!
    
    weak var editEducationDescriptionTableViewCellDelegate: EditEducationDescriptionTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.educationDescriptionTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension EditEducationDescriptionTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.editEducationDescriptionTableViewCellDelegate?.textViewDidBeginEditing(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.educationDescriptionFakePlaceholderLabel.isHidden = !textView.text.isEmpty
        self.editEducationDescriptionTableViewCellDelegate?.textViewDidChange(textView)
    }
}
