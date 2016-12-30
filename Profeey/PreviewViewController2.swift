//
//  PreviewViewController2.swift
//  Profeey
//
//  Created by Antonio Zdelican on 30/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import PhotosUI

class PreviewViewController2: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var gridView: GridView!
    
    var photo: UIImage?
    var asset: PHAsset?
    var isPhoto: Bool = false
    var isProfilePic: Bool = false
    var profilePicUnwind: ProfilePicUnwind?
    var finalImage: UIImage?
    
    fileprivate var containerViewWidth: CGFloat = 0.0
    fileprivate var containerViewHeight: CGFloat = 0.0
    fileprivate var scale: CGFloat?
    fileprivate var isImageAlreadyConfigured: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        self.nextButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        
        self.configureGridView()
        if self.isProfilePic {
            self.configureSquareAspectRatio()
        } else {
            self.configureScrollView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Skip if we come back from EditVc.
        if !self.isImageAlreadyConfigured {
            self.isPhoto ? self.configurePhoto() : self.configureAsset()
            self.isImageAlreadyConfigured = true
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureGridView() {
        Bundle.main.loadNibNamed("GridView", owner: self, options: nil)
        self.containerView.addSubview(self.gridView)
        self.gridView.translatesAutoresizingMaskIntoConstraints = false
        let trailing = NSLayoutConstraint(item: self.gridView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0)
        let leading = NSLayoutConstraint(item: self.gridView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: self.gridView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: self.gridView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([trailing, leading, top, bottom])
    }
    
    fileprivate func configureScrollView() {
        self.scrollView.delegate = self
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.zoomScale = 1.0
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
        self.configureScrollView()
    }
    
    fileprivate func configurePhoto() {
        guard let image = self.photo?.fixOrientation() else {
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
                    guard let image = result else {
                        return
                    }
                    self.adjustImageSize(image)
            })
        }
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
    
    // MARK: Adjust Image
    
    fileprivate func adjustImageSize(_ image: UIImage) {
        let aspectRatio = image.size.width / image.size.height
        
        // ImageView.
        self.scrollView.layoutIfNeeded()
        if self.isProfilePic {
            if image.size.width >= image.size.height {
                self.containerViewHeight = self.scrollView.bounds.height
                self.containerViewWidth = ceil(self.containerViewHeight * aspectRatio)
            } else {
                self.containerViewWidth = self.scrollView.bounds.width
                self.containerViewHeight = ceil(self.containerViewWidth / aspectRatio)
            }
        } else {
            self.containerViewWidth = self.scrollView.bounds.width
            self.containerViewHeight = ceil(self.containerViewWidth / aspectRatio)
        }
        
        self.containerViewWidthConstraint.constant = self.containerViewWidth
        self.containerViewHeightConstraint.constant = self.containerViewHeight
        
        // Set up scale for later use.
        self.scale = image.size.width / self.containerViewWidth
        
        // ScrollView inset.
        self.adjustScrollViewInset()
        
        // ScrollView offset.
        self.adjustScrollViewOffset()
        
        self.imageView.image = image
    }
    
    // MARK: Adjust ScrollView
    
    fileprivate func adjustScrollViewInset() {
        let zoomScale = self.scrollView.zoomScale
        var topInset: CGFloat
        var bottomInset: CGFloat
        var leftInset: CGFloat
        var rightInset: CGFloat
        if self.containerViewHeight * zoomScale < self.scrollView.bounds.height {
            topInset = ceil((self.scrollView.bounds.height - self.containerViewHeight * zoomScale) / 2)
        } else {
            topInset = 0.0
        }
        bottomInset = topInset
        if self.containerViewWidth * zoomScale < self.scrollView.bounds.width {
            leftInset = ceil((self.scrollView.bounds.width - self.containerViewWidth * zoomScale) / 2)
        } else {
            leftInset = 0.0
        }
        rightInset = leftInset
        self.scrollView.contentInset = UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset)
    }
    
    fileprivate func adjustScrollViewOffset() {
        let offsetX = -ceil((self.scrollView.bounds.width - self.containerViewWidth) / 2)
        let offsetY = -ceil((self.scrollView.bounds.height - self.containerViewHeight) / 2)
        self.scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
    }
    
    // MARK: Final
    
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

extension PreviewViewController2: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.containerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustScrollViewInset()
    }
}
