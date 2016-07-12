//
//  CaptureProfilePhotoViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 01/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class CaptureProfilePhotoViewController: UIViewController {
    
    @IBOutlet weak var cropImageView: UIImageView!
    @IBOutlet weak var switchCameraButton: UIBarButtonItem!
    @IBOutlet weak var captureButton: UIButton!
    
    var camera: ProfeeySimpleCamera!
    var capturedPhoto: UIImage!
    var previewProfilePicDelegate: PreviewProfilePicDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove text from backButton on proceeding Vc.
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        // Set up the cropImageView.
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

        // Set up the camera.
        self.camera = ProfeeySimpleCamera(quality: AVCaptureSessionPresetHigh, position: LLCameraPositionRear, videoEnabled: true)
        let rect = CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height)
        self.camera.attachToViewController(self, withFrame: rect)
        self.camera.fixOrientationAfterCapture = true
        // Disable buttons if camera not available.
        guard ProfeeySimpleCamera.isFrontCameraAvailable() && ProfeeySimpleCamera.isRearCameraAvailable() else {
            self.captureButton.enabled = false
            self.switchCameraButton.enabled = false
//            self.flashButton.enabled = false
            let alertController = UIAlertController(title: "Camera error", message: "You must have a camera to take video.", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        // Check for errors.
        self.camera.onError = {
            (camera, error) -> Void in
            NSLog("Camera error: %@", error)
            if (error.domain == LLSimpleCameraErrorDomain) {
                if UInt(error.code) == LLSimpleCameraErrorCodeCameraPermission.rawValue || UInt(error.code) == LLSimpleCameraErrorCodeMicrophonePermission.rawValue {
                    let alertController = UIAlertController(title: "Check permissions", message: "We need permission for the camera and microphone.", preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
                    alertController.addAction(alertAction)
                    // Provide quick access to Settings.
                    // NOTE: HAVE TO HANDLE WHEN USER ACTUALLY CHANGES SETTINGS AND APP IS RUNNING
                    let settingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default) {
                        action in
                        UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
                    }
                    alertController.addAction(settingsAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    self.switchCameraButton.enabled = false
//                    self.flashButton.enabled = false
                    self.captureButton.enabled = false
                }
            }
        }
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? PreviewProfilePhotoViewController {
            destinationViewController.photo = self.capturedPhoto.fixOrientation()
            destinationViewController.previewProfilePicDelegate = self.previewProfilePicDelegate
        }
    }
    
    // MARK: IBActions
    
    @IBAction func captureButtonTapped(sender: AnyObject) {
        // Capture photo.
        self.camera.capture({
            (camera, image, metadata, error) -> Void in
            if error == nil {
                self.capturedPhoto = self.cropImage(image)
                self.performSegueWithIdentifier("segueToPreviewProfilePhotoVc", sender: self)
            } else {
                NSLog("An error has occured: %@", error)
            }
            }, exactSeenImage: true)
    }
    
    @IBAction func switchCameraButtonTapped(sender: AnyObject) {
        self.camera.togglePosition()
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Helpers
    
    private func cropImage(image: UIImage) -> UIImage {
        
        let originalWidht = image.size.width
        let originalHeight = image.size.height
        
        let cropWidth = originalWidht - 2 * 10.0 // edges from each side
        let cropHeight = cropWidth
        let cropX: CGFloat = 10.0
        let cropY = (originalHeight - cropHeight) / 2
        let cropRect = CGRectMake(cropX, cropY, cropWidth, cropHeight)
        
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
