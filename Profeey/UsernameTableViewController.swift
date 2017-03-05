//
//  UsernameTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import PhotosUI
import AWSMobileHubHelper
import AWSCognitoIdentityProvider
import AWSDynamoDB

class UsernameTableViewController: UITableViewController {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameBoxView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    
    fileprivate var userPool: AWSCognitoIdentityUserPool?
    fileprivate var newProfilePicImageData: Data?
    
    var isUserPoolUser: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.profilePicImageView.layer.cornerRadius = 4.0
        
        self.usernameTextField.delegate = self
        self.usernameBoxView.layer.cornerRadius = 4.0
        
        self.continueButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.normal)
        self.continueButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.highlighted)
        self.continueButton.setBackgroundImage(UIImage(named: "btn_white_not_active_resizable"), for: UIControlState.disabled)
        self.continueButton.setTitleColor(Colors.turquoise, for: UIControlState.normal)
        self.continueButton.setTitleColor(Colors.turquoise.withAlphaComponent(0.2), for: UIControlState.highlighted)
        self.continueButton.setTitleColor(UIColor.white, for: UIControlState.disabled)
        self.continueButton.isEnabled = false
        
        // Check if it's a userPool User.
        if self.isUserPoolUser {
           self.userPool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.usernameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? CaptureScrollViewController {
            childViewController.isProfilePic = true
            childViewController.profilePicUnwind = ProfilePicUnwind.usernameVc
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func profilePicImageViewTapped(_ sender: Any) {
        self.usernameTextField.resignFirstResponder()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let removePhotoAction = UIAlertAction(title: "Remove Photo", style: UIAlertActionStyle.destructive, handler: {
            (alert: UIAlertAction) in
            self.newProfilePicImageData = nil
            self.profilePicImageView.image = UIImage(named: "ic_add_profile_pic")
        })
        alertController.addAction(removePhotoAction)
        let changePhotoAction = UIAlertAction(title: "Add Profile Photo", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
            // Check Photos access for the first time. This can happen on MainTabBarVc, UsernameVc, ProfileVc and EditVc.
            if PHPhotoLibrary.authorizationStatus() == .notDetermined {
                PHPhotoLibrary.requestAuthorization({
                    (status: PHAuthorizationStatus) in
                    self.performSegue(withIdentifier: "segueToCaptureVc", sender: self)
                })
            } else {
                self.performSegue(withIdentifier: "segueToCaptureVc", sender: self)
            }
        })
        alertController.addAction(changePhotoAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func usernameTextFieldChanged(_ sender: Any) {
        guard let preferredUsername = self.usernameTextField.text?.trimm(), !preferredUsername.isEmpty else {
            self.continueButton.isEnabled = false
            return
        }
        self.continueButton.isEnabled = true
    }
    
    
    @IBAction func continueButtonTapped(_ sender: AnyObject) {
        UIView.transition(
            with: self.continueButton,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: {
                self.continueButton.isHighlighted = true
        },
            completion: nil)
        self.view.endEditing(true)
        // CHECK IF IT IS Facebook user or UserPool!
        self.queryPreferredUsernames()
    }
    
    @IBAction func unwindToUsernameTableViewController(_ segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? PreviewViewController {
            guard let finalImage = sourceViewController.finalImage,
                let imageData = UIImageJPEGRepresentation(finalImage, 0.6)  else {
                    return
            }
            self.newProfilePicImageData = imageData
            self.profilePicImageView.image = finalImage
        }
    }
    
    // MARK: AWS
    
    // Check if preferredUsername already exists in DynamoDB. This is before any other action.
    fileprivate func queryPreferredUsernames() {
        guard let preferredUsername = self.usernameTextField.text?.trimm(), !preferredUsername.isEmpty else {
            return
        }
        print("queryPreferredUsernames:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().queryPreferredUsernamesDynamoDB(preferredUsername, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error as? NSError {
                    FullScreenIndicator.hide()
                    print("queryPreferredUsernames error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["__type"] as? String, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    guard response == nil || response?.items.count == 0 else {
                        FullScreenIndicator.hide()
                        let alertController = self.getSimpleAlertWithTitle("Username exists", message: "This username already belongs to another account. Please choose a different one and try again.", cancelButtonTitle: "Try Again")
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    // 2. updatePreferredUsername if isUserPoolUser, else go to updateUser.
                    if self.isUserPoolUser {
                        self.userPoolUpdatePreferredUsername()
                    } else {
                        // 3a. Store profilePic if exists and update in DynamoDB with preferredUsername.
                        if let profilePicImageData = self.newProfilePicImageData {
                            self.uploadImage(preferredUsername, imageData: profilePicImageData)
                        } else {
                            self.updateUser(preferredUsername, profilePicUrl: nil)
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func userPoolUpdatePreferredUsername() {
        guard let preferredUsername = self.usernameTextField.text?.trimm(), !preferredUsername.isEmpty else {
            return
        }
        var userAttributes: [AWSCognitoIdentityUserAttributeType] = []
        userAttributes.append(AWSCognitoIdentityUserAttributeType(name: "preferred_username", value: preferredUsername))
        
        print("userPoolUpdatePreferredUsername:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.userPool?.currentUser()?.update(userAttributes).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error as? NSError {
                    FullScreenIndicator.hide()
                    print("userPoolUpdatePreferredUsername error: \(error)")
                    // Error handling.
                    var title: String = "Something went wrong"
                    var message: String? = "Please try again."
                    if let type = error.userInfo["__type"] as? String {
                        switch type {
                        case "AliasExistsException":
                            title = "Username exists"
                            message = "This username already belongs to another account. Please choose a different one and try again."
                        default:
                            title = type
                            message = error.userInfo["message"] as? String
                        }
                    }
                    let alertController = self.getSimpleAlertWithTitle(title, message: message, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // 3. Stored profilePic if exists and update in DynamoDB with preferredUsername.
                    if let profilePicImageData = self.newProfilePicImageData {
                        self.uploadImage(preferredUsername, imageData: profilePicImageData)
                    } else {
                        self.updateUser(preferredUsername, profilePicUrl: nil)
                    }
                }
            })
            return nil
        })
    }
    
    fileprivate func updateUser(_ preferredUsername: String, profilePicUrl: String?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().updateUserPreferredUsernameAndProfilePicDynamoDB(preferredUsername, profilePicUrl: profilePicUrl, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("saveUser error: \(error)")
                    let alertController = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "segueToWelcomeSchoolsVc", sender: self)
                }
            })
            return nil
        })
    }
    
    fileprivate func uploadImage(_ preferredUsername: String, imageData: Data) {
        let uniqueImageName = NSUUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let imageKey = "public/profile_pics/\(uniqueImageName).jpg"
        let localContent = AWSUserFileManager.defaultUserFileManager().localContent(with: imageData, key: imageKey)
        
        print("uploadImageS3:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        localContent.uploadWithPin(
            onCompletion: true,
            progressBlock: {
                (content: AWSLocalContent?, progress: Progress?) -> Void in
                // Do nothing.
            }, completionHandler: {
                (content: AWSLocalContent?, error: Error?) -> Void in
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let error = error {
                        FullScreenIndicator.hide()
                        print("uploadImageS3 error: \(error)")
                        let alertController = self.getSimpleAlertWithTitle("Upload image failed", message: error.localizedDescription, cancelButtonTitle: "Try Again")
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.updateUser(preferredUsername, profilePicUrl: imageKey)
                    }
                })
        })
    }
}

extension UsernameTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
