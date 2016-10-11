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
    func albumSelected(_ album: PHFetchResult<PHAsset>, title: String?)
}

class AlbumsTableViewController: UITableViewController {
    
    var albumsDelegate: AlbumsDelegate?
    fileprivate var fetchResults: [PHFetchResult<PHAsset>] = []
    fileprivate var titles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Fetch allPhotos.
        let allPhotosFetchResult = PHAsset.fetchAssets(with: fetchOptions)
        self.fetchResults.append(allPhotosFetchResult)
        self.titles.append("All Photos")

        // Fetch selfies album.
        let selfiesAssetCollections = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumSelfPortraits, options: nil)
        let assetCollection = selfiesAssetCollections[0]
        let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        let title = (assetCollection.localizedTitle != nil) ? assetCollection.localizedTitle! : ""
        self.fetchResults.append(fetchResult)
        self.titles.append(title)
        
        // Fetch screenshots album.
        let screenshotsAssetCollections = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumScreenshots, options: nil)
        let screenshotsAssetCollection = screenshotsAssetCollections[0]
        let screenshotsFetchResult = PHAsset.fetchAssets(in: screenshotsAssetCollection, options: fetchOptions)
        let screenshotsTitle = (assetCollection.localizedTitle != nil) ? screenshotsAssetCollection.localizedTitle! : ""
        self.fetchResults.append(screenshotsFetchResult)
        self.titles.append(screenshotsTitle)
        
        // Fetch other albums.
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        for i in 0...(topLevelUserCollections.count - 1) {
            if let assetCollection = topLevelUserCollections[i] as? PHAssetCollection {
                let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                let title = (assetCollection.localizedTitle != nil) ? assetCollection.localizedTitle! : ""
                self.fetchResults.append(fetchResult)
                self.titles.append(title)
            }
        }
        
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.fetchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAlbum", for: indexPath) as! AlbumTableViewCell
        cell.albumTitleLabel.text = self.titles[(indexPath as NSIndexPath).row]
        cell.numberOfAssets.text = "\(self.fetchResults[(indexPath as NSIndexPath).row].count)"
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.albumsDelegate?.albumSelected(self.fetchResults[indexPath.row], title: self.titles[indexPath.row])
        self.dismiss(animated: true, completion: nil)
        //self.performSegue(withIdentifier: "unwindToGalleryCollectionVc", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
}

extension AlbumsTableViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        /*
         Change notifications may be made on a background queue. Re-dispatch to the
         main queue before acting on the change as we'll be updating the UI.
         */
        DispatchQueue.main.async(execute: {
            // Loop through the section fetch results, replacing any fetch results that have been updated.
            var updatedFetchResults: [PHFetchResult] = self.fetchResults
            var reloadRequired = false
            
            for (index, fetchResult) in self.fetchResults.enumerated() {
                let changeDetails = changeInstance.changeDetails(for: fetchResult)
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
