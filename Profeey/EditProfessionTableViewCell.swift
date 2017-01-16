//
//  EditProfessionTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditProfessionTableViewCellDelegate: class {
    func clearProfessionButtonTapped()
}

class EditProfessionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var clearProfessionButton: UIButton!
    
    weak var editProfessionTableViewCellDelegate: EditProfessionTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func clearProfessionButtonTapped(_ sender: Any) {
        self.editProfessionTableViewCellDelegate?.clearProfessionButtonTapped()
    }

}
