//
//  CategoriesCollectionViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 02/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol CategoriesCollectionViewControllerDelegate {
    func didSelectItemAtIndexPath(index: Int)
}

class CategoriesCollectionViewController: UICollectionViewController {
    
    // Constants for cell size.
    private let CATEGORY_LABEL_HEIGHT: CGFloat = 20.0
    private let CATEGORY_FONT: UIFont = UIFont.systemFontOfSize(16.0)
    private let TOP_INSET: CGFloat = 4.0
    private let LEFT_INSET: CGFloat = 8.0
    private let RIGHT_INSET: CGFloat = 8.0
    
    var oldCategories: [String]?
    private var categories: [String] = []
    var categoriesCollectionViewControllerDelegate: CategoriesCollectionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let oldCategories = self.oldCategories {
            self.categories = oldCategories
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellCategory", forIndexPath: indexPath) as! CategoryCollectionViewCell
        cell.categoryNameLabel.text = self.categories[indexPath.row]
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Inform delegate.
        self.categoriesCollectionViewControllerDelegate?.didSelectItemAtIndexPath(indexPath.row)
        self.categories.removeAtIndex(indexPath.row)
        collectionView.performBatchUpdates({
            collectionView.deleteItemsAtIndexPaths([indexPath])
            }, completion: {completed in
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        })
    }
}

extension CategoriesCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let category = self.categories[indexPath.row]
        // Calculations.
        let labelRect = NSString(string: category).boundingRectWithSize(CGSize(width: CGFloat(MAXFLOAT), height: self.CATEGORY_LABEL_HEIGHT), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self.CATEGORY_FONT], context: nil)
        let cellWidth = ceil(labelRect.size.width) + self.LEFT_INSET + self.RIGHT_INSET
        let cellHeight = ceil(labelRect.size.height) + 2 * self.TOP_INSET
        return CGSizeMake(cellWidth, cellHeight)
    }
}

extension CategoriesCollectionViewController: CategoriesAddDelegate {
    
    func addCategory(category: String) {
        guard !self.categories.contains(category) else {
            return
        }
        self.categories.insert(category, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.collectionView?.performBatchUpdates({
            self.collectionView?.insertItemsAtIndexPaths([indexPath])
            }, completion: nil)
    }
}
