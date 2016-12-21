//
//  EducationTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import TTTAttributedLabel

@objc protocol EducationTableViewCellDelegate {
    @objc optional func educationExpandButtonTapped(_ cell: EducationTableViewCell)
    func educationDescriptionLabelTapped(_ cell: EducationTableViewCell)
}

class EducationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var educationImageView: UIImageView!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var fieldOfStudyLabel: UILabel!
    @IBOutlet weak var timePeriodLabel: UILabel!
    @IBOutlet weak var educationDescriptionLabel: TTTAttributedLabel!
    // Used in ProfileVc for custom separator.
    @IBOutlet weak var separatorViewLeftConstraint: NSLayoutConstraint?
    
    var educationTableViewCellDelegate: EducationTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.educationDescriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.educationDescriptionLabelTapped(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    // Used in ExperiencesVc.
    @IBAction func expandButtonTapped(_ sender: AnyObject) {
        self.educationTableViewCellDelegate?.educationExpandButtonTapped?(self)
    }
    
    // MARK: Tappers
    
    func educationDescriptionLabelTapped(_ sender: AnyObject) {
        self.educationTableViewCellDelegate?.educationDescriptionLabelTapped(self)
    }
    
    // MARK: Helpers
    
    func truncate() {
        let attributedTruncationToken = NSMutableAttributedString()
        let ellipsis = NSAttributedString(string: "...", attributes: [NSFontAttributeName: self.educationDescriptionLabel.font, NSForegroundColorAttributeName: Colors.black])
        let more = NSAttributedString(string: " more", attributes: [NSFontAttributeName: self.educationDescriptionLabel.font, NSForegroundColorAttributeName: Colors.grey])
        attributedTruncationToken.append(ellipsis)
        attributedTruncationToken.append(more)
        self.educationDescriptionLabel.attributedTruncationToken = attributedTruncationToken
        self.educationDescriptionLabel.numberOfLines = 3
    }
    
    func untruncate() {
        self.educationDescriptionLabel.attributedTruncationToken = nil
        self.educationDescriptionLabel.numberOfLines = 0
    }

}
