//
//  CameraViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate: class {
    func galleryButtonTapped()
    func didSelectPhoto(photo: UIImage)
    func flashTypeChangedInto(_ flashType: FlashType)
    func toggleFlashBarButton(_ isVisible: Bool)
}

class CameraViewController: UIViewController {
    
    // Camera No Access views.
    @IBOutlet var cameraNoAccessView: UIView!
    @IBOutlet weak var noAccessTitleLabel: UILabel!
    @IBOutlet weak var noAccessTextLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var noAccessWindowSubView: UIView!
    @IBOutlet weak var noAccessWindowSubViewAspectRatioConstraint: NSLayoutConstraint!
    
    // Camera Overlay views.
    @IBOutlet var cameraOverlayView: UIView!
    @IBOutlet weak var cameraWindowSubView: UIView!
    @IBOutlet weak var cameraWindowSubViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    
    weak var cameraViewControllerDelegate: CameraViewControllerDelegate?
    var isProfilePic: Bool = false
    
    fileprivate var imagePickerController: UIImagePickerController!
    fileprivate var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Bundle.main.loadNibNamed("CameraNoAccessView", owner: self, options: nil)
        Bundle.main.loadNibNamed("CameraOverlayView", owner: self, options: nil)
        
        // Determine if camera is supported and authorization status.
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.configureNoAccessView(false)
        } else {
            switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
            case .authorized:
                self.configureCamera()
            case .denied, .restricted:
                self.configureNoAccessView(true)
            default:
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Determine if authorization status is not yet determined.
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .notDetermined {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {
                    (granted: Bool) in
                    DispatchQueue.main.async(execute: {
                        if granted {
                            self.configureCamera()
                        } else {
                            self.configureNoAccessView(true)
                        }
                    })
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureCamera() {
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.modalPresentationStyle = UIModalPresentationStyle.currentContext
        self.imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = false
        self.imagePickerController.showsCameraControls = false
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.auto
        
        // Setting cameraOverlay.
        if self.isProfilePic {
            self.configureSquareAspectRatio(self.cameraWindowSubViewAspectRatioConstraint, windowSubView: self.cameraWindowSubView)
        }
        self.cameraOverlayView.frame = self.imagePickerController.cameraOverlayView!.frame
        self.imagePickerController.cameraOverlayView = self.cameraOverlayView
        self.cameraOverlayView = nil
        
        // Setting child-parent relationship.
        self.addChildViewController(self.imagePickerController)
        self.imagePickerController.view.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.insertSubview(self.imagePickerController.view, at: 0)
        self.imagePickerController.didMove(toParentViewController: self)
    }
    
    fileprivate func configureNoAccessView(_ isCameraSupported: Bool) {
        if self.isProfilePic {
            self.configureSquareAspectRatio(self.noAccessWindowSubViewAspectRatioConstraint, windowSubView: self.noAccessWindowSubView)
        }
        if isCameraSupported {
            self.noAccessTitleLabel.text = "Profeey doesn't have access to your camera."
            self.noAccessTextLabel.text = "But that's easy to fix! Just go to settings and switch Camera to green."
            self.settingsButton.isHidden = false
        } else {
            self.noAccessTitleLabel.text = "Your device doesn't have a camera."
            self.noAccessTextLabel.text = "But no worries! You can still choose photos from your library."
            self.settingsButton.isHidden = true
        }
        self.cameraNoAccessView.frame = self.view.bounds
        self.view.addSubview(self.cameraNoAccessView)
        // Remove flash button.
        self.cameraViewControllerDelegate?.toggleFlashBarButton(false)
    }
    
    fileprivate func configureSquareAspectRatio(_ windowSubViewAspectRatioConstraint: NSLayoutConstraint, windowSubView: UIView) {
        windowSubViewAspectRatioConstraint.isActive = false
        let squareConstraint = NSLayoutConstraint(
            item: windowSubView,
            attribute: NSLayoutAttribute.height,
            relatedBy: NSLayoutRelation.equal,
            toItem: windowSubView,
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
    
    @IBAction func cameraSwitchButtonTapped(_ sender: AnyObject) {
        if self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDevice.rear {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.front
        } else {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.rear
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: AnyObject) {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(url)
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

extension CameraViewController: FlashSwitchDelegate {
    
    func flashBarButtonTapped() {
        switch self.imagePickerController.cameraFlashMode {
        case UIImagePickerControllerCameraFlashMode.auto:
            self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.on
            self.cameraViewControllerDelegate?.flashTypeChangedInto(FlashType.on)
        case UIImagePickerControllerCameraFlashMode.on:
            self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.off
            self.cameraViewControllerDelegate?.flashTypeChangedInto(FlashType.off)
        case UIImagePickerControllerCameraFlashMode.off:
            self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.auto
            self.cameraViewControllerDelegate?.flashTypeChangedInto(FlashType.auto)
        }
    }
}
