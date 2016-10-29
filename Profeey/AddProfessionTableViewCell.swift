//
//  AddProfessionTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol AddProfessionTableViewCellDelegate {
    func addProfessionTextFieldChanged(_ text: String)
}

class AddProfessionTableViewCell: UITableViewCell {

    @IBOutlet weak var addProfessionTextField: UITextField!
    
    var addProfessionTableViewCellDelegate: AddProfessionTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func addProfessionTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.addProfessionTextField.text else {
            return
        }
        self.addProfessionTableViewCellDelegate?.addProfessionTextFieldChanged(text)
    }
}
