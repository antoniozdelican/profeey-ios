//
//  PreviewViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 01/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import PhotosUI

enum ProfilePicUnwind {
    case editProfileVc
    case usernameVc
}

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewAspectRatioConstraint: NSLayoutConstraint!
    
    var capturedPhoto: UIImage?
    var asset: PHAsset?
    // Determine if it's a photo or asset from gallery.
    var isPhoto: Bool = true
    
    // Adjusting imageView in scrollView.
    fileprivate var newImageViewWidth: CGFloat = 0.0
    fileprivate var newImageViewHeight: CGFloat = 0.0
    
    fileprivate var scale: CGFloat?
    fileprivate var alreadyConfigured: Bool = false
    var finalImage: UIImage?
    // Determine if it's profile and unwind respectively.
    var isProfilePic: Bool = false
    var profilePicUnwind: ProfilePicUnwind?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.nextButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        if self.isProfilePic {
            self.configureSquareAspectRatio()
        }
        self.configureScrollView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Skip if we come back from EditVc.
        if !self.alreadyConfigured {
            self.isPhoto ? self.configurePhoto() : self.configureAsset()
            self.alreadyConfigured = true
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureScrollView() {
        self.scrollView.delegate = self
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.zoomScale = 1.0
    }
    
    fileprivate func configurePhoto() {
        // Fix orientation for the bug.
        guard let image = self.capturedPhoto?.fixOrientation() else {
            return
        }
        self.adjustImageSize(image)
    }
    
    fileprivate func configureAsset() {
        if let asset = self.asset {
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: PHImageContentMode.default,
                options: nil,
                resultHandler: {
                    (result: UIImage?, info: [AnyHashable: Any]?) in
                    if let image = result {
                        self.adjustImageSize(image)
                    }
            })
        }
    }
    
    fileprivate func configureSquareAspectRatio() {
        self.scrollViewAspectRatioConstraint.isActive = false
        let squareConstraint = NSLayoutConstraint(
            item: self.scrollView,
            attribute: NSLayoutAttribute.height,
            relatedBy: NSLayoutRelation.equal,
            toItem: self.scrollView,
            attribute: NSLayoutAttribute.width,
            multiplier: 1.0,
            constant: 0.0)
        self.scrollView.addConstraint(squareConstraint)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? AddInfoTableViewController {
            destinationViewController.photo = self.finalImage
        }
    }
    
    // MARK: IBActions
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        self.prepareFinalImage()
    }
    
    // MARK: Helpers
    
    fileprivate func adjustImageSize(_ image: UIImage) {
        let aspectRatio = image.size.width / image.size.height
        
        // ImageView.
        self.scrollView.layoutIfNeeded()
        if self.isProfilePic {
            if image.size.width >= image.size.height {
                self.newImageViewHeight = self.scrollView.bounds.height
                self.newImageViewWidth = ceil(self.newImageViewHeight * aspectRatio)
            } else {
                self.newImageViewWidth = self.scrollView.bounds.width
                self.newImageViewHeight = ceil(self.newImageViewWidth / aspectRatio)
            }
        } else {
            self.newImageViewWidth = self.scrollView.bounds.width
            self.newImageViewHeight = ceil(self.newImageViewWidth / aspectRatio)
        }
        
        self.imageViewWidthConstraint.constant = self.newImageViewWidth
        self.imageViewHeightConstraint.constant = self.newImageViewHeight
        
        // Set up scale for later use.
        self.scale = image.size.width / self.newImageViewWidth
        
        // ScrollView inset.
        self.adjustScrollViewInset()
        
        // ScrollView offset.
        self.adjustScrollViewOffset()
        
        self.imageView.image = image
    }
    
    fileprivate func adjustScrollViewInset() {
        let zoomScale = self.scrollView.zoomScale
        var topInset: CGFloat
        var bottomInset: CGFloat
        var leftInset: CGFloat
        var rightInset: CGFloat
        if self.newImageViewHeight * zoomScale < self.scrollView.bounds.height {
            topInset = ceil((self.scrollView.bounds.height - self.newImageViewHeight * zoomScale) / 2)
        } else {
            topInset = 0.0
        }
        bottomInset = topInset
        if self.newImageViewWidth * zoomScale < self.scrollView.bounds.width {
            leftInset = ceil((self.scrollView.bounds.width - self.newImageViewWidth * zoomScale) / 2)
        } else {
            leftInset = 0.0
        }
        rightInset = leftInset
        self.scrollView.contentInset = UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset)
    }
    
    fileprivate func adjustScrollViewOffset() {
        let offsetX = -ceil((self.scrollView.bounds.width - self.newImageViewWidth) / 2)
        let offsetY = -ceil((self.scrollView.bounds.height - self.newImageViewHeight) / 2)
        self.scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
    }
    
    fileprivate func prepareFinalImage() {
        guard let scale = self.scale, let image = self.imageView.image else {
            return
        }
        let zoomScale = 1.0 / self.scrollView.zoomScale
        
        // Crop.
        let cropX = ceil((self.scrollView.contentOffset.x + self.scrollView.contentInset.left) * zoomScale * scale)
        let cropY = ceil((self.scrollView.contentOffset.y + self.scrollView.contentInset.top) * zoomScale * scale)
        let cropWidth = ceil((self.scrollView.bounds.width - (self.scrollView.contentInset.left + self.scrollView.contentInset.right)) * zoomScale * scale)
        let cropHeight = ceil((self.scrollView.bounds.height - (self.scrollView.contentInset.top + self.scrollView.contentInset.bottom)) * zoomScale * scale)
        let croppedImage = image.crop(cropX, cropY: cropY, cropWidth: cropWidth, cropHeight: cropHeight)
        
        // Scale.
        // Profile pic is 400 x 400, others 1080 in width or less.
        if self.isProfilePic {
            guard let profilePicUnwind = self.profilePicUnwind else {
                return
            }
            let scaledWidth: CGFloat = 400.0
            let scaledHeight: CGFloat = 400.0
            let scaledImage = croppedImage.scale(scaledWidth, height: scaledHeight, scale: croppedImage.scale)
            self.finalImage = scaledImage
            
            switch profilePicUnwind {
            case .editProfileVc:
                self.performSegue(withIdentifier: "segueUnwindToEditProfileVc", sender: self)
            case .usernameVc:
                self.performSegue(withIdentifier: "segueUnwindToUsernameVc", sender: self)
            }
            
        } else if croppedImage.size.width > 1080.0 {
            let aspectRatio = croppedImage.size.width / croppedImage.size.height
            let scaledWidth: CGFloat = 1080.0
            let scaledHeight: CGFloat = scaledWidth / aspectRatio
            let scaledImage = croppedImage.scale(scaledWidth, height: scaledHeight, scale: croppedImage.scale)
            self.finalImage = scaledImage
        } else {
           self.finalImage = croppedImage
        }
        self.performSegue(withIdentifier: "segueToAddInfoVc", sender: self)
    }
}

extension PreviewViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustScrollViewInset()
    }
}
