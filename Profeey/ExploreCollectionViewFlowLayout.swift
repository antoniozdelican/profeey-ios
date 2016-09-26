//
//  ExploreCollectionViewFlowLayout.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ExploreCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func awakeFromNib() {
        self.itemSize = CGSizeMake(200.0, 200.0)
        self.minimumInteritemSpacing = 10.0
        self.minimumLineSpacing = 10.0
        self.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.sectionInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var offsetAdjustment = CGFloat.max
        let horizontalOffset = proposedContentOffset.x + 5
        let targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView!.bounds.width, self.collectionView!.bounds.height)
        let array = super.layoutAttributesForElementsInRect(targetRect)!
        
        for layoutAttributes in array {
            let itemOffset = layoutAttributes.frame.origin.x
            if abs(itemOffset - horizontalOffset) < abs(offsetAdjustment) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        }
        
        return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y)
    }
}
