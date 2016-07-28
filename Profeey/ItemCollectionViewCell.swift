//
//  ProfessionCollectionViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 4.0
    }
    
    func configureBlue() {
        self.layer.borderColor = Colors.blue.CGColor
        self.itemLabel.textColor = Colors.blue
        // Selected.
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Colors.blue.colorWithAlphaComponent(0.2)
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    func configureGreen() {
        self.layer.borderColor = Colors.green.CGColor
        self.itemLabel.textColor = Colors.green
        // Selected.
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Colors.green.colorWithAlphaComponent(0.2)
        self.selectedBackgroundView = selectedBackgroundView
    }
    
}
