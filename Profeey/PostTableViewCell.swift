//
//  PostTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet private weak var categoriesCollectionView: UICollectionView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var collectionViewOffset: CGFloat {
        get {
            return self.categoriesCollectionView.contentOffset.x
        }
        
        set {
            self.categoriesCollectionView.contentOffset.x = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        self.postImageView.layer.cornerRadius = 4.0
        self.postImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
        
        self.categoriesCollectionView.delegate = dataSourceDelegate
        self.categoriesCollectionView.dataSource = dataSourceDelegate
        self.categoriesCollectionView.tag = row
        self.categoriesCollectionView.reloadData()
    }

}
