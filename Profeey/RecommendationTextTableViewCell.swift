//
//  RecommendationTextTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class RecommendationTextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recommendationTextLabel: TTTAttributedLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func truncate() {
        let attributedTruncationToken = NSMutableAttributedString()
        let ellipsis = NSAttributedString(string: "...", attributes: [NSFontAttributeName: self.recommendationTextLabel.font, NSForegroundColorAttributeName: Colors.black])
        let more = NSAttributedString(string: " more", attributes: [NSFontAttributeName: self.recommendationTextLabel.font, NSForegroundColorAttributeName: Colors.grey])
        attributedTruncationToken.append(ellipsis)
        attributedTruncationToken.append(more)
        self.recommendationTextLabel.attributedTruncationToken = attributedTruncationToken
        self.recommendationTextLabel.numberOfLines = 3
    }
    
    func untruncate() {
        self.recommendationTextLabel.attributedTruncationToken = nil
        self.recommendationTextLabel.numberOfLines = 0
    }

}
