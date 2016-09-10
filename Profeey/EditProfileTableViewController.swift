//
//  EditProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import MapKit

protocol EditProfileDelegate {
    // Notify profileTableVc that user is updated.
    // Remove profilePic in background on profileTableVc.
    func userUpdated(user: User?, profilePicUrlToRemove: String?)
}

class EditProfileTableViewController: UITableViewController {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var preferredUsernameTextField: UITextField!
    @IBOutlet weak var aboutFakePlaceholderLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var user: User?
    var editProfileDelegate: EditProfileDelegate?
    private var newProfilePicImageData: NSData?
    private var profilePicUrlToRemove: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureProfile()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureProfile() {
        self.profilePicImageView.layer.cornerRadius = 40.0
        self.profilePicImageView.clipsToBounds = true
        self.profilePicImageView.image = self.user?.profilePic
        
        self.firstNameTextField.delegate = self
        self.firstNameTextField.text = self.user?.firstName
        
        self.lastNameTextField.delegate = self
        self.lastNameTextField.text = self.user?.lastName
        
        self.preferredUsernameTextField.delegate = self
        self.preferredUsernameTextField.text = self.user?.preferredUsername
        
        self.aboutTextView.delegate = self
        self.aboutTextView.text = self.user?.about
        self.aboutFakePlaceholderLabel.hidden = !self.aboutTextView.text.isEmpty
        
        if let profession = self.user?.profession {
            self.professionLabel.text = profession
            self.professionLabel.textColor = Colors.black
        }
        
        if let location = self.user?.location {
            self.locationLabel.text = location
            self.locationLabel.textColor = Colors.black
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? LocationTableViewController {
            if self.locationLabel.textColor == Colors.black {
                childViewController.location = self.locationLabel.text
            }
        }
        if let destinationViewController = segue.destinationViewController as? ScrollViewController {
            // Capture.
            destinationViewController.isProfilePic = true
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        guard identifier == "segueToLocationVc" else {
            return true
        }
        // Ask for location authorization.
        let status = CLLocationManager.authorizationStatus()
        if (status == CLAuthorizationStatus.Restricted) || (status == CLAuthorizationStatus.Denied) {
            print("Location Restricted or Denied")
            let alertController = UIAlertController(title: "Enable Location Services", message: "To use location services, please allow it in the Settings", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            let openSettingsAction = UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.Default, handler: {
                (alertAction: UIAlertAction) in
                // Open Settings.
                dispatch_async(dispatch_get_main_queue(), {
                    if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(appSettings)
                    }
                })
            })
            alertController.addAction(cancelAction)
            alertController.addAction(openSettingsAction)
            presentViewController(alertController, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 52.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            self.editProfilePicCellTapped()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        if indexPath.row == 5 || indexPath.row == 6 {
           cell.selectionStyle = UITableViewCellSelectionStyle.Default
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: Tappers
    
    private func editProfilePicCellTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let removePhotoAction = UIAlertAction(title: "Remove Photo", style: UIAlertActionStyle.Destructive, handler: {
            (alert: UIAlertAction) in
            self.newProfilePicImageData = nil
            self.profilePicUrlToRemove = self.user?.profilePicUrl
            self.profilePicImageView.image = nil
            self.tableView.reloadData()
        })
        alertController.addAction(removePhotoAction)
        let changePhotoAction = UIAlertAction(title: "Change Photo", style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction) in
            self.performSegueWithIdentifier("segueToCaptureVc", sender: self)
        })
        alertController.addAction(changePhotoAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: IBActions
    
    @IBAction func unwindToEditProfileTableViewController(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.sourceViewController as? LocationTableViewController {
            guard let location = sourceViewController.location else {
                return
            }
            if location.isEmpty {
                self.locationLabel.text = "Add location"
                self.locationLabel.textColor = Colors.disabled
            } else {
                self.locationLabel.text = location
                self.locationLabel.textColor = Colors.black
            }
        }
        if let sourceViewController = segue.sourceViewController as? PreviewViewController {
            guard let finalImage = sourceViewController.finalImage,
                let imageData = UIImageJPEGRepresentation(finalImage, 0.6)  else {
                return
            }
            self.newProfilePicImageData = imageData
            self.profilePicUrlToRemove = self.user?.profilePicUrl
            self.profilePicImageView.image = finalImage
            self.tableView.reloadData()
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.view.endEditing(true)
        if let newProfilePicImageData = self.newProfilePicImageData {
            self.uploadImage(newProfilePicImageData)
        } else {
            if self.profilePicUrlToRemove != nil {
                self.user?.profilePicUrl = nil
            }
            self.saveUser()
        }
    }
    
    
    
    // MARK: AWS
    
    private func saveUser() {
        guard let firstNameText = self.firstNameTextField.text,
            let lastNameText = self.lastNameTextField.text,
            let preferredUsernameText = self.preferredUsernameTextField.text,
            let aboutText = self.aboutTextView.text else {
                return
        }
        
        // Take new (or old) values from textFields/labels
        let firstName: String? = firstNameText.trimm().isEmpty ? nil : firstNameText.trimm()
        let lastName: String? = lastNameText.trimm().isEmpty ? nil : lastNameText.trimm()
        let preferredUsername: String? = preferredUsernameText.trimm().isEmpty ? nil : preferredUsernameText.trimm()
        let about: String? = aboutText.trimm().isEmpty ? nil : aboutText.trimm()
        let profession: String?
        if self.professionLabel.textColor == Colors.black {
            profession = self.professionLabel.text?.trimm()
        } else {
            profession = nil
        }
        let location: String?
        if self.locationLabel.textColor == Colors.black {
            location = self.locationLabel.text?.trimm()
        } else {
            location = nil
        }
        
        let user = User(userId: self.user?.userId, firstName: firstName, lastName: lastName, preferredUsername: preferredUsername, profession: profession, profilePicUrl: self.user?.profilePicUrl, location: location, about: about)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserDynamoDB(user, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("saveUser error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    // Update user object for ProfileVc.
                    user.profilePic = self.profilePicImageView.image
                    self.editProfileDelegate?.userUpdated(user, profilePicUrlToRemove: self.profilePicUrlToRemove)
                    self.performSegueWithIdentifier("segueUnwindToProfileVc", sender: self)
                }
            })
            return nil
        })
    }
    
    private func uploadImage(imageData: NSData) {
        let uniqueImageName = NSUUID().UUIDString.lowercaseString.stringByReplacingOccurrencesOfString("-", withString: "")
        let imageKey = "public/profile_pics/\(uniqueImageName).jpg"
        let localContent = AWSUserFileManager.custom(key: "USEast1BucketManager").localContentWithData(imageData, key: imageKey)
        
        print("uploadImageS3:")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        localContent.uploadWithPinOnCompletion(
            false,
            progressBlock: {
                (content: AWSLocalContent?, progress: NSProgress?) -> Void in
                // TODO
            }, completionHandler: {
                (content: AWSLocalContent?, error: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    if let error = error {
                        print("uploadImageS3 error: \(error)")
                        let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        print("uploadImageS3 success!")
                        self.user?.profilePicUrl = imageKey
                        self.saveUser()
                    }
                })
        })
    }
}

extension EditProfileTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case self.firstNameTextField:
            self.firstNameTextField.resignFirstResponder()
            self.lastNameTextField.becomeFirstResponder()
        case self.lastNameTextField:
            self.lastNameTextField.resignFirstResponder()
            self.preferredUsernameTextField.becomeFirstResponder()
        default:
            return true
        }
        return true
    }
}

extension EditProfileTableViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        self.aboutFakePlaceholderLabel.hidden = !textView.text.isEmpty
        
        // Changing height of the cell
        let currentOffset = self.tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.tableView.setContentOffset(currentOffset, animated: false)
    }
}
