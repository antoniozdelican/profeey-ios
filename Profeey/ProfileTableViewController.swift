//
//  ProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 16/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class ProfileTableViewController: UITableViewController {
    
    var currentUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delaysContentTouches = false
        self.currentUser = AWSClientManager.defaultClientManager().currentUser
        self.navigationItem.title = self.currentUser?.preferredUsername
//        if self.currentUser == nil {
//            self.getCurrentUser()
//        }
//        self.getCurrentUserDynamoDB()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfile", forIndexPath: indexPath) as! ProfileTableViewCell
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.profilePicImageViewTapped(_:)))
            cell.profilePicImageView.addGestureRecognizer(tapGestureRecognizer)
            cell.fullNameLabel.text = [self.currentUser?.firstName, self.currentUser?.lastName].flatMap({ $0 }).joinWithSeparator(" ")
            cell.professionsLabel.text = self.currentUser?.professions?.joinWithSeparator(" · ")
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        guard let cell = cell as? PostTableViewCell else {
//            return
//        }
//        cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
//        cell.collectionViewOffset = self.storedOffsets[indexPath.row] ?? 0
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        guard let cell = cell as? PostTableViewCell else {
//            return
//        }
//        self.storedOffsets[indexPath.row] = cell.collectionViewOffset
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.view.bounds.height - (self.tabBarController?.tabBar.bounds.height)!
        } else {
            return 120.0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.view.bounds.height - (self.tabBarController?.tabBar.bounds.height)!
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    // MARK: Tappers
    
    func profilePicImageViewTapped(sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let removePhotoAction = UIAlertAction(title: "Remove current photo", style: UIAlertActionStyle.Destructive, handler: {
            (alert: UIAlertAction) in
        })
        alertController.addAction(removePhotoAction)
        let takePhotoAction = UIAlertAction(title: "Update photo", style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction) in
            self.performSegueWithIdentifier("segueToCaptureProfilePicVc", sender: self)
        })
        alertController.addAction(takePhotoAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: AWS
    
    private func getCurrentUser() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().getCurrentUser({
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("Update currentUser success!")
                    self.currentUser = AWSClientManager.defaultClientManager().currentUser
                    self.navigationItem.title = self.currentUser?.preferredUsername
                    self.tableView.reloadData()
                }
            })
            return nil
        })
    }
    
    private func getCurrentUserDynamoDB() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().getCurrentUserDynamoDB({
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                } else if let user = task.result as? AWSUser {
                    // Update professions.
                    self.currentUser?.professions = user._professions
                    self.tableView.reloadData()
                } else {
                    print("This should not happen with getCurrentUserDynamoDB!")
                }
            })
            return nil
        })
    }
    
    
//    private func downloadProfilePic(profilePicUrl: String) {
//        AWSRemoteService.defaultRemoteService().downloadProfilePic(
//            profilePicUrl,
//            progressBlock: {
//                (content: AWSContent?, progress: NSProgress?) -> Void in
//                return
//            },
//            completionHandler: {
//                (task: AWSTask) in
//                dispatch_async(dispatch_get_main_queue(), {
//                    if let error = task.error {
//                        print("Error: \(error)")
//                    } else if let result = task.result as? NSData {
//                        // Cache locally.
//                        LocalService.setProfilePicLocal(result)
//                        self.currentUser?.profilePicData = result
//                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
//                    } else {
//                        print("This should not happen!")
//                    }
//                })
//                return nil
//        })
//    }
}

//extension ProfileTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    
////    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        return self.categoriesArray.count
////    }
////    
////    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
////        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellPostCategory", forIndexPath: indexPath) as! PostCategoryCollectionViewCell
////        cell.categoryLabel.text = self.categoriesArray[indexPath.row]
////        return cell
////    }
//}

extension ProfileTableViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        // Constants for post category cell size.
//        let itemLabelHeight: CGFloat = 17.0
//        let itemFont: UIFont = UIFont.systemFontOfSize(14.0)
//        let topInset: CGFloat = 4.0
//        let leftInset: CGFloat = 8.0
//        let rightInset: CGFloat = 8.0
//        let item = self.categoriesArray[indexPath.row]
//        // Calculations.
//        let labelRect = NSString(string: item).boundingRectWithSize(CGSize(width: CGFloat(MAXFLOAT), height: itemLabelHeight), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: itemFont], context: nil)
//        let cellWidth = ceil(labelRect.size.width) + leftInset + rightInset
//        let cellHeight = ceil(labelRect.size.height) + 2 * topInset
//        return CGSizeMake(cellWidth, cellHeight)
//    }
}
