//
//  CommentTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import TTTAttributedLabel

protocol CommentTableViewCellDelegate: class {
    func userTapped(_ cell: CommentTableViewCell)
    func commentTextLabelTapped(_ cell: CommentTableViewCell)
    func moreButtonTapped(_ cell: CommentTableViewCell)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var commentTextLabel: TTTAttributedLabel!
    @IBOutlet weak var preferredUsernameCreatedLabel: UILabel!
    
    weak var commentTableViewCellDelegate: CommentTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        
        self.profilePicImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.profilePicImageViewTapped(_:))))
        self.commentTextLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.commentTextLabelTapped(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Tappers
    
    func profilePicImageViewTapped(_ sender: AnyObject) {
        self.commentTableViewCellDelegate?.userTapped(self)
    }
    
    func commentTextLabelTapped(_ sender: AnyObject) {
        self.commentTableViewCellDelegate?.commentTextLabelTapped(self)
    }
    
    // MARK: IBActions
    
    @IBAction func moreButtonTapped(_ sender: AnyObject) {
        self.commentTableViewCellDelegate?.moreButtonTapped(self)
    }
    
    // MARK: Helpers
    
    func truncate() {
        let attributedTruncationToken = NSMutableAttributedString()
        let ellipsis = NSAttributedString(string: "...", attributes: [NSFontAttributeName: self.commentTextLabel.font, NSForegroundColorAttributeName: Colors.black])
        let more = NSAttributedString(string: " more", attributes: [NSFontAttributeName: self.commentTextLabel.font, NSForegroundColorAttributeName: Colors.grey])
        attributedTruncationToken.append(ellipsis)
        attributedTruncationToken.append(more)
        self.commentTextLabel.attributedTruncationToken = attributedTruncationToken
        self.commentTextLabel.numberOfLines = 3
    }
    
    func untruncate() {
        self.commentTextLabel.attributedTruncationToken = nil
        self.commentTextLabel.numberOfLines = 0
    }
}
