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
    func userUpdated(user: User?)
}

class EditProfileTableViewController: UITableViewController {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    
    var user: User?
    var editProfileDelegate: EditProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePicImageView.layer.cornerRadius = 40.0
        self.profilePicImageView.clipsToBounds = true
        self.configureUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureUser() {
        self.profilePicImageView.image = self.user?.profilePic
        self.usernameLabel.text = self.user?.preferredUsername
        self.fullNameLabel.text = self.user?.fullName
        self.professionLabel.text = self.user?.profession
        self.locationLabel.text = self.user?.location
        self.aboutLabel.text = self.user?.about
        self.tableView.reloadData()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController {
            switch navigationController.childViewControllers[0] {
            case let destinationViewController as EditUsernameTableViewController:
                destinationViewController.preferredUsername = self.user?.preferredUsername
                destinationViewController.editUsernameDelegate = self
            case let destinationViewController as EditFirstLastNameTableViewController:
                destinationViewController.firstName = self.user?.firstName
                destinationViewController.lastName = self.user?.lastName
                destinationViewController.editFirstLastNameDelegate = self
            case let destinationViewController as EditProfessionTableViewController:
                destinationViewController.profession = self.user?.profession
                destinationViewController.editProfessionDelegate = self
            case let destinationViewController as EditLocationTableViewController:
                destinationViewController.location = self.user?.location
                destinationViewController.editLocationDelegate = self
            case let destinationViewController as EditAboutTableViewController:
                destinationViewController.about = self.user?.about
                destinationViewController.editAboutDelegate = self
            default:
                return
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            self.editProfilePicCellTapped()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: Tappers
    
    private func editProfilePicCellTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let removePhotoAction = UIAlertAction(title: "Remove Photo", style: UIAlertActionStyle.Destructive, handler: {
            (alert: UIAlertAction) in
            
            if let profilePicUrl = self.user?.profilePicUrl {
                // Remove current image on S3 in background.
                self.removeImageS3(profilePicUrl)
            }
            // Update DynamoDB in background.
            self.updateProfilePicDynamoDB(nil)
            
            self.user?.profilePicUrl = nil
            self.user?.profilePic = nil
            self.profilePicImageView.image = nil
            self.editProfileDelegate?.userUpdated(self.user)
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
        if let sourceViewController = segue.sourceViewController as? PreviewViewController {
            guard let finalImage = sourceViewController.finalImage,
                let imageData = UIImageJPEGRepresentation(finalImage, 0.6)  else {
                return
            }
            self.uploadImageS3(imageData)
        }
    }
    
    // MARK: Helpers
    
    private func checkLocationAuthorization() -> Bool {
        // Ask for location authorization.
        let status = CLLocationManager.authorizationStatus()
        guard status != CLAuthorizationStatus.Restricted else {
            print("Location Restricted")
            return false
        }
        guard status != CLAuthorizationStatus.Denied else {
            print("Location Denied")
            return false
        }
        return true
    }
    
    // MARK: AWS
    
    private func uploadImageS3(imageData: NSData) {
        let uniqueImageName = NSUUID().UUIDString.lowercaseString.stringByReplacingOccurrencesOfString("-", withString: "")
        let imageKey = "public/profile_pics/\(uniqueImageName).jpg"
        let localContent = AWSUserFileManager.custom(key: "USEast1BucketManager").localContentWithData(imageData, key: imageKey)
        
        print("uploadImageS3:")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        localContent.uploadWithPinOnCompletion(
            false,
            progressBlock: {
                [weak self](content: AWSLocalContent?, progress: NSProgress?) -> Void in
                guard let strongSelf = self else { return }
                // TODO
            }, completionHandler: {
                [weak self](content: AWSLocalContent?, error: NSError?) -> Void in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("uploadImageS3 error: \(error)")
                    dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        let alertController = strongSelf.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                        strongSelf.presentViewController(alertController, animated: true, completion: nil)
                    })
                } else {
                    print("uploadImageS3 success!")
                    dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        
                        if let profilePicUrl = strongSelf.user?.profilePicUrl {
                            // Remove current image on S3 in background.
                            strongSelf.removeImageS3(profilePicUrl)
                        }
                        // Update DynamoDB in background.
                        strongSelf.updateProfilePicDynamoDB(imageKey)
                        
                        strongSelf.user?.profilePicUrl = imageKey
                        strongSelf.user?.profilePic = UIImage(data: imageData)
                        strongSelf.profilePicImageView.image = strongSelf.user?.profilePic
                        strongSelf.editProfileDelegate?.userUpdated(strongSelf.user)
                        strongSelf.tableView.reloadData()
                    })
                }
        })
    }
    
    // In background.
    private func updateProfilePicDynamoDB(imageKey: String?) {
        print("updateProfilePicDynamoDB:")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().updateProfilePicDynamoDB(
            imageKey,
            completionHandler: {
                (task: AWSTask) in
                if let error = task.error {
                    print("updateProfilePicDynamoDB error: \(error)")
                    dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    })
                } else {
                    print("updateProfilePicDynamoDB success!")
                    dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    })
                }
                return nil
        })
    }
    
    // In background.
    private func removeImageS3(imageKey: String) {
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").contentWithKey(imageKey)
        
        print("removeImageS3:")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        content.removeRemoteContentWithCompletionHandler({
            (content: AWSContent?, error: NSError?) -> Void in
            if let error = error {
                print("removeImageS3 error: \(error)")
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
            } else {
                print("removeImageS3 success")
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    content?.removeLocal()
                })
            }
        })
    }
}

extension EditProfileTableViewController: EditUsernameDelegate {
    
    func usernameUpdated(preferredUsername: String?) {
        self.user?.preferredUsername = preferredUsername
        self.configureUser()
        self.editProfileDelegate?.userUpdated(self.user)
    }
}

extension EditProfileTableViewController: EditFirstLastNameDelegate {
    
    func firstLastNameUpdated(firstName: String?, lastName: String?) {
        self.user?.firstName = firstName
        self.user?.lastName = lastName
        self.configureUser()
        self.editProfileDelegate?.userUpdated(self.user)
    }
}

extension EditProfileTableViewController: EditProfessionDelegate {
    
    func professionUpdated(profession: String?) {
        self.user?.profession = profession
        self.configureUser()
        self.editProfileDelegate?.userUpdated(self.user)
    }
}

extension EditProfileTableViewController: EditLocationDelegate {
    
    func locationUpdated(location: String?) {
        self.user?.location = location
        self.configureUser()
        self.editProfileDelegate?.userUpdated(self.user)
    }
}

extension EditProfileTableViewController: EditAboutDelegate {
    
    func aboutUpdated(about: String?) {
        self.user?.about = about
        self.configureUser()
        self.editProfileDelegate?.userUpdated(self.user)
    }
}
