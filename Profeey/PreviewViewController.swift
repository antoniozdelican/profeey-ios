//
//  PreviewViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 30/12/16.
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
    @IBOutlet weak var scrollViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var gridView: GridView!
    @IBOutlet weak var gridContainerView: UIView!
    
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
    
    fileprivate var leadingGridViewConstraint: NSLayoutConstraint!
    fileprivate var trailingGridViewConstraint: NSLayoutConstraint!
    fileprivate var topGridViewConstraint: NSLayoutConstraint!
    fileprivate var bottomGridViewConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        self.nextButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        
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
    
    fileprivate func configureScrollView() {
        self.scrollView.delegate = self
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.zoomScale = 1.0
        self.configureInitialGridView()
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
    
    fileprivate func configureInitialGridView() {
        Bundle.main.loadNibNamed("GridView", owner: self, options: nil)
        self.gridContainerView.addSubview(self.gridView)
        self.gridView.translatesAutoresizingMaskIntoConstraints = false
        self.leadingGridViewConstraint = NSLayoutConstraint(item: self.gridView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.gridContainerView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0)
        self.trailingGridViewConstraint = NSLayoutConstraint(item: self.gridView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.gridContainerView, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0)
        self.topGridViewConstraint = NSLayoutConstraint(item: self.gridView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.gridContainerView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
        self.bottomGridViewConstraint = NSLayoutConstraint(item: self.gridView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.gridContainerView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([self.leadingGridViewConstraint, self.trailingGridViewConstraint, self.topGridViewConstraint, self.bottomGridViewConstraint])
        self.gridView.alpha = 0.0
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
            destinationViewController.postImage = self.finalImage
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
    
    // MARK: Adjust grid
    
    fileprivate func adjustGrid() {
        // Horizontal.
        if self.scrollView.contentOffset.x < 0 {
            self.leadingGridViewConstraint.constant = -self.scrollView.contentOffset.x
        } else {
            self.leadingGridViewConstraint.constant = 0.0
        }
        if (self.scrollView.contentSize.width - self.scrollView.contentOffset.x) < self.scrollView.bounds.width {
            let trailingPoint = self.scrollView.bounds.width - (self.scrollView.contentSize.width - self.scrollView.contentOffset.x)
            self.trailingGridViewConstraint.constant = -trailingPoint
        } else {
            self.trailingGridViewConstraint.constant = 0.0
        }
        // Vertical.
        if self.scrollView.contentOffset.y < 0 {
            self.topGridViewConstraint.constant = -self.scrollView.contentOffset.y
            
        } else {
            self.topGridViewConstraint.constant = 0.0
        }
        if (self.scrollView.contentSize.height - self.scrollView.contentOffset.y) < self.scrollView.bounds.height {
            let bottomPoint = self.scrollView.bounds.height - (self.scrollView.contentSize.height - self.scrollView.contentOffset.y)
            self.bottomGridViewConstraint.constant = -bottomPoint
        } else {
            self.bottomGridViewConstraint.constant = 0.0
        }
    }
    
    fileprivate func toggleGrid(_ isHidden: Bool) {
        guard (self.gridView.alpha == 0.0 && isHidden == false) || (self.gridView.alpha == 1.0 && isHidden == true) else {
            return
        }
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.gridView.alpha = isHidden ? 0.0 : 1.0
        })
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

extension PreviewViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.containerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustScrollViewInset()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.adjustGrid()
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.toggleGrid(false)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.toggleGrid(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.toggleGrid(false)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.toggleGrid(true)
    }
}
