//
//  ProfessionsCollectionViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ProfessionsRemoveDelegate {
    func removeAtIndex(professionIndex: Int)
}

class ProfessionsCollectionViewController: UICollectionViewController {
    
    // Constants for cell size.
    let PROFESSION_LABEL_HEIGHT: CGFloat = 20.0
    let PROFESSION_FONT: UIFont = UIFont.systemFontOfSize(16.0)
    let TOP_INSET: CGFloat = 4.0
    let LEFT_INSET: CGFloat = 8.0
    let RIGHT_INSET: CGFloat = 8.0
    
    var professions: [String] = []
    var professionsRemoveDelegate: ProfessionsRemoveDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.professions.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellProfession", forIndexPath: indexPath) as! ProfessionCollectionViewCell
        cell.professionLabel.text = self.professions[indexPath.row]
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Inform delegate.
        self.professionsRemoveDelegate?.removeAtIndex(indexPath.row)
        self.professions.removeAtIndex(indexPath.row)
        collectionView.performBatchUpdates({
            collectionView.deleteItemsAtIndexPaths([indexPath])
            }, completion: {completed in
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        })
    }

}

extension ProfessionsCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let item = self.professions[indexPath.row]
        // Calculations.
        let labelRect = NSString(string: item).boundingRectWithSize(CGSize(width: CGFloat(MAXFLOAT), height: self.PROFESSION_LABEL_HEIGHT), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self.PROFESSION_FONT], context: nil)
        let cellWidth = ceil(labelRect.size.width) + self.LEFT_INSET + self.RIGHT_INSET
        let cellHeight = ceil(labelRect.size.height) + 2 * self.TOP_INSET
        
        return CGSizeMake(cellWidth, cellHeight)
    }
}

extension ProfessionsCollectionViewController: ProfessionsAddDelegate {
    
    // Insert selected item.
    func addProfession(profession: String) {
        guard !self.professions.contains(profession) else {
            return
        }
        self.professions.insert(profession, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.collectionView?.performBatchUpdates({
            self.collectionView?.insertItemsAtIndexPaths([indexPath])
            }, completion: nil)
    }
}
