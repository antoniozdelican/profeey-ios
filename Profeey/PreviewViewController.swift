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
    case EditProfileVc
    case UsernameVc
}

class PreviewViewController: UIViewController {
    
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
    private var newImageViewWidth: CGFloat = 0.0
    private var newImageViewHeight: CGFloat = 0.0
    
    private var scale: CGFloat?
    private var alreadyConfigured: Bool = false
    var finalImage: UIImage?
    // Determine if it's profile and unwind respectively.
    var isProfilePic: Bool = false
    var profilePicUnwind: ProfilePicUnwind?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        if self.isProfilePic {
            self.configureSquareAspectRatio()
        }
        self.configureScrollView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Skip if we come back from EditVc.
        if !self.alreadyConfigured {
            self.isPhoto ? self.configurePhoto() : self.configureAsset()
            self.alreadyConfigured = true
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureScrollView() {
        self.scrollView.delegate = self
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.zoomScale = 1.0
    }
    
    private func configurePhoto() {
        // Fix orientation for the bug.
        guard let image = self.capturedPhoto?.fixOrientation() else {
            return
        }
        self.adjustImageSize(image)
    }
    
    private func configureAsset() {
        if let asset = self.asset {
            PHImageManager.defaultManager().requestImageForAsset(
                asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: PHImageContentMode.Default,
                options: nil,
                resultHandler: {
                    (result: UIImage?, info: [NSObject : AnyObject]?) in
                    if let image = result {
                        self.adjustImageSize(image)
                    }
            })
        }
    }
    
    private func configureSquareAspectRatio() {
        self.scrollViewAspectRatioConstraint.active = false
        let squareConstraint = NSLayoutConstraint(
            item: self.scrollView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.scrollView,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1.0,
            constant: 0.0)
        self.scrollView.addConstraint(squareConstraint)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? EditPostTableViewController {
            destinationViewController.finalImage = self.finalImage
        }
    }
    
    // MARK: IBActions
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        self.prepareFinalImage()
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: Helpers
    
    private func adjustImageSize(image: UIImage) {
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
    
    private func adjustScrollViewInset() {
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
    
    private func adjustScrollViewOffset() {
        let offsetX = -ceil((self.scrollView.bounds.width - self.newImageViewWidth) / 2)
        let offsetY = -ceil((self.scrollView.bounds.height - self.newImageViewHeight) / 2)
        self.scrollView.contentOffset = CGPointMake(offsetX, offsetY)
    }
    
    private func prepareFinalImage() {
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
            case .EditProfileVc:
                self.performSegueWithIdentifier("segueUnwindToEditProfileVc", sender: self)
            case .UsernameVc:
                self.performSegueWithIdentifier("segueUnwindToUsernameVc", sender: self)
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
        self.performSegueWithIdentifier("segueToEditVc", sender: self)
    }
}

extension PreviewViewController: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.adjustScrollViewInset()
    }
}