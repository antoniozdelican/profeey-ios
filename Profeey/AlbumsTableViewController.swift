//
//  AlbumsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import PhotosUI

protocol AlbumsDelegate {
    func albumSelected(album: PHFetchResult, title: String?)
}

class AlbumsTableViewController: UITableViewController {
    
    var albumsDelegate: AlbumsDelegate?
    private var fetchResults: [PHFetchResult] = []
    private var titles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Fetch allPhotos.
        let allPhotosFetchResult = PHAsset.fetchAssetsWithOptions(fetchOptions)
        //self.albums.append(["All Photos": allPhotosFetchResult])
        self.fetchResults.append(allPhotosFetchResult)
        self.titles.append("All Photos")

        // Fetch selfies album.
        let selfiesAssetCollections = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.SmartAlbumSelfPortraits, options: nil)
        if let assetCollection = selfiesAssetCollections[0] as? PHAssetCollection {
            let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: fetchOptions)
            let title = (assetCollection.localizedTitle != nil) ? assetCollection.localizedTitle! : ""
            //self.albums.append([title: fetchResult])
            self.fetchResults.append(fetchResult)
            self.titles.append(title)
        }
        
        // Fetch screenshots album.
        let screenshotsAssetCollections = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.SmartAlbumScreenshots, options: nil)
        if let assetCollection = screenshotsAssetCollections[0] as? PHAssetCollection {
            let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: fetchOptions)
            let title = (assetCollection.localizedTitle != nil) ? assetCollection.localizedTitle! : ""
            self.fetchResults.append(fetchResult)
            self.titles.append(title)
        }
        
        // Fetch other albums.
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
        for i in 0...(topLevelUserCollections.count - 1) {
            if let assetCollection = topLevelUserCollections[i] as? PHAssetCollection {
                let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: fetchOptions)
                let title = (assetCollection.localizedTitle != nil) ? assetCollection.localizedTitle! : ""
                self.fetchResults.append(fetchResult)
                self.titles.append(title)
            }
        }
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.fetchResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellAlbum", forIndexPath: indexPath) as! AlbumTableViewCell
        cell.albumTitleLabel.text = self.titles[indexPath.row]
        cell.numberOfAssets.text = "\(self.fetchResults[indexPath.row].count)"
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.albumsDelegate?.albumSelected(self.fetchResults[indexPath.row], title: self.titles[indexPath.row])
        self.performSegueWithIdentifier("unwindToGalleryCollectionVc", sender: self)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
}

extension AlbumsTableViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(changeInstance: PHChange) {
        /*
         Change notifications may be made on a background queue. Re-dispatch to the
         main queue before acting on the change as we'll be updating the UI.
         */
        dispatch_async(dispatch_get_main_queue(), {
            // Loop through the section fetch results, replacing any fetch results that have been updated.
            var updatedFetchResults: [PHFetchResult] = self.fetchResults
            var reloadRequired = false
            
            for (index, fetchResult) in self.fetchResults.enumerate() {
                let changeDetails = changeInstance.changeDetailsForFetchResult(fetchResult)
                if changeDetails != nil {
                   updatedFetchResults[index] = changeDetails!.fetchResultAfterChanges
                    reloadRequired = true
                }
            }
            
            if reloadRequired {
                self.fetchResults = updatedFetchResults
                self.tableView.reloadData()
            }
        })
    }
}
