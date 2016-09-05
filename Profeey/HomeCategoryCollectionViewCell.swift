//
//  HomeCategoryCollectionViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 03/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class HomeCategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
