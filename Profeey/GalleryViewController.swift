//
//  GalleryViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import PhotosUI

protocol GalleryViewControllerDelegate: class {
    func cameraButtonTapped()
    func didSelectAsset(asset: PHAsset)
}

class GalleryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var galleryViewControllerDelegate: GalleryViewControllerDelegate?
    
    fileprivate var imageManager: PHCachingImageManager?
    fileprivate var thumbnailSize: CGSize!
    // Used for checking if PHCachingImageManager should start caching
    fileprivate var previousPreheatRect: CGRect!
    fileprivate var album :PHFetchResult<PHAsset>?
    fileprivate var ITEM_INSET: CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()
        
        if self.album == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            self.album = PHAsset.fetchAssets(with: allPhotosOptions)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Begin caching assets in and around collection view's visible rect
        self.updateCachedAssets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        self.imageManager?.stopCachingImagesForAllAssets()
        self.previousPreheatRect = CGRect.zero;
    }
    
    fileprivate func updateCachedAssets() {
        guard self.isViewLoaded && self.view.window != nil else {
            return
        }
        guard let galleryCollectionView = self.collectionView else {
            return
        }
        
        // The preheat window is twice the height of the visible rect
        var preheatRect = galleryCollectionView.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
        
        // Check if the collection view is showing an area that is significantly different to the last preheated area
        let delta = abs(preheatRect.midY - self.previousPreheatRect.midY)
        if delta > galleryCollectionView.bounds.height / 3.0 {
            
            // Compute the assets to start caching and to stop caching.
            var addedIndexPaths: [IndexPath] = []
            var removedIndexPaths: [IndexPath] = []
            
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
            self.imageManager?.startCachingImages(
                for: assetsToStartCaching,
                targetSize: self.thumbnailSize,
                contentMode: PHImageContentMode.aspectFill,
                options: nil
            )
            self.imageManager?.stopCachingImages(
                for: assetsToStopCaching,
                targetSize: self.thumbnailSize,
                contentMode: PHImageContentMode.aspectFill,
                options: nil
            )
            
            // Store the preheat rect to compare against in the future.
            self.previousPreheatRect = preheatRect
        }
    }
    
    fileprivate func computeDifferenceBetweenRect(_ oldRect: CGRect, andRect newRect: CGRect, removedHandler: (CGRect)-> Void, addedHandler: (CGRect)-> Void) {
        if newRect.intersects(oldRect) {
            let oldMaxY = oldRect.maxY
            let oldMinY = oldRect.minY
            let newMaxY = newRect.maxY
            let newMinY = newRect.minY
            
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
            
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height: (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height: (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    fileprivate func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset] {
        var assets: [PHAsset] = []
        for indexPath in indexPaths {
            let asset = self.album![indexPath.item]
            assets.append(asset)
        }
        return assets
    }
}

extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let album = self.album else {
            return 0
        }
        // Number of photos (videos) and camera button.
        return album.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCameraGallery", for: indexPath) as! GalleryCollectionViewCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellGallery", for: indexPath) as! GalleryCollectionViewCell
        let asset = self.album![indexPath.item]
        cell.representedAssetIdentifier = asset.localIdentifier as NSString!
        
        // Request an image for the asset from the PHCachingImageManager
        self.imageManager?.requestImage(
            for: asset,
            targetSize: thumbnailSize!,
            contentMode: PHImageContentMode.aspectFill,
            options: nil,
            resultHandler: {result, info in
                // Set the cell's thumbnail image if it's still showing the same asset
                if cell.representedAssetIdentifier == asset.localIdentifier as NSString {
                    cell.thumbnailImageView?.image = result
                }
        })
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? GalleryCollectionViewCell {
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    cell.overlayView.alpha = 0.4
            }, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? GalleryCollectionViewCell {
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    cell.overlayView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            // Scroll to camera.
            self.galleryViewControllerDelegate?.cameraButtonTapped()
        } else {
            guard let asset = self.album?[indexPath.item] else {
                return
            }
            self.galleryViewControllerDelegate?.didSelectAsset(asset: asset)
        }
    }
    
    //MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Update cached assets for the new visible area
        self.updateCachedAssets()
    }
    
}

extension GalleryViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Check if there are changes to the assets we are showing.
        guard let assetsFetchResults = self.album,
            let collectionChanges = changeInstance.changeDetails(for: assetsFetchResults) else {
                return
        }
        
        /*
         Change notifications may be made on a background queue. Re-dispatch to the
         main queue before acting on the change as we'll be updating the UI.
         */
        DispatchQueue.main.async {
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
                        , removedIndexes.count > 0 {
                        collectionView.deleteItems(at: removedIndexes.indexPathsFromIndexesWithSection(0))
                    }
                    
                    if let insertedIndexes = collectionChanges.insertedIndexes
                        , insertedIndexes.count > 0 {
                        collectionView.insertItems(at: insertedIndexes.indexPathsFromIndexesWithSection(0))
                    }
                    
                    if let changedIndexes = collectionChanges.changedIndexes
                        , changedIndexes.count > 0 {
                        collectionView.reloadItems(at: changedIndexes.indexPathsFromIndexesWithSection(0))
                    }
                    }, completion:  nil)
            }
            
            self.resetCachedAssets()
        }
    }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.ITEM_INSET
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.ITEM_INSET
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns:CGFloat = 3
        let itemWidth = ceil((self.view.frame.width - ((numberOfColumns - 1) * self.ITEM_INSET + 2 * self.ITEM_INSET)) / numberOfColumns)
        let itemHeight = itemWidth
        
        // Set thumbnailSize for fetching Photos for retina displays
        let scale = UIScreen.main.scale
        self.thumbnailSize = CGSize(width: itemWidth * scale, height: itemWidth * scale)
        
        return CGSize(width: itemHeight, height: itemWidth)
    }
}

extension GalleryViewController: CaptureScrollViewDelegate {
    
    func albumSelected(_ album: PHFetchResult<PHAsset>, title: String?) {
        self.resetCachedAssets()
        self.album = album
        self.updateCachedAssets()
        self.collectionView?.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
        self.collectionView?.reloadData()
    }
}
