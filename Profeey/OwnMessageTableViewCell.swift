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
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabelHeightConstraint: NSLayoutConstraint!
    
    fileprivate var timeLabelTopConstraintConstant: CGFloat = 0.0
    fileprivate var timeLabelBottomConstraintConstant: CGFloat = 0.0
    fileprivate var timeLabelHeightConstraintConstant: CGFloat = 0.0

    override func awakeFromNib() {
        super.awakeFromNib()
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
    
    func hideTimeLabel() {
        self.timeLabel.isHidden = true
        self.timeLabelTopConstraint.constant = 0.0
        self.timeLabelBottomConstraint.constant = 1.0
        self.timeLabelHeightConstraint.constant = 0.0
    }
    
    func showTimeLabel() {
        // Return to initial.
        self.timeLabel.isHidden = false
        self.timeLabelTopConstraint.constant =  self.timeLabelTopConstraintConstant
        self.timeLabelBottomConstraint.constant = self.timeLabelBottomConstraintConstant
        self.timeLabelHeightConstraint.constant = self.timeLabelHeightConstraintConstant
    }

}
