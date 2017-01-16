//
//  EditWebsiteTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 27/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditWebsiteTableViewCellDelegate: class {
    func websiteTextFieldChanged(_ text: String)
}

class EditWebsiteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var websiteTextField: UITextField!
    
    weak var editWebsiteTableViewCellDelegate: EditWebsiteTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func websiteTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.websiteTextField.text else {
            return
        }
        self.editWebsiteTableViewCellDelegate?.websiteTextFieldChanged(text)
    }

}
