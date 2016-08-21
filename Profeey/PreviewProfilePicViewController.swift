//
//  PreviewProfilePicViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import PhotosUI
import AWSMobileHubHelper

class PreviewProfilePicViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cropImageView: UIImageView!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var okButton: UIButton!
    
    var photo: UIImage?
    var asset: PHAsset?
    var imageOnScreen: UIImage?
    var finalImage: UIImage?
    var scale: CGFloat?
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
    
    // MARK: Pre-onfiguration
    
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
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.zoomScale = 1.0
    }
    
    private func configurePhoto() {
        guard let image = self.photo else {
            return
        }
        self.imageOnScreen = image
        self.adjustImageOnScreen(image)
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
                        self.imageOnScreen = image
                        self.adjustImageOnScreen(image)
                    }
            })
        }
    }
    
    private func adjustImageOnScreen(image: UIImage) {
        let aspectRatio = image.size.width / image.size.height
        var newImageViewWidth: CGFloat
        var newImageViewHeight: CGFloat
        
        if image.size.width <= image.size.height {
            newImageViewWidth = self.view.bounds.width
            newImageViewHeight = ceil(newImageViewWidth / aspectRatio)
        } else {
            newImageViewHeight = self.view.bounds.width
            newImageViewWidth = ceil(newImageViewHeight * aspectRatio)
        }
        self.imageViewWidthConstraint.constant = newImageViewWidth
        self.imageViewHeightConstraint.constant = newImageViewHeight
        self.imageView.image = image
        // Set up scale for later use.
        self.scale = image.size.width / newImageViewWidth
        
        self.scrollView.layoutIfNeeded()
        // Adjust scrollView inset.
        let topInset = ceil((self.scrollView.bounds.height - self.cropFrameLength) / 2)
        let bottomInset = topInset
        self.scrollView.contentInset = UIEdgeInsetsMake(topInset, self.CROP_FRAME_PADDING, bottomInset, self.CROP_FRAME_PADDING)
        
        // Adjust scrollView offset.
        let offsetX = -ceil((self.scrollView.bounds.width - newImageViewWidth) / 2)
        let difference = ceil((newImageViewHeight - self.cropFrameLength) / 2)
        let offsetY = -(topInset - difference)
        self.scrollView.contentOffset = CGPointMake(offsetX, offsetY)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    // MARK: IBActions
    
    @IBAction func okButtonTapped(sender: AnyObject) {
        self.prepareForUpload()
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    private func prepareForUpload() {
        guard let scale = self.scale, let imageOnScreen = self.imageOnScreen else {
            return
        }
        
        let topInset = ceil((self.scrollView.bounds.height - self.cropFrameLength) / 2)
        let zoomScale = 1.0 / self.scrollView.zoomScale
        
        let cropX = (self.scrollView.contentOffset.x + self.CROP_FRAME_PADDING) * scale * zoomScale
        let cropY = (self.scrollView.contentOffset.y + topInset) * scale * zoomScale
        
        let cropWidth = self.cropFrameLength * scale * zoomScale
        let cropHeight = self.cropFrameLength * scale * zoomScale
        
        // Crop.
        let croppedImage = imageOnScreen.crop(cropX, cropY: cropY, cropWidth: cropWidth, cropHeight: cropHeight)
        // Scale
        let scaledImage = croppedImage.scale(400.0, height: 400.0, scale: croppedImage.scale)
        self.finalImage = scaledImage
        
        self.uploadImageS3()
        //self.performSegueWithIdentifier("segueToTestVc", sender: self)
        
    }
    
    // MARK: AWS
    
    private func uploadImageS3() {
//        guard let finalImage = self.finalImage,
//            let imageData = UIImageJPEGRepresentation(finalImage, 0.6) else {
//                return
//        }
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        AWSClientManager.defaultClientManager().uploadImageS3(
//            imageData,
//            isProfilePic: true,
//            progressBlock: {
//                (localContent: AWSLocalContent, progress: NSProgress) in
//                return
//            },
//            completionHandler: {
//                (task: AWSTask) in
//                if let error = task.error {
//                    dispatch_async(dispatch_get_main_queue(), {
//                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                        print(error)
//                    })
//                } else if let imageKey = task.result as? String {
//                    
//                    // 1. Async delete oldProfilePicUrl.
//                    //                        if let oldProfilePicUrl = AWSClientManager.defaultClientManager().currentUser?.profilePicUrl {
//                    //                            self.deleteProfilePic(oldProfilePicUrl)
//                    //                        }
//                    //
//                    //                        // 2. Async update UserPool and DynamoDB.
//                    //                        self.updateProfilePic(imageKey)
//                    //
//                    //                        // 3. Update local currentUser profilePicUrl.
//                    //                        AWSClientManager.defaultClientManager().currentUser?.profilePicUrl = imageKey
//                    
//                    dispatch_async(dispatch_get_main_queue(), {
//                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                        print("Success!")
//                    })
//                } else {
//                    dispatch_async(dispatch_get_main_queue(), {
//                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                        print("This should not happen!")
//                    })
//                }
//                return nil
//        })
    }
    
    // Background.
    private func updateProfilePic(profilePicUrl: String?) {
        AWSClientManager.defaultClientManager().updateProfilePic(
            profilePicUrl,
            completionHandler: {
                (task: AWSTask) in
                return nil
        })
    }
    
    // Background.
    private func deleteProfilePic(oldProfilePicUrl: String) {
        AWSClientManager.defaultClientManager().deleteImageS3(oldProfilePicUrl, completionHandler: {
            (task: AWSTask) in
            return nil
        })
    }
}

extension PreviewProfilePicViewController: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}