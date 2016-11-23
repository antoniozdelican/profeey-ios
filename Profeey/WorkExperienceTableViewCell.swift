//
//  WorkExperienceTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol WorkExperienceTableViewCellDelegate {
    func workExperienceExpandButtonTapped(_ button: UIButton)
}

class WorkExperienceTableViewCell: UITableViewCell {

    @IBOutlet weak var workExperienceImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var timePeriodLabel: UILabel!
    @IBOutlet weak var workDescriptionLabel: UILabel!
    // Used in ProfileVc for custom separator.
    @IBOutlet weak var separatorViewLeftConstraint: NSLayoutConstraint?
    
    
    var workExperienceTableViewCellDelegate: WorkExperienceTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.workExperienceImageView.layer.cornerRadius = 4.0
        self.workExperienceImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func expandButtonTapped(_ sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        self.workExperienceTableViewCellDelegate?.workExperienceExpandButtonTapped(button)
    }
    

}
