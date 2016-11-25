//
//  PostInfoTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class PostInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var captionLabel: TTTAttributedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func truncate() {
        let attributedTruncationToken = NSMutableAttributedString()
        let ellipsis = NSAttributedString(string: "...", attributes: [NSFontAttributeName: self.captionLabel.font, NSForegroundColorAttributeName: Colors.black])
        let more = NSAttributedString(string: " more", attributes: [NSFontAttributeName: self.captionLabel.font, NSForegroundColorAttributeName: Colors.grey])
        attributedTruncationToken.append(ellipsis)
        attributedTruncationToken.append(more)
        self.captionLabel.attributedTruncationToken = attributedTruncationToken
        self.captionLabel.numberOfLines = 3
    }
    
    func untruncate() {
        self.captionLabel.attributedTruncationToken = nil
        self.captionLabel.numberOfLines = 0
    }

}
