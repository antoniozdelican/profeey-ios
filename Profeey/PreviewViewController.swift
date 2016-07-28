//
//  PreviewViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 27/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import PhotosUI

class PreviewViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var cropImageView: UIImageView!
    
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    var photo: UIImage?
    var asset: PHAsset?
    // Determine if it's a photo or asset from gallery.
    var isPhoto: Bool = true
    var cropFrameLength: CGFloat!
    var CROP_FRAME_PADDING: CGFloat = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.cropFrameLength = self.view.bounds.width - 2 * CROP_FRAME_PADDING
        
        self.configureCropImageView()
        self.configureScrollView()
        
        if self.isPhoto {
            self.configurePhoto()
        } else {
            self.configureAsset()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureCropImageView() {
        // Set up the cropImageView depending on the device.
        let screenHeight: NSNumber = UIScreen.mainScreen().bounds.height
        switch screenHeight {
        case 568: // iPhone 5, 5s, SE
            self.cropImageView.image = UIImage(named: "bg_crop_568h")
        case 667: // iPhone 6, 6s
            self.cropImageView.image = UIImage(named: "bg_crop_667h")
        case 736: // iPhone 6 Plus, 6s Plus
            self.cropImageView.image = UIImage(named: "bg_crop_736h")
        default: // unknown
            self.cropImageView.image = UIImage(named: "bg_crop_736h")
        }
    }
    
    private func configureScrollView() {
        self.scrollView.delegate = self
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 4.0
        self.scrollView.zoomScale = 1.0
    }
    
    private func configurePhoto() {
//        guard let newWidth = self.photo?.size.width,
//            let newHeight = self.photo?.size.height else {
//                return
//        }
//        self.imageViewWidthConstraint.constant = newWidth
//        self.imageViewHeightConstraint.constant = newHeight
//        self.imageView.image = photo
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
                        
                        let aspectRatio = image.size.width / image.size.height
                        var newImageWidth: CGFloat
                        var newImageHeight: CGFloat
                        
                        if image.size.width <= image.size.height {
                            newImageWidth = self.view.bounds.width
                            newImageHeight = ceil(newImageWidth / aspectRatio)
                        } else {
                            newImageHeight = self.view.bounds.width
                            newImageWidth = ceil(newImageHeight * aspectRatio)
                        }
                        
                        self.imageViewWidthConstraint.constant = newImageWidth
                        self.imageViewHeightConstraint.constant = newImageHeight
                        self.imageView.image = image
                        
                        self.updateScrollView(newImageWidth, newImageHeight: newImageHeight)
                    }
            })
        }
    }
    
    private func updateScrollView(newImageWidth: CGFloat, newImageHeight: CGFloat) {
        // Adjust insets.
        let topInset = ceil((self.scrollView.bounds.height - self.cropFrameLength) / 2)
        let bottomInset = topInset
        self.scrollView.contentInset = UIEdgeInsetsMake(topInset, self.CROP_FRAME_PADDING, bottomInset, self.CROP_FRAME_PADDING)
        
        // Adjust offsets.
        let offsetX = -ceil((self.scrollView.bounds.width - newImageWidth) / 2)
        let difference = ceil((newImageHeight - self.cropFrameLength) / 2)
        let offsetY = -(topInset - difference)
        self.scrollView.contentOffset = CGPointMake(offsetX, offsetY)
    }

}

extension PreviewViewController: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
