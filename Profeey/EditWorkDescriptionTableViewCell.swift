//
//  EditWorkDescriptionTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditWorkDescriptionTableViewCellDelegate: class {
    func textViewDidBeginEditing(_ textView: UITextView)
    func textViewDidChange(_ textView: UITextView)
}

class EditWorkDescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var workDescriptionTextView: UITextView!
    @IBOutlet weak var workDescriptionFakePlaceholderLabel: UILabel!
    
    weak var editWorkDescriptionTableViewCellDelegate: EditWorkDescriptionTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.workDescriptionTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension EditWorkDescriptionTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.editWorkDescriptionTableViewCellDelegate?.textViewDidBeginEditing(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.workDescriptionFakePlaceholderLabel.isHidden = !textView.text.isEmpty
        self.editWorkDescriptionTableViewCellDelegate?.textViewDidChange(textView)
    }
}
