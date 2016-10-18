//
//  EditEducationSchoolTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditEducationSchoolTableViewCellDelegate {
    func schoolTextFieldChanged(_ text: String)
}

class EditEducationSchoolTableViewCell: UITableViewCell {
    
    @IBOutlet weak var schoolTextField: UITextField!
    
    var editEducationSchoolTableViewCellDelegate: EditEducationSchoolTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func schoolTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.schoolTextField.text else {
            return
        }
        self.editEducationSchoolTableViewCellDelegate?.schoolTextFieldChanged(text)
    }
}
