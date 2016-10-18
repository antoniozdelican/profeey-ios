//
//  EditWorkTitleTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditWorkTitleTableViewCellDelegate {
    func titleTextFieldChanged(_ text: String)
}

class EditWorkTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    var editWorkTitleTableViewCellDelegate: EditWorkTitleTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func titleTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.titleTextField.text else {
            return
        }
        self.editWorkTitleTableViewCellDelegate?.titleTextFieldChanged(text)
    }
}
