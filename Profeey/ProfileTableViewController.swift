//
//  ProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSDynamoDB
import AWSMobileHubHelper

class ProfileTableViewController: UITableViewController {
    
    var currentUser: CurrentUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.tableView.estimatedRowHeight = 85.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.delaysContentTouches = false
        
        self.currentUser = CurrentUser()
        self.navigationItem.title = self.currentUser.preferredUsername
        
        self.getRemoteUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? EditProfileTableViewController {
            destinationViewController.currentUser = self.currentUser
            destinationViewController.delegate = self
        }
        if let destinationViewController = segue.destinationViewController as? CaptureProfilePhotoNavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? CaptureProfilePhotoViewController {
            childViewController.previewProfilePicDelegate = self
        }
    }
    
    // MARK: AWS
    
    private func getRemoteUser() {
        AWSRemoteService.defaultRemoteService().getUser({
            (response: AWSDynamoDBObjectModel?, error: NSError?) -> Void in
            if let error = error {
                print("Failed to load user. \(error.localizedDescription)")
            } else if let awsUser = response as? AWSUser {
                self.currentUser.updateFromRemote(awsUser)
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    self.navigationItem.title = self.currentUser.preferredUsername
                })
                // WAIT TILL YOU SOLVE Amzon Cognito Problem.
                // Async download profilePic
                if let profilePicUrl = self.currentUser.profilePicUrl {
                    self.downloadProfilePic(profilePicUrl)
                }
            } else {
                print("User not found.")
            }
        })
    }
    
    private func downloadProfilePic(profilePicUrl: String) {
        AWSRemoteService.defaultRemoteService().downloadProfilePic(
            profilePicUrl,
            progressBlock: {
                (content: AWSContent?, progress: NSProgress?) -> Void in
                return
            },
            completionHandler: {
                (task: AWSTask) in
                dispatch_async(dispatch_get_main_queue(), {
                    if let error = task.error {
                        print("Error: \(error)")
                    } else if let result = task.result as? NSData {
                        // Cache locally.
                        LocalService.setProfilePicLocal(result)
                        self.currentUser.profilePicData = result
                        self.tableView.reloadData()
                    } else {
                        print("This should not happen!")
                    }
                })
                return nil
        })
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader", forIndexPath: indexPath) as! HeaderProfileTableViewCell
        if let imageData = self.currentUser.profilePicData {
            cell.profilePicImageView.image = UIImage(data: imageData)
        }
        cell.fullNameLabel.text = self.currentUser.fullName
        cell.professionsLabel.text = self.currentUser.professions?.joinWithSeparator(" · ")
        cell.aboutLabel.text = self.currentUser.about
        cell.signOutButton.addTarget(self, action: #selector(ProfileTableViewController.signOutButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    
    // MARK: Tappers
    
    func signOutButtonTapped(sender: UIButton) {
        // Simulate delay.
        FullScreenIndicator.show()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ProfileTableViewController.signOut), userInfo: nil, repeats: false)
    }
    
    func signOut() {
        AWSRemoteService.defaultRemoteService().signOut()
        LocalService.clearAllLocal()
        FullScreenIndicator.hide()
    }
    
    // MARK: IBActions
    
    @IBAction func profilePicImageViewTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let removePhotoAction = UIAlertAction(title: "Remove current photo", style: UIAlertActionStyle.Destructive, handler: {
            (alert: UIAlertAction) in
            //self.profilePicUploader.deleteProfilePic(self.user._profilePicUrl)
        })
        alertController.addAction(removePhotoAction)
        let takePhotoAction = UIAlertAction(title: "Take photo", style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction) in
            self.performSegueWithIdentifier("segueToCaptureProfilePhotoVc", sender: self)
        })
        alertController.addAction(takePhotoAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToProfileTableViewController(segue: UIStoryboardSegue) {
    }
}

extension ProfileTableViewController: EditProfileDelegate {
    
    func currentUserUpdated(currentUser: CurrentUser) {
        self.currentUser = currentUser
        self.tableView.reloadData()
        self.navigationItem.title = self.currentUser.preferredUsername
    }
}

extension ProfileTableViewController: PreviewProfilePicDelegate {
    
    func saveProfilePic(profilePic: UIImage) {
        AWSRemoteService.defaultRemoteService().saveProfilePic(
            profilePic,
            oldImageKey: self.currentUser.profilePicUrl,
            progressBlock: {
                (content: AWSLocalContent?, progress: NSProgress?) -> Void in
                // TODO
                return
            },
            completionHandler: {
                (task: AWSTask) in
                dispatch_async(dispatch_get_main_queue(), {
                    if let error = task.error {
                        print("Error: \(error)")
                    } else if let result = task.result as? NSData {
                        // Cache locally.
                        LocalService.setProfilePicLocal(result)
                        self.currentUser.profilePicData = result
                        self.tableView.reloadData()
                    } else {
                        print("This should not happen!")
                    }
                })
                return nil
        })
    }
}

extension ProfileTableViewController: ProfilePicUploaderDelegate {
    
    func uploadFinished(profilePicUrl: String) {
        //let profilePicContent = self.manager.contentWithKey(profilePicUrl)
        //self.downloadProfilePic(profilePicContent)
    }
    
    func deleteFinished() {
        self.tableView.reloadData()
    }
}
