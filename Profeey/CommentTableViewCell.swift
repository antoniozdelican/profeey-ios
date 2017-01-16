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
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var preferredUsernameLabel: UILabel!
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var commentTextLabel: TTTAttributedLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameStackView: UIStackView!
    
    weak var commentTableViewCellDelegate: CommentTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        
        self.profilePicImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.profilePicImageViewTapped(_:))))
        self.nameStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nameStackViewTapped(_:))))
        self.commentTextLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.commentTextLabelTapped(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Tappers
    
    func profilePicImageViewTapped(_ sender: AnyObject) {
        self.commentTableViewCellDelegate?.userTapped(self)
    }
    
    func nameStackViewTapped(_ sender: AnyObject) {
        self.commentTableViewCellDelegate?.userTapped(self)
    }
    
    func commentTextLabelTapped(_ sender: AnyObject) {
        self.commentTableViewCellDelegate?.commentTextLabelTapped(self)
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
