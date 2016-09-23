//
//  GalleryCollectionViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import PhotosUI

protocol GalleryCollectionViewDelegate {
    func updateAlbumName(name: String?)
}

class GalleryCollectionViewController: UICollectionViewController {
    
    var galleryCollectionViewDelegate: GalleryCollectionViewDelegate?
    var imageManager: PHCachingImageManager?
    var thumbnailSize: CGSize!
    var album :PHFetchResult?
    // Used for checking if PHCachingImageManager should start caching
    var previousPreheatRect: CGRect!
    private var ITEM_INSET: CGFloat = 1.0
    var isProfilePic: Bool = false
    var profilePicUnwind: ProfilePicUnwind?

    override func viewDidLoad() {
        super.viewDidLoad()        
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()
        
        if self.album == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            self.album = PHAsset.fetchAssetsWithOptions(allPhotosOptions)
            self.galleryCollectionViewDelegate?.updateAlbumName("All Photos")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Begin caching assets in and around collection view's visible rect
        self.updateCachedAssets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? AlbumsTableViewController {
            childViewController.albumsDelegate = self
        }
        if let navigationController = segue.destinationViewController as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? PreviewViewController,
            let indexPath = sender as? NSIndexPath,
            let asset = self.album?[indexPath.item] as? PHAsset {
            childViewController.asset = asset
            childViewController.isPhoto = false
            childViewController.isProfilePic = self.isProfilePic
            childViewController.profilePicUnwind = self.profilePicUnwind
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let album = self.album {
            return album.count
        } else {
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellGallery", forIndexPath: indexPath) as! GalleryCollectionViewCell
        let asset = self.album?[indexPath.item] as! PHAsset
        cell.representedAssetIdentifier = asset.localIdentifier;
        
        // Request an image for the asset from the PHCachingImageManager
        self.imageManager?.requestImageForAsset(
            asset,
            targetSize: thumbnailSize!,
            contentMode: PHImageContentMode.AspectFill,
            options: nil,
            resultHandler: {result, info in
                // Set the cell's thumbnail image if it's still showing the same asset
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    cell.thumbnailImageView.image = result
                }
        })
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueToPreviewVc", sender: indexPath)
    }
    
    //MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        // Update cached assets for the new visible area
        self.updateCachedAssets()
    }
    
    @IBAction func unwindToGalleryCollectionViewController(segue: UIStoryboardSegue) {
    }
    
    // MARK: Asset Caching
    
    private func resetCachedAssets() {
        self.imageManager?.stopCachingImagesForAllAssets()
        self.previousPreheatRect = CGRectZero;
    }
    
