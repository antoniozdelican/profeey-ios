//
//  PostDetailsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol LikeDelegate {
    func togglePostLike(postIndexPath: NSIndexPath?, numberOfLikes: NSNumber?)
}

class PostDetailsTableViewController: UITableViewController {
    
    var post: Post?
    var postIndexPath: NSIndexPath?
    var likeDelegate: LikeDelegate?
    private var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.title = "Post"
        
        // Get current user.
        self.getCurrentUser()
        
        // Check if liked by currentUser.
        if let postId = self.post?.postId {
            self.getLike(postId)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? ProfileTableViewController {
            destinationViewController.user = self.post?.user
        }
        if let destinationViewController = segue.destinationViewController as? CategoryTableViewController {
            destinationViewController.categoryName = self.post?.categoryName
        }
        if let destinationViewController = segue.destinationViewController as? UsersTableViewController {
            destinationViewController.usersType = UsersType.Likers
            destinationViewController.postId = self.post?.postId
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let post = self.post else {
            return UITableViewCell()
        }
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostUser", forIndexPath: indexPath) as! PostUserTableViewCell
            let user = post.user
            cell.profilePicImageView.image = user?.profilePic
            cell.fullNameLabel.text = user?.fullName
            cell.professionNameLabel.text = user?.professionName
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostImage", forIndexPath: indexPath) as! PostImageTableViewCell
            cell.postImageView.image = post.image
            if let image = post.image {
                let aspectRatio = image.size.width / image.size.height
                cell.postImageViewHeightConstraint.constant = tableView.bounds.width / aspectRatio
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostInfo", forIndexPath: indexPath) as! PostInfoTableViewCell
            cell.titleLabel.text = post.title
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostCategory", forIndexPath: indexPath) as! PostCategoryTableViewCell
            cell.categoryNameLabel.text = post.categoryName
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostTime", forIndexPath: indexPath) as! PostTimeTableViewCell
            cell.timeLabel.text = post.creationDateString
            return cell
        case 5:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostButtons", forIndexPath: indexPath) as! PostButtonsTableViewCell
            
            post.isLikedByCurrentUser ? cell.setSelectedLikeButton() : cell.setUnselectedLikeButton()
            cell.likeButton.addTarget(self, action: #selector(CategoryTableViewController.likeButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.numberOfLikesButton.addTarget(self, action: #selector(CategoryTableViewController.numberOfLikesButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.numberOfLikesButton.hidden = (post.numberOfLikesString == nil) ? true : false
            cell.numberOfLikesLabel.text = post.numberOfLikesString
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is PostUserTableViewCell {
            self.performSegueWithIdentifier("segueToProfileVc", sender: indexPath)
        }
        if cell is PostCategoryTableViewCell {
            self.performSegueWithIdentifier("segueToCategoryVc", sender: indexPath)
        }
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        if indexPath.row == 5 {
            cell.separatorInset = UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0)
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 65.0
        case 1:
            return 300.0
        case 2:
            return 30.0
        case 3:
            return 21.0
        case 4:
            return 21.0
        case 5:
            return 49.0
        default:
            return 0.0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 65.0
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return UITableViewAutomaticDimension
        case 3:
            return UITableViewAutomaticDimension
        case 4:
            return 21.0
        case 5:
            return 49.0
        default:
            return 0.0
        }
    }
    
    // MARK: Tappers
    
    func likeButtonTapped(sender: UIButton) {
        guard let postId = post?.postId,
            let postUserId = post?.userId else {
                return
        }
        if self.post!.isLikedByCurrentUser {
            self.post?.isLikedByCurrentUser = false
            if let oldNumberOfLikes = self.post?.numberOfLikes?.integerValue {
                let newNumberOfLikes = oldNumberOfLikes - 1
                self.post?.numberOfLikes = NSNumber(integer: newNumberOfLikes)
                
            }
            self.tableView.reloadData()
            // In background.
            self.removeLike(postId, postUserId: postUserId)
        } else {
            self.post?.isLikedByCurrentUser = true
            if let oldNumberOfLikes = self.post?.numberOfLikes?.integerValue {
                let newNumberOfLikes = oldNumberOfLikes + 1
                self.post?.numberOfLikes = NSNumber(integer: newNumberOfLikes)
            }
            self.tableView.reloadData()
            // In background.
            self.saveLike(postId, postUserId: postUserId)
        }
        self.likeDelegate?.togglePostLike(self.postIndexPath, numberOfLikes: self.post?.numberOfLikes)
    }
    
    func numberOfLikesButtonTapped(sender: UIButton) {
        self.performSegueWithIdentifier("segueToUsersVc", sender: self)
    }
    
    // MARK: AWS
    
    // Get currentUser data so we can perform actions (like, comment)
    private func getCurrentUser() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getCurrentUserDynamoDB({
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getCurrentUser error: \(error)")
                } else {
                    if let awsUser = task.result as? AWSUser {
                        let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl)
                        self.currentUser = user
                    }
                }
            })
            return nil
        })
    }
    
    // Check if currentUser liked a post.
    private func getLike(postId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getLikeDynamoDB(postId, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getLike error: \(error)")
                } else {
                    if task.result != nil {
                        self.post?.isLikedByCurrentUser = true
                        self.tableView.reloadData()
                    }
                }
            })
            return nil
        })
    }
    
    private func saveLike(postId: String, postUserId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveLikeDynamoDB(postId, postUserId: postUserId, liker: self.currentUser, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("saveLike error: \(error)")
                } else {
                    print("saveLike success!")
                }
            })
            return nil
        })
    }
    
    private func removeLike(postId: String, postUserId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeLikeDynamoDB(postId, postUserId: postUserId, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("removeLike error: \(error)")
                } else {
                    print("removeLike success!")
                }
            })
            return nil
        })
    }
}