//
//  ProfessionsCollectionViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ItemsRemoveDelegate {
    func removeAtIndex(itemIndex: Int)
}

class ItemsCollectionViewController: UICollectionViewController {
    
    // Constants for cell size.
    let ITEM_LABEL_HEIGHT: CGFloat = 20.0
    let ITEM_FONT: UIFont = UIFont.systemFontOfSize(16.0)
    let TOP_INSET: CGFloat = 4.0
    let LEFT_INSET: CGFloat = 8.0
    let RIGHT_INSET: CGFloat = 8.0
    
    var items: [String]?
    var itemsArray: [String] = []
    var itemsRemoveDelegate: ItemsRemoveDelegate?
    var itemType: ItemType?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let items = self.items {
            self.itemsArray = items
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
        return self.itemsArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellItem", forIndexPath: indexPath) as! ItemCollectionViewCell
        cell.itemLabel.text = self.itemsArray[indexPath.row]
        if self.itemType == ItemType.User {
            cell.configureGreen()
        } else {
            cell.configureBlue()
        }
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Inform delegate.
        self.itemsRemoveDelegate?.removeAtIndex(indexPath.row)
        self.itemsArray.removeAtIndex(indexPath.row)
        collectionView.performBatchUpdates({
            collectionView.deleteItemsAtIndexPaths([indexPath])
            }, completion: {completed in
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        })
    }

}

extension ItemsCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let item = self.itemsArray[indexPath.row]
        // Calculations.
        let labelRect = NSString(string: item).boundingRectWithSize(CGSize(width: CGFloat(MAXFLOAT), height: self.ITEM_LABEL_HEIGHT), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self.ITEM_FONT], context: nil)
        let cellWidth = ceil(labelRect.size.width) + self.LEFT_INSET + self.RIGHT_INSET
        let cellHeight = ceil(labelRect.size.height) + 2 * self.TOP_INSET
        
        return CGSizeMake(cellWidth, cellHeight)
    }
}

extension ItemsCollectionViewController: ItemsAddDelegate {
    
    // Insert selected item.
    func add(item: String) {
        guard !self.itemsArray.contains(item) else {
            return
        }
        self.itemsArray.insert(item, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.collectionView?.performBatchUpdates({
            self.collectionView?.insertItemsAtIndexPaths([indexPath])
            }, completion: nil)
    }
}
