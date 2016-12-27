//
//  EditLocationTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditLocationTableViewCellDelegate {
    func clearLocationButtonTapped()
}

class EditLocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var clearLocationButton: UIButton!
    
    var editLocationTableViewCellDelegate: EditLocationTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions

    @IBAction func clearLocationButtonTapped(_ sender: Any) {
        self.editLocationTableViewCellDelegate?.clearLocationButtonTapped()
    }
}
