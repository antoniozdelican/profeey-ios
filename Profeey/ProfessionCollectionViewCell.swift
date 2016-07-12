//
//  ProfessionCollectionViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ProfessionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var professionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Normal.
        self.layer.borderWidth = 1.0
        self.layer.borderColor = Colors.blue.CGColor
        self.layer.cornerRadius = 4.0
        // Selected.
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Colors.blue.colorWithAlphaComponent(0.2)
        self.selectedBackgroundView = selectedBackgroundView
    }
    
}
