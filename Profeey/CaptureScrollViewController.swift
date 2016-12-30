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

protocol FlashSwitchDelegate {
    func flashBarButtonTapped()
}

enum FlashType {
    case on
    case off
    case auto
}

class CaptureScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var albumButton: UIButton?
    
    var flashBarButtonItem: UIBarButtonItem?
    var isProfilePic: Bool = false
    var profilePicUnwind: ProfilePicUnwind?
    
    fileprivate var captureScrollViewDelegate: CaptureScrollViewDelegate?
    fileprivate var flashSwitchDelegate: FlashSwitchDelegate?
    fileprivate var photo: UIImage?
    fileprivate var asset: PHAsset?
    fileprivate var isPhoto: Bool = true
    
    // Initialy is not but as soon as it's loaded, hide it.
    fileprivate var isStatusBarHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.configureNavigationItems()
        self.configureScrollView()
        
        self.isStatusBarHidden = true
        UIView.animate(withDuration: 0.2, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureNavigationItems() {
        Bundle.main.loadNibNamed("AlbumButton", owner: self, options: nil)
        self.albumButton?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.albumButton?.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.albumButton?.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.albumButton?.titleEdgeInsets = UIEdgeInsetsMake(0.0, 4.0, 0.0, 0.0)
        self.albumButton?.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 4.0)
        self.albumButton?.addTarget(self, action: #selector(self.albumButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        self.flashBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_flash_auto"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.flashBarButtonTapped(_:)))
        // Show gallery first.
        self.navigationItem.titleView = self.albumButton
        self.navigationItem.title = nil
        self.navigationItem.rightBarButtonItem = nil
    }
    
    fileprivate func configureScrollView() {
        // Show gallery first.
        self.scrollView.layoutIfNeeded()
        self.scrollView.contentOffset = CGPoint(x: self.view.bounds.width, y: 0.0)
        self.scrollView.delegate = self
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? CameraViewController {
            destinationViewController.cameraViewControllerDelegate = self
            destinationViewController.isProfilePic = self.isProfilePic
            self.flashSwitchDelegate = destinationViewController
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
    
    func flashBarButtonTapped(_ sender: AnyObject) {
        self.flashSwitchDelegate?.flashBarButtonTapped()
    }
    
    // MARK: IBActions
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CaptureScrollViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            self.navigationItem.titleView = nil
            self.navigationItem.title = "Camera"
            self.navigationItem.rightBarButtonItem = self.flashBarButtonItem
        } else if scrollView.contentOffset.x == self.view.bounds.width {
            self.navigationItem.titleView = self.albumButton
            self.navigationItem.title = nil
            self.navigationItem.rightBarButtonItem = nil
        }
    }
}

extension CaptureScrollViewController: CameraViewControllerDelegate {
    
    func galleryButtonTapped() {
        // Scroll to gallery.
        self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0.0), animated: true)
    }
    
    func flashTypeChangedInto(_ flashType: FlashType) {
        switch flashType {
        case .auto:
            self.flashBarButtonItem?.image = UIImage(named: "ic_flash_auto")
        case .on:
            self.flashBarButtonItem?.image = UIImage(named: "ic_flash_on")
        case .off:
            self.flashBarButtonItem?.image = UIImage(named: "ic_flash_off")
        }
    }
    
    func toggleFlashBarButton(_ isVisible: Bool) {
        self.navigationItem.rightBarButtonItem = isVisible ? self.flashBarButtonItem : nil
    }
}

extension CaptureScrollViewController: GalleryViewControllerDelegate {
    
    func cameraButtonTapped() {
        // Scroll to camera.
        self.scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
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
