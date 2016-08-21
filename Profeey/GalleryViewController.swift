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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adjust button image to the right.
        self.albumNameButton.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        self.albumNameButton.titleLabel?.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        self.albumNameButton.imageView?.transform = CGAffineTransformMakeScale(-1.0, 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? GalleryCollectionViewController {
            destinationViewController.galleryCollectionViewDelegate = self
            self.albumsDelegate = destinationViewController
        }
        if let navigationController = segue.destinationViewController as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? AlbumsTableViewController {
            childViewController.albumsDelegate = self
        }
    }
    
    // MARK: IBActions
    
    @IBAction func cameraButtonTapped(sender: AnyObject) {
        self.galleryDelegate?.cameraButtonTapped()
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension GalleryViewController: GalleryCollectionViewDelegate {
    
    func updateAlbumName(name: String?) {
        self.albumNameButton.setTitle(name, forState: .Normal)
    }
}

extension GalleryViewController: AlbumsDelegate {
    
    func albumSelected(album: PHFetchResult, title: String?) {
        // Transfer delegation to GalleryCollectionVc.
        self.albumsDelegate?.albumSelected(album, title: title)
    }
}
