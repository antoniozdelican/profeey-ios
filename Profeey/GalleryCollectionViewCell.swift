//
//  GalleryCollectionViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView?
    @IBOutlet weak var overlayView: UIView!
    
    var representedAssetIdentifier: NSString!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbnailImageView?.image = nil
    }
}
