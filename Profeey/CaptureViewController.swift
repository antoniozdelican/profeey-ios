//
//  CaptureViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 19/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class CaptureViewController: UIViewController {
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIBarButtonItem!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var customToolbarView: UIView!
    
    var camera: ProfeeySimpleCamera!
    var cameraFrame: CGRect!
    var photo: UIImage?
    var photoButtonActive: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.switchCameraButton.image = UIImage(named: "btn_camera_switch")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.closeButton.image = UIImage(named: "btn_close")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)

        self.camera = ProfeeySimpleCamera(quality: AVCaptureSessionPresetHigh, position: LLCameraPositionRear, videoEnabled: true)
//        self.cameraFrame = CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height - self.customToolbarView.bounds.height)
        self.cameraFrame = CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height)
        self.camera.attachToViewController(self, withFrame: cameraFrame)
        self.camera.fixOrientationAfterCapture = false
        
        // Disable buttons if camera not available.
        guard ProfeeySimpleCamera.isFrontCameraAvailable() && ProfeeySimpleCamera.isRearCameraAvailable() else {
            self.captureButton.enabled = false
            self.switchCameraButton.enabled = false
            self.flashButton.enabled = false
            let alertController = UIAlertController(title: "Camera error", message: "You must have a camera to take video.", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        // Toggle flash button on camera switch.
        self.camera.onDeviceChange = {
            (camera, device) -> Void in
            if camera.isFlashAvailable() {
                self.flashButton.hidden = false
                if camera.flash == LLCameraFlashOff {
                    self.flashButton.selected = false
                }
                else {
                    self.flashButton.selected = true
                }
            }
            else {
                self.flashButton.hidden = true
            }
        }
        
        // Check for errors.
        self.camera.onError = {
            (camera, error) -> Void in
            print("Camera error: \(error.localizedDescription)")
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
                    self.flashButton.enabled = false
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
        if let destinationViewController = segue.destinationViewController as? PreviewViewController2 {
            destinationViewController.photo = self.photo?.fixOrientation()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func captureButtonTapped(sender: AnyObject) {
        if self.photoButtonActive {
            // Capture photo.
            self.camera.capture({
                (camera, image, metadata, error) -> Void in
                if error == nil {
                    self.photo = image
                    self.performSegueWithIdentifier("segueToPreviewVc", sender: self)
                } else {
                    print("Capture error: \(error.localizedDescription)")
                }
                }, exactSeenImage:true)
            
        }
    }
    
    @IBAction func switchCameraButtonTapped(sender: AnyObject) {
        self.camera.togglePosition()
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
