//
//  AddCategoryTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol AddCategoryTableViewCellDelegate {
    func addCategoryTextFieldChanged(_ text: String)
}

class AddCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addCategoryTextField: UITextField!
    
    var addCategoryTableViewCellDelegate: AddCategoryTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func addCategoryTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.addCategoryTextField.text else {
            return
        }
        self.addCategoryTableViewCellDelegate?.addCategoryTextFieldChanged(text)
    }
}
