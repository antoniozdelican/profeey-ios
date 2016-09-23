//
//  UsernameTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class UsernameTableViewController: UITableViewController {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    private var newProfilePicImageData: NSData?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePicImageView.layer.cornerRadius = 40.0
        self.usernameTextField.delegate = self
        self.continueButton.enabled = false
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? CaptureScrollViewController {
            destinationViewController.isProfilePic = true
            destinationViewController.profilePicUnwind = ProfilePicUnwind.UsernameVc
        }
    }

    // MARK: UITableViewController

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.editProfilePicCellTapped()
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func textFieldChanged(sender: AnyObject) {
        guard let usernameText = self.usernameTextField.text else {
                return
        }
        guard !usernameText.trimm().isEmpty else {
                self.continueButton.enabled = false
                return
        }
        self.continueButton.enabled = true
    }
    
    
    @IBAction func continueButtonTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.prepareForUpdate()
    }
    
    @IBAction func unwindToUsernameTableViewController(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.sourceViewController as? PreviewViewController {
            guard let finalImage = sourceViewController.finalImage,
                let imageData = UIImageJPEGRepresentation(finalImage, 0.6)  else {
                    return
            }
            self.newProfilePicImageData = imageData
            self.profilePicImageView.image = finalImage
            self.tableView.reloadData()
        }
    }
    
    // MARK: Helpers
    
    private func editProfilePicCellTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let removePhotoAction = UIAlertAction(title: "Remove Photo", style: UIAlertActionStyle.Destructive, handler: {
            (alert: UIAlertAction) in
            self.newProfilePicImageData = nil
            self.profilePicImageView.image = nil
            self.tableView.reloadData()
        })
        alertController.addAction(removePhotoAction)
        let changePhotoAction = UIAlertAction(title: "Add Profile Photo", style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction) in
            self.performSegueWithIdentifier("segueToCaptureVc", sender: self)
        })
        alertController.addAction(changePhotoAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func prepareForUpdate() {
        guard let preferredUsernameText = self.usernameTextField.text else {
                return
        }
        guard !preferredUsernameText.trimm().isEmpty else {
                return
        }
        let preferredUsername = preferredUsernameText.trimm()
        FullScreenIndicator.show()
        self.updatePreferredUsernameUserPool(preferredUsername)
    }
    
    // MARK: AWS
    
    private func updatePreferredUsernameUserPool(preferredUsername: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYUserPoolManager.defaultUserPoolManager().updatePreferredUsernameUserPool(preferredUsername, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("updatePreferredUsernameUserPool error: \(error)")
                    let alertController = UIAlertController(title: "Username unavailable", message: error.userInfo["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    if let profilePicImageData = self.newProfilePicImageData {
                        self.uploadImage(preferredUsername, imageData: profilePicImageData)
                    } else {
                        self.saveUser(preferredUsername, profilePicUrl: nil)
                    }
                }
            })
            return nil
        })
        
    }
    
    private func saveUser(preferredUsername: String, profilePicUrl: String?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserPreferredUsernameAndProfilePicDynamoDB(preferredUsername, profilePicUrl: profilePicUrl, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("saveUser error: \(error)")
                    let alertController = UIAlertController(title: "Save error", message: error.userInfo["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    FullScreenIndicator.hide()
                    print("SUCCESS")
                }
            })
            return nil
        })
    }
    
    private func uploadImage(preferredUsername: String, imageData: NSData) {
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
                        let alertController = UIAlertController(title: "Upload image failed", message: error.userInfo["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        self.saveUser(preferredUsername, profilePicUrl: imageKey)
                    }
                })
        })
    }
}

extension UsernameTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}
