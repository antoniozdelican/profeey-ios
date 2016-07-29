//
//  CaptureProfilePicViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol CaptureDelegate {
    func galleryButtonTapped()
}

class CaptureProfilePicViewController: UIViewController {

    @IBOutlet weak var switchCameraButton: UIBarButtonItem!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    var camera: ProfeeySimpleCamera!
    var profilePic: UIImage?
    var captureDelegate: CaptureDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureButtons()
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
    
    // MARK: Configure
    
    private func configureButtons() {
        self.switchCameraButton.image = UIImage(named: "btn_camera_switch")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.closeButton.image = UIImage(named: "btn_close_white")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
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
        if let navigationController = segue.destinationViewController as? UINavigationController,
        let childViewController = navigationController.childViewControllers[0] as? PreviewViewController {
            childViewController.photo = self.profilePic?.fixOrientation()
            childViewController.isPhoto = true
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
    
    @IBAction func galleryButtonTapped(sender: AnyObject) {
        self.captureDelegate?.galleryButtonTapped()
    }
    
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
