//
//  EducationTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EducationTableViewCellDelegate {
    func educationExpandButtonTapped(_ button: UIButton)
}

class EducationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var educationImageView: UIImageView!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var fieldOfStudyLabel: UILabel!
    @IBOutlet weak var timePeriodLabel: UILabel!
    @IBOutlet weak var educationDescriptionLabel: UILabel!
    // Used in ProfileVc for custom separator.
    @IBOutlet weak var separatorViewLeftConstraint: NSLayoutConstraint?
    
    
    var educationTableViewCellDelegate: EducationTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.educationImageView.layer.cornerRadius = 4.0
        self.educationImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func expandButtonTapped(_ sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        self.educationTableViewCellDelegate?.educationExpandButtonTapped(button)
    }

}
