//
//  OwnMessageTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

class OwnMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var messageTextContainerView: UIView!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var createdLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var createdLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var createdLabelHeightConstraint: NSLayoutConstraint!
    
    fileprivate var createdLabelTopConstraintConstant: CGFloat = 0.0
    fileprivate var createdLabelBottomConstraintConstant: CGFloat = 0.0
    fileprivate var createdLabelHeightConstraintConstant: CGFloat = 0.0

    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageTextContainerView.layer.cornerRadius = 4.0
        self.messageTextContainerView.clipsToBounds = true
        self.createdLabelTopConstraintConstant = self.createdLabelTopConstraint.constant
        self.createdLabelBottomConstraintConstant = self.createdLabelBottomConstraint.constant
        self.createdLabelHeightConstraintConstant = self.createdLabelHeightConstraint.constant
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Helpers
    
    func hideCreatedLabel() {
        self.createdLabel.isHidden = true
        self.createdLabelTopConstraint.constant = 0.0
        self.createdLabelBottomConstraint.constant = 1.0
        self.createdLabelHeightConstraint.constant = 0.0
    }
    
    func showCreatedLabel() {
        // Return to initial.
        self.createdLabel.isHidden = false
        self.createdLabelTopConstraint.constant =  self.createdLabelTopConstraintConstant
        self.createdLabelBottomConstraint.constant = self.createdLabelBottomConstraintConstant
        self.createdLabelHeightConstraint.constant = self.createdLabelHeightConstraintConstant
    }

}
