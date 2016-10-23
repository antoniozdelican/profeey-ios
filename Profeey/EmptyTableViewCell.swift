//
//  EmptyTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EmptyTableViewCellDelegate {
    func addButtonTapped()
}

class EmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var addButton: UIButton?
    
    var emptyTableViewCellDelegate: EmptyTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addButton?.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        self.emptyTableViewCellDelegate?.addButtonTapped()
    }
}
