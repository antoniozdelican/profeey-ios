//
//  ExperiencesHeaderTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

protocol ExperiencesHeaderTableViewCellDelegate: class {
    func editButtonTapped()
}

class ExperiencesHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var editButton: UIButton?
    
    weak var experiencesHeaderTableViewCellDelegate: ExperiencesHeaderTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func editButtonTapped(_ sender: AnyObject) {
        self.experiencesHeaderTableViewCellDelegate?.editButtonTapped()
    }

}
