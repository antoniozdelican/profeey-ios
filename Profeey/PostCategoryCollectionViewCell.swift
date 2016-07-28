//
//  PostCategoryCollectionViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class PostCategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 4.0
        self.layer.borderColor = Colors.blue.CGColor
        self.categoryLabel.textColor = Colors.blue
        // Selected.
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Colors.blue.colorWithAlphaComponent(0.2)
        self.selectedBackgroundView = selectedBackgroundView
    }
    
}
