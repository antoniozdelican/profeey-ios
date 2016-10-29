//
//  EditFirstNameTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditFirstNameTableViewCellDelegate {
    func firstNameTextFieldChanged(_ text: String)
}

class EditFirstNameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    var editFirstNameTableViewCellDelegate: EditFirstNameTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func firstNameTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.firstNameTextField.text else {
            return
        }
        self.editFirstNameTableViewCellDelegate?.firstNameTextFieldChanged(text)
    }
}
