//
//  EditPostCategoryTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 04/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditPostCategoryTableViewCellDelegate: class {
    func clearCategoryButtonTapped()
}

class EditPostCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var clearCategoryButton: UIButton!
    
    weak var editPostCategoryTableViewCellDelegate: EditPostCategoryTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func clearCategoryButtonTapped(_ sender: Any) {
        self.editPostCategoryTableViewCellDelegate?.clearCategoryButtonTapped()
    }

}
