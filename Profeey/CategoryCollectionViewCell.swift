//
//  CategoryCollectionViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 02/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 4.0
        self.layer.borderColor = Colors.blue.CGColor
        self.categoryNameLabel.textColor = Colors.blue
        // Selected.
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Colors.blue.colorWithAlphaComponent(0.2)
        self.selectedBackgroundView = selectedBackgroundView
    }
    
}
