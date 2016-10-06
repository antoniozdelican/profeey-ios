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
    @IBOutlet weak var cameraWindowSubViewAspectRatioConstraint: NSLayoutConstraint!
    
    fileprivate var capturedPhoto: UIImage?
    var captureDelegate: CaptureDelegate?
    var isProfilePic: Bool = false
    var profilePicUnwind: ProfilePicUnwind?
    
    fileprivate var imagePickerController: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Bundle.main.loadNibNamed("CameraOverlayView", owner: self, options: nil)
        if self.isProfilePic {
            self.configureSquareAspectRatio()
        }
        self.configureCamera()
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return .portrait
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureCamera() {
        // Check if camera exists.
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.imagePickerController = UIImagePickerController()
            self.imagePickerController.modalPresentationStyle = UIModalPresentationStyle.currentContext
            self.imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = false
            self.imagePickerController.showsCameraControls = false
            self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.off
            
            self.cameraOverlayView.frame = self.imagePickerController.cameraOverlayView!.frame
            self.imagePickerController.cameraOverlayView = self.cameraOverlayView
            self.cameraOverlayView = nil
            
            self.addChildViewController(self.imagePickerController)
            self.imagePickerController.view.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
            self.view.insertSubview(self.imagePickerController.view, at: 0)
            self.imagePickerController.didMove(toParentViewController: self)
        } else {
            // Disable buttons.
            self.flashButton.isEnabled = false
            self.cameraSwitchButton.isEnabled = false
            self.captureButton.isEnabled = false
            // Present empty camera overlay view.
            self.cameraOverlayView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
            self.view.insertSubview(self.cameraOverlayView, at: 0)
            // Present alert.
            let alertController = self.getSimpleAlertWithTitle("No camera", message: "Your device doesn't have a camera.", cancelButtonTitle: "Ok")
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func configureSquareAspectRatio() {
        self.cameraWindowSubViewAspectRatioConstraint.isActive = false
        let squareConstraint = NSLayoutConstraint(
            item: self.cameraWindowSubView,
            attribute: NSLayoutAttribute.height,
            relatedBy: NSLayoutRelation.equal,
            toItem: self.cameraWindowSubView,
            attribute: NSLayoutAttribute.width,
            multiplier: 1.0,
            constant: 0.0)
        squareConstraint.isActive = true
        
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? PreviewViewController {
            childViewController.capturedPhoto = self.capturedPhoto
            self.capturedPhoto = nil
            childViewController.isPhoto = true
            childViewController.isProfilePic = self.isProfilePic
            childViewController.profilePicUnwind = self.profilePicUnwind
        }
    }
    
    // MARK: IBActions
    
    @IBAction func captureButtonTapped(_ sender: AnyObject) {
        self.imagePickerController.takePicture()
    }
    
    @IBAction func flashButtonTapped(_ sender: AnyObject) {
        guard self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDevice.rear else {
            return
        }
        if self.imagePickerController.cameraFlashMode == UIImagePickerControllerCameraFlashMode.on {
            self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.off
            self.flashButton.setImage(UIImage(named: "ic_flash_black"), for: UIControlState())
            
        } else if self.imagePickerController.cameraFlashMode == UIImagePickerControllerCameraFlashMode.off {
            self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.on
            self.flashButton.setImage(UIImage(named: "ic_flash_orange"), for: UIControlState())
        }
    }
    
    
    @IBAction func switchCameraButtonTapped(_ sender: AnyObject) {
        if self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDevice.rear {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.front
            UIView.animate(
                withDuration: 0.0,
                delay: 0.5,
                options: [],
                animations: {
                    self.flashButton.alpha = 0.0
                }, completion: nil)
        } else {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.rear
            UIView.animate(
                withDuration: 0.0,
                delay: 0.5,
                options: [],
                animations: {
                    self.flashButton.alpha = 1.0
                }, completion: nil)
        }
    }
    
    @IBAction func galleryButtonTapped(_ sender: AnyObject) {
        self.captureDelegate?.galleryButtonTapped()
    }
    
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CaptureViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var capturedPhoto = UIImage()
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Flip image if front camera.
            if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDevice.front) && (image.cgImage != nil) {
                capturedPhoto = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
            } else {
                capturedPhoto = image
            }
        }
        // If it's profilePic, make it square!
        if self.isProfilePic {
            self.capturedPhoto = capturedPhoto.crop(0.0, cropY: 0.0, cropWidth: capturedPhoto.size.width, cropHeight: capturedPhoto.size.width)
        } else {
          self.capturedPhoto = capturedPhoto
        }
        self.performSegue(withIdentifier: "segueToPreviewVc", sender: self)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
