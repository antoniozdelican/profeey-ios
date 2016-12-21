//
//  WorkExperienceTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import TTTAttributedLabel

@objc protocol WorkExperienceTableViewCellDelegate {
    @objc optional func workExperienceExpandButtonTapped(_ cell: WorkExperienceTableViewCell)
    func workDescriptionLabelTapped(_ cell: WorkExperienceTableViewCell)
}

class WorkExperienceTableViewCell: UITableViewCell {

    @IBOutlet weak var workExperienceImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var timePeriodLabel: UILabel!
    @IBOutlet weak var workDescriptionLabel: TTTAttributedLabel!
    // Used in ProfileVc for custom separator.
    @IBOutlet weak var separatorViewLeftConstraint: NSLayoutConstraint?
    
    var workExperienceTableViewCellDelegate: WorkExperienceTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.workDescriptionLabelTapped(_:)))
        self.workDescriptionLabel.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    // Used in ExperiencesVc.
    @IBAction func expandButtonTapped(_ sender: AnyObject) {
        self.workExperienceTableViewCellDelegate?.workExperienceExpandButtonTapped?(self)
    }
    
    func workDescriptionLabelTapped(_ sender: AnyObject) {
        self.workExperienceTableViewCellDelegate?.workDescriptionLabelTapped(self)
    }
    
    func truncate() {
        let attributedTruncationToken = NSMutableAttributedString()
        let ellipsis = NSAttributedString(string: "...", attributes: [NSFontAttributeName: self.workDescriptionLabel.font, NSForegroundColorAttributeName: Colors.black])
        let more = NSAttributedString(string: " more", attributes: [NSFontAttributeName: self.workDescriptionLabel.font, NSForegroundColorAttributeName: Colors.grey])
        attributedTruncationToken.append(ellipsis)
        attributedTruncationToken.append(more)
        self.workDescriptionLabel.attributedTruncationToken = attributedTruncationToken
        self.workDescriptionLabel.numberOfLines = 3
    }
    
    func untruncate() {
        self.workDescriptionLabel.attributedTruncationToken = nil
        self.workDescriptionLabel.numberOfLines = 0
    }
}
