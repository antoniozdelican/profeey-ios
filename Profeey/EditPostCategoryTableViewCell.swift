//
//  EditPostCategoryTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 04/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditPostCategoryTableViewCellDelegate {
    func removeButtonTapped()
}

class EditPostCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    var editPostCategoryTableViewCellDelegate: EditPostCategoryTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func removeButtonTapped(_ sender: AnyObject) {
        self.editPostCategoryTableViewCellDelegate?.removeButtonTapped()
    }
    
    
    func categoryRemoved() {
        self.categoryImageView.image = UIImage(named: "ic_skills")
        self.categoryLabel.textColor = Colors.disabled
        self.categoryLabel.text = "Add Skill"
        self.removeButton.isHidden = true
        
    }
    
    func categoryAdded(categoryName: String) {
        self.categoryImageView.image = UIImage(named: "ic_skills_active")
        self.categoryLabel.textColor = Colors.black
        self.categoryLabel.text = categoryName
        self.removeButton.isHidden = false
    }

}
