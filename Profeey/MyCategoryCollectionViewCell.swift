//
//  MyCategoryCollectionViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class MyCategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
