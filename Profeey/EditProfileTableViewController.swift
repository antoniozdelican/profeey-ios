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

class EditProfileTableViewController: UITableViewController {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var aboutFakePlaceholderLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    var user: User?
    private var newProfilePicImageData: NSData?
    
    var profilePicUrlToRemove: String?
    var updatedUser: User?
    
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
        
        self.aboutTextView.delegate = self
        self.aboutTextView.text = self.user?.about
        self.aboutFakePlaceholderLabel.hidden = !self.aboutTextView.text.isEmpty
        
        if let professionName = self.user?.professionName {
            self.professionNameLabel.text = professionName
            self.professionNameLabel.textColor = Colors.black
        }
        
        if let locationName = self.user?.locationName {
            self.locationNameLabel.text = locationName
            self.locationNameLabel.textColor = Colors.black
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? ProfessionsTableViewController {
            if self.professionNameLabel.textColor == Colors.black {
                childViewController.professionName = self.professionNameLabel.text
            }
        }
        if let destinationViewController = segue.destinationViewController as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? LocationsTableViewController {
            if self.locationNameLabel.textColor == Colors.black {
                childViewController.locationName = self.locationNameLabel.text
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
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        if indexPath.row == 4 || indexPath.row == 5 {
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
        if let sourceViewController = segue.sourceViewController as? ProfessionsTableViewController {
            guard let professionName = sourceViewController.professionName else {
                return
            }
            if professionName.isEmpty {
                self.professionNameLabel.text = "Add profession"
                self.professionNameLabel.textColor = Colors.disabled
            } else {
                self.professionNameLabel.text = professionName
                self.professionNameLabel.textColor = Colors.black
            }
        }
        if let sourceViewController = segue.sourceViewController as? LocationsTableViewController {
            guard let locationName = sourceViewController.locationName else {
                return
            }
            if locationName.isEmpty {
                self.locationNameLabel.text = "Add location"
                self.locationNameLabel.textColor = Colors.disabled
            } else {
                self.locationNameLabel.text = locationName
                self.locationNameLabel.textColor = Colors.black
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
        
        FullScreenIndicator.show()
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
            let aboutText = self.aboutTextView.text else {
                return
        }
        
        // Take new (or old) values from textFields/labels
        let firstName: String? = firstNameText.trimm().isEmpty ? nil : firstNameText.trimm()
        let lastName: String? = lastNameText.trimm().isEmpty ? nil : lastNameText.trimm()
        let about: String? = aboutText.trimm().isEmpty ? nil : aboutText.trimm()
        let professionName: String? = (self.professionNameLabel.textColor == Colors.black) ? self.professionNameLabel.text?.trimm() : nil
        let locationName: String? = (self.locationNameLabel.textColor == Colors.black) ? self.locationNameLabel.text?.trimm() : nil
        
        self.updatedUser = User(userId: self.user?.userId, firstName: firstName, lastName: lastName, preferredUsername: self.user?.preferredUsername, professionName: professionName, profilePicUrl: self.user?.profilePicUrl, about: about, locationName: locationName, numberOfFollowers: self.user?.numberOfFollowers, numberOfPosts: self.user?.numberOfPosts)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserDynamoDB(user, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("saveUser error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    // Update user object for ProfileVc.
                    self.updatedUser?.profilePic = self.profilePicImageView.image
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
                        FullScreenIndicator.hide()
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
