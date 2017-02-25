//
//  PostReportTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

class PostReportTableViewCell: UITableViewCell {
    
    @IBOutlet weak var confirmationMessageLabel: UILabel!
    @IBOutlet weak var thanksMessageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.confirmationMessageLabel.text = "This post has been reported"
        self.thanksMessageLabel.text = "Thanks for helping us making Profeey a safer place for everybody."
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
