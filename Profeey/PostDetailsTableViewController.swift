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
            let indexPath = NSIndexPath(forRow: 5, inSection: 0)
            self.getLike(postId, indexPath: indexPath)
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
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostUser", forIndexPath: indexPath) as! PostUserTableViewCell
            let user = self.post?.user
            cell.profilePicImageView.image = user?.profilePic
            cell.fullNameLabel.text = user?.fullName
            cell.professionNameLabel.text = user?.professionName
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostImage", forIndexPath: indexPath) as! PostImageTableViewCell
            cell.postImageView.image = self.post?.image
            if let image = self.post?.image {
                let aspectRatio = image.size.width / image.size.height
                cell.postImageViewHeightConstraint.constant = tableView.bounds.width / aspectRatio
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostInfo", forIndexPath: indexPath) as! PostInfoTableViewCell
            cell.titleLabel.text = self.post?.title
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostCategory", forIndexPath: indexPath) as! PostCategoryTableViewCell
            cell.categoryNameLabel.text = self.post?.categoryName
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostTime", forIndexPath: indexPath) as! PostTimeTableViewCell
            cell.timeLabel.text = self.post?.creationDateString
            return cell
        case 5:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostButtons", forIndexPath: indexPath) as! PostButtonsTableViewCell
            self.post!.isLikedByCurrentUser ? cell.setSelectedLikeButton() : cell.setUnselectedLikeButton()
            cell.likeButton.addTarget(self, action: #selector(HomeTableViewController.likeButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.numberOfLikesButton.hidden = (self.post?.numberOfLikesString != nil) ? false : true
            cell.numberOfLikesButton.setTitle(self.post?.numberOfLikesString, forState: UIControlState.Normal)
            cell.numberOfLikesButton.addTarget(self, action: #selector(HomeTableViewController.numberOfLikesButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
        let point = sender.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(point) else {
            return
        }
        guard let post = self.post else {
            return
        }
        guard let postId = post.postId else {
            return
        }
        guard let postUserId = post.userId else {
            return
        }
        let numberOfLikes = (post.numberOfLikes != nil) ? post.numberOfLikes! : 0
        let numberOfLikesInteger = numberOfLikes.integerValue
        if post.isLikedByCurrentUser {
            post.isLikedByCurrentUser = false
            post.numberOfLikes = NSNumber(integer: (numberOfLikesInteger - 1))
            self.removeLike(postId, postUserId: postUserId)
        } else {
            post.isLikedByCurrentUser = true
            post.numberOfLikes = NSNumber(integer: (numberOfLikesInteger + 1))
            self.saveLike(postId, postUserId: postUserId)
        }
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        
        //self.likeDelegate?.togglePostLike(self.postIndexPath, numberOfLikes: self.post?.numberOfLikes)
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
                    guard let awsUser = task.result as? AWSUser else {
                        return
                    }
                    let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl)
                    self.currentUser = user
                }
            })
            return nil
        })
    }
    
    // Check if currentUser liked a post.
    private func getLike(postId: String, indexPath: NSIndexPath) {
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
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
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
                }
            })
            return nil
        })
    }
}