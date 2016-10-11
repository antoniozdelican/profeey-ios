//
//  CameraViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol CameraViewControllerDelegate {
    func galleryButtonTapped()
    func didSelectPhoto(photo: UIImage)
    
}

class CameraViewController: UIViewController {
    
    @IBOutlet var cameraOverlayView: UIView!
    @IBOutlet weak var cameraWindowSubView: UIView!
    @IBOutlet weak var cameraWindowSubViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    
    var cameraViewControllerDelegate: CameraViewControllerDelegate?
    var isProfilePic: Bool = false
    
    fileprivate var imagePickerController: UIImagePickerController!
    fileprivate var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Bundle.main.loadNibNamed("CameraOverlayView", owner: self, options: nil)
        if self.isProfilePic {
            self.configureSquareAspectRatio()
        }
        self.configureCamera()
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
    
    // MARK: IBActions
    
    @IBAction func captureButtonTapped(_ sender: AnyObject) {
        self.imagePickerController.takePicture()
    }
    
    @IBAction func galleryButtonTapped(_ sender: AnyObject) {
        self.cameraViewControllerDelegate?.galleryButtonTapped()
    }
    
    @IBAction func flashButtonTapped(_ sender: AnyObject) {
        guard self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDevice.rear else {
            return
        }
        if self.imagePickerController.cameraFlashMode == UIImagePickerControllerCameraFlashMode.on {
            self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.off
            self.flashButton.setImage(UIImage(named: "ic_flash_white"), for: UIControlState())
            
        } else if self.imagePickerController.cameraFlashMode == UIImagePickerControllerCameraFlashMode.off {
            self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.on
            self.flashButton.setImage(UIImage(named: "ic_flash_orange"), for: UIControlState())
        }
    }
    
    @IBAction func cameraSwitchButtonTapped(_ sender: AnyObject) {
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
    
    
}

extension CameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var photo = UIImage()
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Flip image if front camera.
            if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDevice.front) && (image.cgImage != nil) {
                photo = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
            } else {
                photo = image
            }
        }
        // If it's profilePic, make it square!
        if self.isProfilePic {
            let profilePicPhoto = photo.crop(0.0, cropY: 0.0, cropWidth: photo.size.width, cropHeight: photo.size.width)
            self.cameraViewControllerDelegate?.didSelectPhoto(photo: profilePicPhoto)
        } else {
            self.cameraViewControllerDelegate?.didSelectPhoto(photo: photo)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
