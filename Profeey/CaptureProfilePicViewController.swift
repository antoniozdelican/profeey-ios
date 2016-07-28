//
//  CaptureProfilePicViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class CaptureProfilePicViewController: UIViewController {

    @IBOutlet weak var switchCameraButton: UIBarButtonItem!
    @IBOutlet weak var captureButton: UIButton!
    
    var camera: ProfeeySimpleCamera!
    var profilePic: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the cropImageView depending on the device.
//        let screenHeight: NSNumber = UIScreen.mainScreen().bounds.height
//        switch screenHeight {
//        case 568: // iPhone 5, 5s, SE
//            self.cropImageView.image = UIImage(named: "bg_crop_568h")
//        case 667: // iPhone 6, 6s
//            self.cropImageView.image = UIImage(named: "bg_crop_667h")
//        case 736: // iPhone 6 Plus, 6s Plus
//            self.cropImageView.image = UIImage(named: "bg_crop_736h")
//        default: // unknown
//            self.cropImageView.image = UIImage(named: "bg_crop_736h")
//        }
        
        // Set up the camera.
        self.configureCamera()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.camera.start()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.camera.view.frame = self.view.bounds
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func configureCamera() {
        self.camera = ProfeeySimpleCamera(quality: AVCaptureSessionPresetHigh, position: LLCameraPositionRear, videoEnabled: true)
        let rect = CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height)
        self.camera.attachToViewController(self, withFrame: rect)
        self.camera.fixOrientationAfterCapture = true
        
        // Disable buttons if camera not available.
        guard ProfeeySimpleCamera.isFrontCameraAvailable() && ProfeeySimpleCamera.isRearCameraAvailable() else {
            self.captureButton.enabled = false
            self.switchCameraButton.enabled = false
            let alertController = UIAlertController(title: "Camera error", message: "You must have a camera to take video.", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        // Check for errors.
        self.camera.onError = {
            (camera, error) -> Void in
            print("Camera error: \(error)")
            if (error.domain == LLSimpleCameraErrorDomain) {
                if UInt(error.code) == LLSimpleCameraErrorCodeCameraPermission.rawValue || UInt(error.code) == LLSimpleCameraErrorCodeMicrophonePermission.rawValue {
                    let alertController = UIAlertController(title: "Check permissions", message: "We need permission for the camera and microphone.", preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
                    alertController.addAction(alertAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    self.switchCameraButton.enabled = false
                    self.captureButton.enabled = false
                }
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? PreviewViewController {
            destinationViewController.photo = self.profilePic?.fixOrientation()
            destinationViewController.isPhoto = true
        }
    }
    
    // MARK: IBActions
    
    @IBAction func captureButtonTapped(sender: AnyObject) {
        self.camera.capture({
            (camera, image, metadata, error) -> Void in
            if error == nil {
                self.profilePic = image
                self.performSegueWithIdentifier("segueToPreviewVc", sender: self)
            } else {
                print("An error has occured: \(error)")
            }
            }, exactSeenImage: true)
    }
    
    @IBAction func switchCameraButtonTapped(sender: AnyObject) {
        self.camera.togglePosition()
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func cropImage(image: UIImage) -> UIImage {
        
        let originalWidht = image.size.width
        let originalHeight = image.size.height
        
        let cropWidth = originalWidht - 2 * 10.0 // edges from each side
        let cropHeight = cropWidth
        let cropX: CGFloat = 10.0
        let cropY = (originalHeight - cropHeight) / 2
        let cropRect = CGRectMake(cropX, cropY, cropWidth, cropHeight)
        
        //return image.crop(cropX, cropY: cropY, cropWidth: cropWidth, cropHeight: cropHeight)
        
        // Not sure about scale.
        // UIScreen.mainScreen().scale
        var newImage = image
        let cgiImage = image.CGImage
        if let imageRef = CGImageCreateWithImageInRect(cgiImage, cropRect) {
            newImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        }
        return newImage
    }
    
}
