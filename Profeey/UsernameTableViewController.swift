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
    @IBOutlet weak var invalidPreferredUsernameMessageLabel: UILabel!
    @IBOutlet weak var invalidPreferredUsernameBoxView: UIView!
    
    fileprivate var userPool: AWSCognitoIdentityUserPool?
    fileprivate var newProfilePicImageData: Data?
    fileprivate var cleanPreferredUsername: String?
    fileprivate var shouldShowInvalidMessage: Bool = false
    
    var isUserPoolUser: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.profilePicImageView.layer.cornerRadius = 4.0
        
        self.usernameTextField.delegate = self
        self.usernameBoxView.layer.cornerRadius = 4.0
        self.usernameBoxView.layer.borderWidth = 0.5
        self.usernameBoxView.layer.borderColor = UIColor.clear.cgColor
        
        self.continueButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.normal)
        self.continueButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.highlighted)
        self.continueButton.setBackgroundImage(UIImage(named: "btn_white_not_active_resizable"), for: UIControlState.disabled)
        self.continueButton.setTitleColor(Colors.turquoise, for: UIControlState.normal)
        self.continueButton.setTitleColor(Colors.turquoise.withAlphaComponent(0.2), for: UIControlState.highlighted)
        self.continueButton.setTitleColor(UIColor.white, for: UIControlState.disabled)
        self.continueButton.isEnabled = false
        self.invalidPreferredUsernameMessageLabel.text = "Your username must be 30 characters or less and contain only letters, numbers, periods and underscores."
        self.invalidPreferredUsernameBoxView.layer.cornerRadius = 4.0
        
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
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 202.0
        case 1:
            return 41.0
        case 2:
            return 68.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 202.0
        case 1:
            return self.shouldShowInvalidMessage ? UITableViewAutomaticDimension : 0.0
        case 2:
            return 68.0
        default:
            return 0.0
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
        // 1. Replace " " with "_" while typing.
        guard let preferredUsername = self.usernameTextField.text?.replacingOccurrences(of: " ", with: "_"), !preferredUsername.isEmpty else {
            self.cleanPreferredUsername = nil
            self.continueButton.isEnabled = false
            self.removeInvalidMessage()
            return
        }
        self.usernameTextField.text = preferredUsername
        // 2. Check if less than 30 characters
        guard preferredUsername.characters.count <= 30 else {
            self.cleanPreferredUsername = nil
            self.continueButton.isEnabled = false
            self.showInvalidMessage("Your username must be 30 characters or less and contain only letters, numbers, periods and underscores.")
            return
        }
        // 3. Check regex.
        guard self.isValidPreferredUsername(preferredUsername) else {
            self.cleanPreferredUsername = nil
            self.continueButton.isEnabled = false
            self.showInvalidMessage("Your username can contain only letters, numbers, periods and underscores.")
            return
        }
        self.removeInvalidMessage()
        // 4. Put characters lowercase and enable button.
        self.cleanPreferredUsername = preferredUsername.lowercased()
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
        
        if let cleanPreferredUsername = self.cleanPreferredUsername {
            self.view.endEditing(true)
            self.queryPreferredUsernames(cleanPreferredUsername)
        }
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
    
    // MARK: Helpers
    
    /*
     - preferredUsername must be 30 characters or less and contain only letters, numbers, periods and underscores
     - if the letter was uppercase, turn it into lowercase always
     - while typing space, make an underscore instead
    */
    
    fileprivate func isValidPreferredUsername(_ preferredUsername: String) -> Bool {
        var returnValue = true
        let preferredUsernameRegex = "^[a-zA-Z0-9_.]{1,30}$"
        do {
            let regex = try NSRegularExpression(pattern: preferredUsernameRegex)
            let nsString = preferredUsername as NSString
            let results = regex.matches(in: preferredUsername, range: NSRange(location: 0, length: nsString.length))
            if results.count == 0 {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        return  returnValue
    }
    
    fileprivate func removeInvalidMessage() {
        if self.shouldShowInvalidMessage {
            self.shouldShowInvalidMessage = false
            self.usernameBoxView.layer.borderColor = UIColor.clear.cgColor
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    fileprivate func showInvalidMessage(_ text: String) {
        if !self.shouldShowInvalidMessage {
            self.shouldShowInvalidMessage = true
            self.invalidPreferredUsernameMessageLabel.text = text
            self.usernameBoxView.layer.borderColor = Colors.red.cgColor
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    // MARK: AWS
    
    // Check if preferredUsername already exists in DynamoDB. This is before any other action.
    fileprivate func queryPreferredUsernames(_ preferredUsername: String) {
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
                        self.userPoolUpdatePreferredUsername(preferredUsername)
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
    
    fileprivate func userPoolUpdatePreferredUsername(_ preferredUsername: String) {
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
        if let cleanPreferredUsername = self.cleanPreferredUsername, isValidPreferredUsername(cleanPreferredUsername) {
            self.view.endEditing(true)
            self.queryPreferredUsernames(cleanPreferredUsername)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.removeInvalidMessage()
        return true
    }
}
