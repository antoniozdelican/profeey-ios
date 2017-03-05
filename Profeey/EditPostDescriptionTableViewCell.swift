//
//  EditPostDescriptionTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 04/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditPostDescriptionTableViewCellDelegate: class {
    func textViewDidChange(_ textView: UITextView)
}

class EditPostDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionImageView: UIImageView?
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionPlaceholderLabel: UILabel!
    
    weak var editPostDescriptionTableViewCellDelegate: EditPostDescriptionTableViewCellDelegate?
    
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
        self.descriptionImageView?.image = !textView.text.isEmpty ? UIImage(named: "ic_caption_on") : UIImage(named: "ic_caption_off")
        self.editPostDescriptionTableViewCellDelegate?.textViewDidChange(textView)
    }
}
