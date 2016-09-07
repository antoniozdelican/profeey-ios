//
//  PostDetailsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 16/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class PostDetailsTableViewController: UITableViewController {

    @IBOutlet weak var postPicImageView: UIImageView!
    @IBOutlet weak var postPicImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var mainTableViewCell: UITableViewCell!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var numberOfLikesButton: UIButton!
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var userTableViewCell: UITableViewCell!
    
    //@IBOutlet weak var timeLabel: UILabel!
    //@IBOutlet weak var descriptionLabel: UILabel!
    
    var post: Post?
    private var newImageViewHeight: CGFloat?
    
    private var comments: [Comment]?

    private var isLiked: Bool = false
    private var numberOfLikes = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.configurePost()
        
        //self.getLike()
        //self.queryPostLikers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configurePost() {
        // PostPic.
        if let image = self.post?.image {
            let aspectRatio = image.size.width / image.size.height
            let imageHeight = self.view.bounds.width / aspectRatio
            self.postPicImageViewHeightConstraint.constant = imageHeight
            self.postPicImageView.image = image
            self.newImageViewHeight = imageHeight
        }
        // Title and categories.
        self.titleLabel.text = self.post?.title
        self.categoryLabel.text = self.post?.categoryName
        // User.
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        self.profilePicImageView.image = self.post?.user?.profilePic
        self.fullNameLabel.text = self.post?.user?.fullName
        self.professionLabel.text = self.post?.user?.profession
        // Other.
        //self.descriptionLabel.text = self.post?.postDescription
        //self.timeLabel.text = self.post?.creationDateString
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? UsersTableViewController {
            destinationViewController.isLikers = true
        }
        if let destinationViewController = segue.destinationViewController as? CommentsViewController {
            // If button was tapped.
            if segue.identifier == "segueButtonToCommentsVc" {
                destinationViewController.isCommentButton = true
            } else {
                destinationViewController.isCommentButton = false
            }
            destinationViewController.hidesBottomBarWhenPushed = true
        }
        if let destinationViewController = segue.destinationViewController as? ProfileTableViewController {
            destinationViewController.user = self.post?.user
            destinationViewController.isCurrentUser = false
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 300.0
        case 1:
            return 30.0
        case 2:
            return 30.0
        case 3:
            return 40.0
        case 4:
            return 73.0
        default:
            return 0.0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.row {
        case 4:
            self.performSegueWithIdentifier("segueToProfileVc", sender: self)
        default:
            return
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        switch indexPath.row {
        case 0:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 1:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 2:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 3:
            cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        case 4:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
        default:
            return
        }
    }
    
    // MARK: IBActions
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        if self.isLiked {
            self.likeButton.setImage(UIImage(named: "ic_like_blue_big"), forState: UIControlState.Normal)
            self.isLiked = false
            self.numberOfLikes -= 1
            let likesTitle = self.numberOfLikes > 1 ? "\(self.numberOfLikes) likes" : "\(self.numberOfLikes) like"
            //self.numberOfLikesButton.setTitle(likesTitle, forState: UIControlState.Normal)
            //self.removeLike()
        } else {
            self.likeButton.setImage(UIImage(named: "ic_like_blue_big_selected"), forState: UIControlState.Normal)
            self.isLiked = true
            self.numberOfLikes += 1
            let likesTitle = self.numberOfLikes > 1 ? "\(self.numberOfLikes) likes" : "\(self.numberOfLikes) like"
            //self.numberOfLikesButton.setTitle(likesTitle, forState: UIControlState.Normal)
            //self.saveLike()
        }
    }
    
    @IBAction func numberOfLikesButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("segueToUsersVc", sender: self)
    }
    
    
    @IBAction func commentButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("segueButtonToCommentsVc", sender: self)
    }
    
    @IBAction func numberOfCommentsButton(sender: AnyObject) {
        self.performSegueWithIdentifier("segueToCommentsVc", sender: self)
    }
    
    // MARK: AWS
    
//    // Check if currentUser already liked this post.
//    private func getLike() {
//        guard let postId = self.post?.postId else {
//            return
//        }
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        AWSClientManager.defaultClientManager().getLike(postId, completionHandler: {
//            (task: AWSTask) in
//            dispatch_async(dispatch_get_main_queue(), {
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                if let error = task.error {
//                    print("getLike error: \(error.localizedDescription)")
//                } else {
//                    if task.result != nil {
//                        self.isLiked = true
//                        self.likeButton.setImage(UIImage(named: "ic_like_blue_big_selected"), forState: UIControlState.Normal)
//                    } else {
//                        self.isLiked = false
//                        self.likeButton.setImage(UIImage(named: "ic_like_blue_big"), forState: UIControlState.Normal)
//                    }
//                }
//            })
//            return nil
//        })
//    }
//    
//    // In background.
//    private func saveLike() {
//        guard let postId = self.post?.postId else {
//            return
//        }
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        AWSClientManager.defaultClientManager().saveLike(postId, completionHandler: {
//            (task: AWSTask) in
//            dispatch_async(dispatch_get_main_queue(), {
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                if let error = task.error {
//                    print("saveLike error: \(error.localizedDescription)")
//                } else {
//                    print("saveLike success!")
//                }
//            })
//            return nil
//        })
//    }
//    
//    // In background.
//    private func removeLike() {
//        guard let postId = self.post?.postId else {
//            return
//        }
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        AWSClientManager.defaultClientManager().removeLike(postId, completionHandler: {
//            (task: AWSTask) in
//            dispatch_async(dispatch_get_main_queue(), {
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                if let error = task.error {
//                    print("removeLike error: \(error.localizedDescription)")
//                } else {
//                    print("removeLike success!")
//                }
//            })
//            return nil
//        })
//    }
//    
//    private func queryPostLikers() {
//        guard let postId = self.post?.postId else {
//            return
//        }
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        AWSClientManager.defaultClientManager().queryPostLikers(postId, completionHandler: {
//            (task: AWSTask) in
//            dispatch_async(dispatch_get_main_queue(), {
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                if let error = task.error {
//                    print("queryPostLikers error: \(error.localizedDescription)")
//                } else {
//                    if let output = task.result as? AWSDynamoDBPaginatedOutput,
//                        let awsLikes = output.items as? [AWSLike] {
//                        self.numberOfLikes = awsLikes.count
//                        let likesTitle = self.numberOfLikes > 1 ? "\(self.numberOfLikes) likes" : "\(self.numberOfLikes) like"
//                        //self.numberOfLikesButton.setTitle(likesTitle, forState: UIControlState.Normal)
//                    }
//                }
//            })
//            return nil
//        })
//    }
}
