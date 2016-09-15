//
//  UsersTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

enum UsersType {
    case Likers
    case Followers
}

class UsersTableViewController: UITableViewController {
    
    var usersType: UsersType?
    // In case of likes.
    var postId: String?
    // In case of followers.
    var userId: String?
    
    private var users: [User] = []
    private var isLoadingUsers: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        if let usersType = self.usersType {
            switch usersType {
            case .Likers:
                self.navigationItem.title = "Likes"
                if let postId = self.postId {
                    self.isLoadingUsers = true
                    self.queryPostLikers(postId)
                }
            case .Followers:
                self.navigationItem.title = "Followers"
                if let followingId = self.userId {
                    self.isLoadingUsers = true
                    self.queryUserFollowers(followingId)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? ProfileTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.user = self.users[indexPath.row]
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingUsers {
            return 1
        }
        return self.users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.isLoadingUsers {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellLoading", forIndexPath: indexPath) as! LoadingTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("cellUser", forIndexPath: indexPath) as! UserTableViewCell
        let user = self.users[indexPath.row]
        cell.profilePicImageView.image = user.profilePic
        cell.fullNameLabel.text = user.fullName
        cell.professionLabel.text = user.professionName
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is UserTableViewCell {
           self.performSegueWithIdentifier("segueToProfileVc", sender: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 12.0, 0.0, 0.0)
        if self.isLoadingUsers {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.isLoadingUsers {
            return 120.0
        }
        return 65.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.isLoadingUsers {
            return 120.0
        }
        return 65.0
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(sender: AnyObject) {
        guard let usersType = self.usersType else {
            self.refreshControl?.endRefreshing()
            return
        }
        switch usersType {
        case .Likers:
            guard let postId = self.postId else {
                self.refreshControl?.endRefreshing()
                return
            }
            self.users = []
            self.queryPostLikers(postId)
        case .Followers:
            guard let followingId = self.userId else {
                self.refreshControl?.endRefreshing()
                return
            }
            self.users = []
            self.queryUserFollowers(followingId)
        }
    }
    
    // MARK: AWS
    
    private func queryPostLikers(postId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryPostLikersDynamoDB(postId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("queryPostLikers error: \(error)")
                    self.isLoadingUsers = false
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                } else {
                    guard let awsLikes = response?.items as? [AWSLike] else {
                        self.isLoadingUsers = false
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    guard awsLikes.count > 0 else {
                        self.isLoadingUsers = false
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    for (index, awsLike) in awsLikes.enumerate() {
                        let user = User(userId: awsLike._userId, firstName: awsLike._firstName, lastName: awsLike._lastName, preferredUsername: awsLike._preferredUsername, professionName: awsLike._professionName, profilePicUrl: awsLike._profilePicUrl)
                        self.users.append(user)
                        self.isLoadingUsers = false
                        self.tableView.reloadData()
                        
                        // Get profilePic.
                        if let profilePicUrl = awsLike._profilePicUrl {
                            let indexPath = NSIndexPath(forRow: index, inSection: 0)
                            self.downloadImage(profilePicUrl, imageType: .UserProfilePic, indexPath: indexPath)
                        }
                    }
                    self.refreshControl?.endRefreshing()
                }
            })
        })
    }
    
    private func queryUserFollowers(followingId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserFollowersDynamoDB(followingId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("queryUserFollowers error: \(error)")
                    self.isLoadingUsers = false
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                } else {
                    guard let awsUserRelationships = response?.items as? [AWSUserRelationship] else {
                        self.isLoadingUsers = false
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    guard awsUserRelationships.count > 0 else {
                        self.isLoadingUsers = false
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    for (index, awsUserRelationship) in awsUserRelationships.enumerate() {
                        let user = User(userId: awsUserRelationship._userId, firstName: awsUserRelationship._firstName, lastName: awsUserRelationship._lastName, preferredUsername: awsUserRelationship._preferredUsername, professionName: awsUserRelationship._professionName, profilePicUrl: awsUserRelationship._profilePicUrl)
                        self.users.append(user)
                        self.isLoadingUsers = false
                        self.tableView.reloadData()
                        
                        // Get profilePic.
                        if let profilePicUrl = awsUserRelationship._profilePicUrl {
                            let indexPath = NSIndexPath(forRow: index, inSection: 0)
                            self.downloadImage(profilePicUrl, imageType: .UserProfilePic, indexPath: indexPath)
                        }
                    }
                    self.refreshControl?.endRefreshing()
                }
            })
        })
        
    }
    
    private func downloadImage(imageKey: String, imageType: ImageType, indexPath: NSIndexPath) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").contentWithKey(imageKey)
        // TODO check if content.isImage()
        if content.cached {
            print("Content cached:")
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            switch imageType {
            case .UserProfilePic:
                self.users[indexPath.row].profilePic = image
                self.tableView.reloadData()
            default:
                return
            }
        } else {
            print("Download content:")
            content.downloadWithDownloadType(
                AWSContentDownloadType.IfNewerExists,
                pinOnCompletion: false,
                progressBlock: {
                    (content: AWSContent?, progress: NSProgress?) -> Void in
                    // TODO
                },
                completionHandler: {
                    (content: AWSContent?, data: NSData?, error: NSError?) in
                    dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        if let error = error {
                            print("downloadImage error: \(error)")
                        } else {
                            guard let imageData = data else {
                                return
                            }
                            let image = UIImage(data: imageData)
                            switch imageType {
                            case .UserProfilePic:
                                self.users[indexPath.row].profilePic = image
                                self.tableView.reloadData()
                            default:
                                return
                            }
                        }
                    })
            })
        }
    }

}
