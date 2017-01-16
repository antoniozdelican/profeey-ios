//
//  EditLastNameTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditLastNameTableViewCellDelegate: class {
    func lastNameTextFieldChanged(_ text: String)
}

class EditLastNameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    weak var editLastNameTableViewCellDelegate: EditLastNameTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func lastNameTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.lastNameTextField.text else {
            return
        }
        self.editLastNameTableViewCellDelegate?.lastNameTextFieldChanged(text)
    }
}
