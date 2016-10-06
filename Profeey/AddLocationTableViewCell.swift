//
//  AddLocationTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 27/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class AddLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
