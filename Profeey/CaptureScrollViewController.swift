//
//  CaptureScrollViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import PhotosUI

protocol CaptureScrollViewDelegate {
    func albumSelected(_ album: PHFetchResult<PHAsset>, title: String?)
}

class CaptureScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var albumButton: UIButton?
    
    var isProfilePic: Bool = false
    var profilePicUnwind: ProfilePicUnwind?
    
    fileprivate var captureScrollViewDelegate: CaptureScrollViewDelegate?
    fileprivate var photo: UIImage?
    fileprivate var asset: PHAsset?
    fileprivate var isPhoto: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.configureNavigationItem()
        self.configureScrollView()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureNavigationItem() {
        Bundle.main.loadNibNamed("AlbumButton", owner: self, options: nil)
        self.albumButton?.addTarget(self, action: #selector(self.albumButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        self.navigationItem.title = "Camera"
    }
    
    fileprivate func configureScrollView() {
        // Show camera first.
        self.scrollView.layoutIfNeeded()
        self.scrollView.contentOffset = CGPoint(x: self.view.bounds.width, y: 0.0)
        self.scrollView.delegate = self
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? CameraViewController {
            destinationViewController.cameraViewControllerDelegate = self
            destinationViewController.isProfilePic = self.isProfilePic
        }
        if let destinationViewController = segue.destination as? GalleryViewController {
            destinationViewController.galleryViewControllerDelegate = self
            self.captureScrollViewDelegate = destinationViewController
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? AlbumsTableViewController {
            childViewController.albumsDelegate = self
        }
        if let destinationViewController = segue.destination as? PreviewViewController {
            if self.isPhoto {
                destinationViewController.capturedPhoto = self.photo
                self.photo = nil
            } else {
                destinationViewController.asset = self.asset
            }
            destinationViewController.isPhoto = self.isPhoto
            destinationViewController.isProfilePic = self.isProfilePic
            destinationViewController.profilePicUnwind = self.profilePicUnwind
        }
    }
    
    // MARK: Tappers
    
    func albumButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "segueToAlbumsVc", sender: self)
    }
    
    // MARK: IBActions
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CaptureScrollViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            self.navigationItem.titleView = self.albumButton
            self.navigationItem.title = nil
        } else if scrollView.contentOffset.x == self.view.bounds.width {
            self.navigationItem.titleView = nil
            self.navigationItem.title = "Camera"
        }
    }
}

extension CaptureScrollViewController: CameraViewControllerDelegate {
    
    func galleryButtonTapped() {
        // Scroll to gallery.
        self.scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
}

extension CaptureScrollViewController: GalleryViewControllerDelegate {
    
    func cameraButtonTapped() {
        // Scroll to camera.
        self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0.0), animated: true)
    }
    
    func didSelectPhoto(photo: UIImage) {
        self.photo = photo
        self.isPhoto = true
        self.performSegue(withIdentifier: "segueToPreviewVc", sender: self)
    }
}

extension CaptureScrollViewController: AlbumsDelegate {
    
    func albumSelected(_ album: PHFetchResult<PHAsset>, title: String?) {
        // Transfer delegation to GalleryVc.
        self.captureScrollViewDelegate?.albumSelected(album, title: title)
        self.albumButton?.setTitle(title, for: UIControlState.normal)
    }
    
    func didSelectAsset(asset: PHAsset) {
        self.asset = asset
        self.isPhoto = false
        self.performSegue(withIdentifier: "segueToPreviewVc", sender: self)
    }
}
