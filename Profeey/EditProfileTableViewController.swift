//
//  EditProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import MapKit

protocol EditAboutDelegate {
    func toggleAboutFakePlaceholderLabel(hidden: Bool)
}

class EditProfileTableViewController: UITableViewController {
    
    var user: User?
    
    // Properties.
    var profilePic: UIImage?
    var profilePicUrl: String?
    var firstName: String?
    var lastName: String?
    var about: String?
    var locationName: String?
    var professionName: String?
    
    var profilePicUrlToRemove: String?
    private var newProfilePicImageData: NSData?
    
    private var editAboutDelegate: EditAboutDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureUserData() {
        self.profilePic = self.user?.profilePic
        self.profilePicUrl = self.user?.profilePicUrl
        self.firstName = self.user?.firstName
        self.lastName = self.user?.lastName
        self.about = self.user?.about
        self.locationName = self.user?.locationName
        self.professionName = self.user?.professionName
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? LocationsTableViewController {
            childViewController.locationName = self.locationName
        }
        if let destinationViewController = segue.destinationViewController as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? ProfessionsTableViewController {
            childViewController.professionName = self.professionName
        }
        if let destinationViewController = segue.destinationViewController as? ScrollViewController {
            // Capture.
            destinationViewController.isProfilePic = true
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        guard identifier == "segueToLocationsVc" else {
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

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 6
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellEditProfilePic", forIndexPath: indexPath) as! EditProfilePicTableViewCell
                cell.profilePicImageView.image = self.profilePic
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellEditFirstName", forIndexPath: indexPath) as! EditFirstNameTableViewCell
                cell.firstNameTextField.text = self.firstName
                cell.firstNameTextField.addTarget(self, action: #selector(EditProfileTableViewController.firstNameTextFieldChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellEditLastName", forIndexPath: indexPath) as! EditLastNameTableViewCell
                cell.lastNameTextField.text = self.lastName
                cell.lastNameTextField.addTarget(self, action: #selector(EditProfileTableViewController.lastNameTextFieldChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellEditAbout", forIndexPath: indexPath) as! EditAboutTableViewCell
                cell.aboutTextView.text = self.about
                cell.aboutTextView.delegate = self
                if let about = self.about {
                    cell.aboutFakePlaceholderLabel.hidden = !about.isEmpty
                }
                self.editAboutDelegate = cell
                return cell
            case 4:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellEditLocation", forIndexPath: indexPath) as! EditLocationTableViewCell
                if let locationName = self.locationName {
                    cell.locationNameLabel.text = locationName
                    cell.locationNameLabel.textColor = Colors.black
                } else {
                    cell.locationNameLabel.text = "Add location"
                    cell.locationNameLabel.textColor = Colors.disabled
                }
                return cell
            case 5:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellEditProfession", forIndexPath: indexPath) as! EditProfessionTableViewCell
                if let professionName = self.professionName {
                    cell.professionNameLabel.text = professionName
                    cell.professionNameLabel.textColor = Colors.black
                } else {
                    cell.professionNameLabel.text = "Add profession"
                    cell.professionNameLabel.textColor = Colors.disabled
                }
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellAddExperience", forIndexPath: indexPath)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellAddExperience", forIndexPath: indexPath)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader") as! HeaderTableViewCell
            cell.headerTitle.text = "WORK EXPERIENCE"
            // for bug returning contentView
            return cell.contentView
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader") as! HeaderTableViewCell
            cell.headerTitle.text = "EDUCATION"
            // for bug returning contentView
            return cell.contentView
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
            case 4:
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
            case 5:
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
                cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
            default:
                return
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
            default:
                return
            }
        default:
            return
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 112.0
            default:
                return 52.0
            }
        default:
            return 52.0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 112.0
            case 1:
                return 52.0
            case 2:
                return 52.0
            default:
                return UITableViewAutomaticDimension
            }
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 52.0
        case 2:
            return 52.0
        default:
            return 0.0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is EditProfilePicTableViewCell {
            self.editProfilePicCellTapped()
        }
        if cell is EditLocationTableViewCell {
            self.performSegueWithIdentifier("segueToLocationsVc", sender: self)
        }
        if cell is EditProfessionTableViewCell {
            self.performSegueWithIdentifier("segueToProfessionsVc", sender: self)
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: Tappers
    
    func firstNameTextFieldChanged(sender: AnyObject) {
        guard let textField = sender as? UITextField else {
            return
        }
        guard let text = textField.text else {
            return
        }
        self.firstName = text.trimm().isEmpty ? nil : text.trimm()
    }
    
    func lastNameTextFieldChanged(sender: AnyObject) {
        guard let textField = sender as? UITextField else {
            return
        }
        guard let text = textField.text else {
            return
        }
        self.lastName = text.trimm().isEmpty ? nil : text.trimm()
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.view.endEditing(true)
        FullScreenIndicator.show()
        if let newProfilePicImageData = self.newProfilePicImageData {
            self.uploadImage(newProfilePicImageData)
        } else {
            self.saveUser()
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func unwindToEditProfileTableViewController(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.sourceViewController as? LocationsTableViewController {
            guard let locationName = sourceViewController.locationName else {
                self.locationName = nil
                self.tableView.reloadData()
                return
            }
            self.locationName = locationName.isEmpty ? nil : locationName
            self.tableView.reloadData()
        }
        if let sourceViewController = segue.sourceViewController as? ProfessionsTableViewController {
            guard let professionName = sourceViewController.professionName else {
                self.professionName = nil
                self.tableView.reloadData()
                return
            }
            self.professionName = professionName.isEmpty ? nil : professionName
            self.tableView.reloadData()
        }
        if let sourceViewController = segue.sourceViewController as? PreviewViewController {
            guard let finalImage = sourceViewController.finalImage,
                let imageData = UIImageJPEGRepresentation(finalImage, 0.6)  else {
                return
            }
            self.newProfilePicImageData = imageData
            if self.profilePicUrl != nil {
                self.profilePicUrlToRemove = self.profilePicUrl
                self.profilePicUrl = nil
            }
            self.profilePic = finalImage
            self.tableView.reloadData()
        }
    }
    
    // MARK: Helpers
    
    private func editProfilePicCellTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let removePhotoAction = UIAlertAction(title: "Remove Photo", style: UIAlertActionStyle.Destructive, handler: {
            (alert: UIAlertAction) in
            self.newProfilePicImageData = nil
            if self.profilePicUrl != nil {
                self.profilePicUrlToRemove = self.profilePicUrl
                self.profilePicUrl = nil
            }
            self.profilePic = nil
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
    
    // MARK: AWS
    
    private func saveUser() {
        let updatedUser = User(userId: self.user?.userId, firstName: self.firstName, lastName: self.lastName, professionName: self.professionName, profilePicUrl: self.profilePicUrl, about: self.about, locationName: self.locationName)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserDynamoDB(updatedUser, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("saveUser error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
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
                        self.profilePicUrl = imageKey
                        self.saveUser()
                    }
                })
        })
    }
    
}

extension EditProfileTableViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        if textView.text.trimm().isEmpty {
            self.editAboutDelegate?.toggleAboutFakePlaceholderLabel(false)
        } else {
            self.editAboutDelegate?.toggleAboutFakePlaceholderLabel(true)
        }
        self.about = textView.text.trimm().isEmpty ? nil : textView.text.trimm()
        
        // Changing height of the cell
        let currentOffset = self.tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.tableView.setContentOffset(currentOffset, animated: false)
    }
}
