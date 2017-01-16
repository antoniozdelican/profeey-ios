//
//  EditEducationFieldOfStudyTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditEducationFieldOfStudyTableViewCellDelegate: class {
    func fieldOfStudyTextFieldChanged(_ text: String)
}

class EditEducationFieldOfStudyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fieldOfStudyTextField: UITextField!
    
    weak var editEducationFieldOfStudyTableViewCellDelegate: EditEducationFieldOfStudyTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: IBActions
    
    @IBAction func fieldOfStudyTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.fieldOfStudyTextField.text else {
            return
        }
        self.editEducationFieldOfStudyTableViewCellDelegate?.fieldOfStudyTextFieldChanged(text)
    }
}
