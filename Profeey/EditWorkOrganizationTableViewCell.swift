//
//  EditWorkOrganizationTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditWorkOrganizationTableViewCellDelegate: class {
    func organizationTextFieldChanged(_ text: String)
}

class EditWorkOrganizationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var organizationTextField: UITextField!
    
    weak var editWorkOrganizationTableViewCellDelegate: EditWorkOrganizationTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func organizationTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.organizationTextField.text else {
            return
        }
        self.editWorkOrganizationTableViewCellDelegate?.organizationTextFieldChanged(text)
    }
}
