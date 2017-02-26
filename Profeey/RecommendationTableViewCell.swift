//
//  RecommendationTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import TTTAttributedLabel

protocol RecommendationTableViewCellDelegate: class {
    func userTapped(_ cell: RecommendationTableViewCell)
    func recommendationTextLabelTapped(_ cell: RecommendationTableViewCell)
    func moreButtonTapped(_ cell: RecommendationTableViewCell)
}

class RecommendationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var recommendationTextLabel: TTTAttributedLabel!
    @IBOutlet weak var preferredUsernameCreatedLabel: UILabel!
    
    weak var recommendationTableViewCellDelegate: RecommendationTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        
        self.profilePicImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.profilePicImageViewTapped(_:))))
        self.recommendationTextLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.recommendationTextLabelTapped(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Tappers
    
    func profilePicImageViewTapped(_ sender: AnyObject) {
        self.recommendationTableViewCellDelegate?.userTapped(self)
    }
    
    func recommendationTextLabelTapped(_ sender: AnyObject) {
        self.recommendationTableViewCellDelegate?.recommendationTextLabelTapped(self)
    }
    
    // MARK: IBActions
    
    @IBAction func moreButtonTapped(_ sender: AnyObject) {
        self.recommendationTableViewCellDelegate?.moreButtonTapped(self)
    }
    
    // MARK: Helpers
    
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
