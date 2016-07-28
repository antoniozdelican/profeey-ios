//
//  PreviewViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class PreviewViewController2: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var customToolbarHeightConstraint: NSLayoutConstraint!
    
    // Photo is just used for full screen preview, while croppedPhoto is transfered as real photo.
    var photo: UIImage?
    var croppedPhoto: UIImage?
    var customToolbarHeightConstraintConstant: CGFloat?
    var thumbnailPhoto: UIImage?
    var photoData: NSData?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton.image = UIImage(named: "btn_back")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.photoImageView.image = self.photo
        self.customToolbarHeightConstraintConstant = self.customToolbarHeightConstraint.constant
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? EditTableViewController {
            destinationViewController.thumbnailPhoto = self.thumbnailPhoto?.fixOrientation()
            destinationViewController.photoData = self.photoData
        }
    }
    
    // MARK: IBActions
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        self.setPhoto()
    }
    
    // MARK: Helpers
    
    private func setPhoto() {
        guard let photo = self.photo, let customToolbarHeightConstraintConstant = self.customToolbarHeightConstraintConstant else {
            return
        }
        // Calculate ratio between screen preview and original photo size.
        let ratio = photo.size.height / self.view.bounds.height
        let newConstant = ratio * customToolbarHeightConstraintConstant
        let width = photo.size.width
        let height = photo.size.height - newConstant
        self.croppedPhoto = photo.crop(0.0, cropY: 0.0, cropWidth: width, cropHeight: height)
        self.thumbnailPhoto = self.getThumbnailPhoto(self.croppedPhoto)
        self.photoData = self.getPhotoData(self.croppedPhoto)
        
        print("CROPPED PHOTO SIZE: \(croppedPhoto?.size)")
        print("THUMBNAIL PHOTO SIZE: \(thumbnailPhoto?.size)")
        print("PHOTO DATA: \(photoData?.length)")
        
        self.performSegueWithIdentifier("segueToEditVc", sender: self)
    }
    
    // Use thumbnail to reduce memory impact on next screen!
    private func getThumbnailPhoto(photo: UIImage?) -> UIImage? {
        guard let photo = photo else {
            return nil
        }
        let width = self.view.bounds.width
        let height = width / photo.aspectRatio()
        return photo.scale(width, height: height, scale: 1.0)
    }
    
    private func getPhotoData(photo: UIImage?) -> NSData? {
        guard let photo = photo else {
            return nil
        }
        return UIImageJPEGRepresentation(photo, 0.6)
    }
}
