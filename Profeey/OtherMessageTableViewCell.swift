//
//  OtherMessageTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

protocol OtherMessageTableViewCellDelegate {
    func profilePicImageViewTapped(_ cell:OtherMessageTableViewCell)
}

class OtherMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var messageTextContainerView: UIView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabelHeightConstraint: NSLayoutConstraint!
    
    fileprivate var timeLabelTopConstraintConstant: CGFloat = 0.0
    fileprivate var timeLabelBottomConstraintConstant: CGFloat = 0.0
    fileprivate var timeLabelHeightConstraintConstant: CGFloat = 0.0
    
    var otherMessageTableViewCellDelegate: OtherMessageTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        self.profilePicImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.profilePicImageViewTapped(_:))))
        
        self.messageTextContainerView.layer.cornerRadius = 4.0
        self.messageTextContainerView.clipsToBounds = true
        
        self.timeLabelTopConstraintConstant = self.timeLabelTopConstraint.constant
        self.timeLabelBottomConstraintConstant = self.timeLabelBottomConstraint.constant
        self.timeLabelHeightConstraintConstant = self.timeLabelHeightConstraint.constant
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Helpers
    
    func hideProfilePicAndTimeLabel() {
        self.profilePicImageView.isHidden = true
        self.timeLabel.isHidden = true
        self.timeLabelTopConstraint.constant = 0.0
        self.timeLabelBottomConstraint.constant = 1.0
        self.timeLabelHeightConstraint.constant = 0.0
    }
    
    func showProfilePicAndTimeLabel() {
        // Return to initial.
        self.profilePicImageView.isHidden = false
        self.timeLabel.isHidden = false
        self.timeLabelTopConstraint.constant =  self.timeLabelTopConstraintConstant
        self.timeLabelBottomConstraint.constant = self.timeLabelBottomConstraintConstant
        self.timeLabelHeightConstraint.constant = self.timeLabelHeightConstraintConstant
    }
    
    // MARK: Tappers
    
    func profilePicImageViewTapped(_ sender: AnyObject) {
        self.otherMessageTableViewCellDelegate?.profilePicImageViewTapped(self)
    }
    
}
