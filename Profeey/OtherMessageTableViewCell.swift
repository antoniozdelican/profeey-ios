//
//  OtherMessageTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

protocol OtherMessageTableViewCellDelegate: class {
    func profilePicImageViewTapped(_ cell:OtherMessageTableViewCell)
    func otherMessageTapped(_ cell: OtherMessageTableViewCell)
}

class OtherMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var messageTextContainerView: UIView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var createdLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var createdLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var createdLabelHeightConstraint: NSLayoutConstraint!
    
    fileprivate var createdLabelTopConstraintConstant: CGFloat = 0.0
    fileprivate var createdLabelBottomConstraintConstant: CGFloat = 0.0
    fileprivate var createdLabelHeightConstraintConstant: CGFloat = 0.0
    
    weak var otherMessageTableViewCellDelegate: OtherMessageTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        self.profilePicImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.profilePicImageViewTapped(_:))))
        
        self.messageTextContainerView.layer.cornerRadius = 4.0
        self.messageTextContainerView.clipsToBounds = true
        
        self.createdLabelTopConstraintConstant = self.createdLabelTopConstraint.constant
        self.createdLabelBottomConstraintConstant = self.createdLabelBottomConstraint.constant
        self.createdLabelHeightConstraintConstant = self.createdLabelHeightConstraint.constant
        
        // Long gesture for delete/report message.
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.otherMessageTextContainerViewTapped(_:)))
        gestureRecognizer.minimumPressDuration = 0.2
        self.messageTextContainerView.addGestureRecognizer(gestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Helpers
    
    func showCreatedLabel() {
        self.createdLabel.isHidden = false
        self.createdLabelTopConstraint.constant =  self.createdLabelTopConstraintConstant
        self.createdLabelBottomConstraint.constant = self.createdLabelBottomConstraintConstant
        self.createdLabelHeightConstraint.constant = self.createdLabelHeightConstraintConstant
    }
    
    func hideCreatedLabel() {
        self.createdLabel.isHidden = true
        self.createdLabelTopConstraint.constant = 0.0
        self.createdLabelBottomConstraint.constant = 1.0
        self.createdLabelHeightConstraint.constant = 0.0
    }
    
    func showProfilePicImageView() {
        self.profilePicImageView.isHidden = false
    }
    
    func hideProfilePicImageView() {
        self.profilePicImageView.isHidden = true
    }
    
    // MARK: Tappers
    
    func profilePicImageViewTapped(_ sender: AnyObject) {
        self.otherMessageTableViewCellDelegate?.profilePicImageViewTapped(self)
    }
    
    func otherMessageTextContainerViewTapped(_ sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.began {
            self.otherMessageTableViewCellDelegate?.otherMessageTapped(self)
        }
    }
    
}
