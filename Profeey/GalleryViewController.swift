//
//  GalleryViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import PhotosUI

protocol GalleryDelegate {
    func cameraButtonTapped()
}

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var albumNameButton: UIButton!

    var galleryDelegate: GalleryDelegate?
    var albumsDelegate: AlbumsDelegate?
    var isProfilePic: Bool = false
    var profilePicUnwind: ProfilePicUnwind?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adjust button image to the right.
        self.albumNameButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.albumNameButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.albumNameButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? GalleryCollectionViewController {
            destinationViewController.galleryCollectionViewDelegate = self
            self.albumsDelegate = destinationViewController
            destinationViewController.isProfilePic = self.isProfilePic
            destinationViewController.profilePicUnwind = self.profilePicUnwind
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? AlbumsTableViewController {
            childViewController.albumsDelegate = self
        }
    }
    
    // MARK: IBActions
    
    @IBAction func cameraButtonTapped(_ sender: AnyObject) {
        self.galleryDelegate?.cameraButtonTapped()
    }
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension GalleryViewController: GalleryCollectionViewDelegate {
    
    func updateAlbumName(_ name: String?) {
        self.albumNameButton.setTitle(name, for: UIControlState())
    }
}

extension GalleryViewController: AlbumsDelegate {
    
    func albumSelected(_ album: PHFetchResult<PHAsset>, title: String?) {
        // Transfer delegation to GalleryCollectionVc.
        self.albumsDelegate?.albumSelected(album, title: title)
    }
}
