//
//  CaptureViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol CaptureDelegate {
    func galleryButtonTapped()
}

class CaptureViewController: UIViewController {
    
    
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cameraSwitchButton: UIBarButtonItem!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet var cameraOverlayView: UIView!
    @IBOutlet weak var cameraWindowSubView: UIView!
    
    private var capturedPhoto: UIImage?
    var captureDelegate: CaptureDelegate?
    
    private var imagePickerController: UIImagePickerController!
    private var isCameraAvailable: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSBundle.mainBundle().loadNibNamed("CameraOverlayView", owner: self, options: nil)
        self.configureCamera()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !self.isCameraAvailable {
            // Disable buttons.
            self.flashButton.enabled = false
            self.cameraSwitchButton.enabled = false
            self.captureButton.enabled = false
            // Present empty camera overlay view.
            self.cameraOverlayView.frame = CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height)
            self.view.insertSubview(self.cameraOverlayView, atIndex: 0)
            // Present alert.
            let alertController = self.getSimpleAlertWithTitle("No camera", message: "Your device doesn't have a camera.", cancelButtonTitle: "Ok")
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureCamera() {
        // Check if camera exists.
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.imagePickerController = UIImagePickerController()
            self.imagePickerController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            self.imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = false
            self.imagePickerController.showsCameraControls = false
            self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.Off
            
            self.cameraOverlayView.frame = self.imagePickerController.cameraOverlayView!.frame
            self.imagePickerController.cameraOverlayView = self.cameraOverlayView
            self.cameraOverlayView = nil
            
            self.addChildViewController(self.imagePickerController)
            self.imagePickerController.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height)
            self.view.insertSubview(self.imagePickerController.view, atIndex: 0)
            self.imagePickerController.didMoveToParentViewController(self)
        } else {
            self.isCameraAvailable = false
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? PreviewViewController {
            childViewController.capturedPhoto = self.capturedPhoto
            self.capturedPhoto = nil
            childViewController.isPhoto = true
        }
    }
    
    // MARK: IBActions
    
    @IBAction func captureButtonTapped(sender: AnyObject) {
        self.imagePickerController.takePicture()
    }
    
    @IBAction func flashButtonTapped(sender: AnyObject) {
        guard self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDevice.Rear else {
            return
        }
        if self.imagePickerController.cameraFlashMode == UIImagePickerControllerCameraFlashMode.On {
            self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.Off
            self.flashButton.setImage(UIImage(named: "ic_flash_black"), forState: UIControlState.Normal)
            
        } else if self.imagePickerController.cameraFlashMode == UIImagePickerControllerCameraFlashMode.Off {
            self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.On
            self.flashButton.setImage(UIImage(named: "ic_flash_orange"), forState: UIControlState.Normal)
        }
    }
    
    
    @IBAction func switchCameraButtonTapped(sender: AnyObject) {
        if self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDevice.Rear {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.Front
            UIView.animateWithDuration(
                0.0,
                delay: 0.5,
                options: [],
                animations: {
                    self.flashButton.alpha = 0.0
                }, completion: nil)
        } else {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.Rear
            UIView.animateWithDuration(
                0.0,
                delay: 0.5,
                options: [],
                animations: {
                    self.flashButton.alpha = 1.0
                }, completion: nil)
        }
    }
    
    @IBAction func galleryButtonTapped(sender: AnyObject) {
        self.captureDelegate?.galleryButtonTapped()
    }
    
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CaptureViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var capturedPhoto = UIImage()
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Flip image if front camera.
            if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDevice.Front) && (image.CGImage != nil) {
                capturedPhoto = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation: .LeftMirrored)
            } else {
                capturedPhoto = image
            }
        }
        self.capturedPhoto = capturedPhoto
        self.performSegueWithIdentifier("segueToPreviewVc", sender: self)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