    private func updateCachedAssets() {
        guard self.isViewLoaded() && self.view.window != nil else {
            return
        }
        
        guard let galleryCollectionView = self.collectionView else {
            return
        }
        
        // The preheat window is twice the height of the visible rect
        var preheatRect = galleryCollectionView.bounds
        preheatRect = CGRectInset(preheatRect, 0.0, -0.5 * CGRectGetHeight(preheatRect))
        
        // Check if the collection view is showing an area that is significantly different to the last preheated area
        let delta = abs(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect))
        if delta > CGRectGetHeight(galleryCollectionView.bounds) / 3.0 {
            
            // Compute the assets to start caching and to stop caching.
            var addedIndexPaths: [NSIndexPath] = []
            var removedIndexPaths: [NSIndexPath] = []
            
            self.computeDifferenceBetweenRect(
                previousPreheatRect,
                andRect: preheatRect,
                removedHandler: {removedRect in
                    let indexPaths = galleryCollectionView.indexPathsForElementsInRect(removedRect)
                    removedIndexPaths += indexPaths
                },
                addedHandler: {addedRect in
                    let indexPaths = galleryCollectionView.indexPathsForElementsInRect(addedRect)
                    addedIndexPaths += indexPaths
            })
            
            let assetsToStartCaching = self.assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching = self.assetsAtIndexPaths(removedIndexPaths)
            
            // Update the assets the PHCachingImageManager is caching
            self.imageManager?.startCachingImagesForAssets(
                assetsToStartCaching,
                targetSize: self.thumbnailSize,
                contentMode: PHImageContentMode.AspectFill,
                options: nil
            )
            self.imageManager?.stopCachingImagesForAssets(
                assetsToStopCaching,
                targetSize: self.thumbnailSize,
                contentMode: PHImageContentMode.AspectFill,
                options: nil
            )
            
            // Store the preheat rect to compare against in the future.
            self.previousPreheatRect = preheatRect
        }
    }
    
    private func computeDifferenceBetweenRect(oldRect: CGRect, andRect newRect: CGRect, removedHandler: (CGRect)-> Void, addedHandler: (CGRect)-> Void) {
        if CGRectIntersectsRect(newRect, oldRect) {
            let oldMaxY = CGRectGetMaxY(oldRect)
            let oldMinY = CGRectGetMinY(oldRect)
            let newMaxY = CGRectGetMaxY(newRect)
            let newMinY = CGRectGetMinY(newRect)
            
            if newMaxY > oldMaxY {
                let rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
            
            if oldMinY > newMinY {
                let rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            
            if newMaxY < oldMaxY {
                let rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            
            if oldMinY < newMinY {
                let rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    private func assetsAtIndexPaths(indexPaths: [NSIndexPath]) -> [PHAsset] {
        var assets: [PHAsset] = []
        for indexPath in indexPaths {
            let asset = self.album?[indexPath.item] as! PHAsset
            assets.append(asset)
        }
        return assets
    }
}

extension GalleryCollectionViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(changeInstance: PHChange) {
        // Check if there are changes to the assets we are showing.
        guard let assetsFetchResults = self.album, collectionChanges = changeInstance.changeDetailsForFetchResult(assetsFetchResults) else {
            return
        }
        
        /*
         Change notifications may be made on a background queue. Re-dispatch to the
         main queue before acting on the change as we'll be updating the UI.
         */
        dispatch_async(dispatch_get_main_queue()) {
            // Get the new fetch result.
            self.album = collectionChanges.fetchResultAfterChanges
            
            let collectionView = self.collectionView!
            
            if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                // Reload the collection view if the incremental diffs are not available
                collectionView.reloadData()
                
            } else {
                /*
                 Tell the collection view to animate insertions and deletions if we
                 have incremental diffs.
                 */
                collectionView.performBatchUpdates({
                    if let removedIndexes = collectionChanges.removedIndexes
                        where removedIndexes.count > 0 {
                        collectionView.deleteItemsAtIndexPaths(removedIndexes.indexPathsFromIndexesWithSection(0))
                    }
                    
                    if let insertedIndexes = collectionChanges.insertedIndexes
                        where insertedIndexes.count > 0 {
                        collectionView.insertItemsAtIndexPaths(insertedIndexes.indexPathsFromIndexesWithSection(0))
                    }
                    
                    if let changedIndexes = collectionChanges.changedIndexes
                        where changedIndexes.count > 0 {
                        collectionView.reloadItemsAtIndexPaths(changedIndexes.indexPathsFromIndexesWithSection(0))
                    }
                    }, completion:  nil)
            }
            
            self.resetCachedAssets()
        }
    }
}

extension GalleryCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return self.ITEM_INSET
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return self.ITEM_INSET
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let numberOfColumns:CGFloat = 3
        let itemWidth = ceil((self.view.frame.width - ((numberOfColumns - 1) * self.ITEM_INSET + 2 * self.ITEM_INSET)) / numberOfColumns)
        let itemHeight = itemWidth
        
        // Set thumbnailSize for fetching Photos for retina displays
        let scale = UIScreen.mainScreen().scale
        self.thumbnailSize = CGSizeMake(itemWidth * scale, itemWidth * scale)
        
        return CGSizeMake(itemHeight, itemWidth)
    }
}

extension GalleryCollectionViewController: AlbumsDelegate {
    
    func albumSelected(album: PHFetchResult, title: String?) {
        self.resetCachedAssets()
        self.album = album
        self.updateCachedAssets()
        self.collectionView?.setContentOffset(CGPointMake(0.0, -44.0), animated: false)
        self.collectionView?.reloadData()
        self.galleryCollectionViewDelegate?.updateAlbumName(title)
    }
}
