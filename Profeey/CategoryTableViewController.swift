//
//  CategoryTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class CategoryTableViewController: UITableViewController {

    var categoryName: String?
    private var posts: [Post] = []
    private var isLoadingPosts: Bool = false
    private var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.title = self.categoryName
        
        // Get current user.
        self.getCurrentUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? ProfileTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.user = self.posts[indexPath.section].user
        }
        if let destinationViewController = segue.destinationViewController as? UsersTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.postId = self.posts[indexPath.section].postId
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.posts.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.section]
        
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
            if post.numberOfLikesString == nil {
                cell.numberOfLikesButton.hidden = true
            }
            //cell.numberOfLikesLabel.text = post.numberOfLikesString
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
        let buttonPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = tableView.indexPathForRowAtPoint(buttonPoint) else {
            return
        }
        let post = self.posts[indexPath.section]
        guard let postId = post.postId,
            let postUserId = post.userId else {
            return
        }
        if post.isLikedByCurrentUser {
            post.isLikedByCurrentUser = false
            if let oldNumberOfLikes = post.numberOfLikes?.integerValue {
                let newNumberOfLikes = oldNumberOfLikes - 1
                post.numberOfLikes = NSNumber(integer: newNumberOfLikes)
            }
            self.tableView.reloadData()
            // In background.
            self.removeLike(postId, postUserId: postUserId)
        } else {
            post.isLikedByCurrentUser = true
            if let oldNumberOfLikes = post.numberOfLikes?.integerValue {
                let newNumberOfLikes = oldNumberOfLikes + 1
                post.numberOfLikes = NSNumber(integer: newNumberOfLikes)
            }
            self.tableView.reloadData()
            // In background.
            self.saveLike(postId, postUserId: postUserId)
        }
    }
    
    func numberOfLikesButtonTapped(sender: UIButton) {
        let buttonPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = tableView.indexPathForRowAtPoint(buttonPoint) else {
            return
        }
        self.performSegueWithIdentifier("segueToUsersVc", sender: indexPath)
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
                        
                        // Only now query posts.
                        self.queryCategoryPostsDateSorted()
                    }
                }
            })
            return nil
        })
    }
    
    private func queryCategoryPostsDateSorted() {
        guard let categoryName = self.categoryName else {
            return
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryCategoryPostsDateSortedDynamoDB(categoryName, completionHandler: {
            (reponse: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("queryCategoryPostsDateSorted error: \(error)")
                } else {
                    if let awsPosts = reponse?.items as? [AWSPost] {
                        for (index, awsPost) in awsPosts.enumerate() {
                            let user = User(userId: awsPost._userId, firstName: awsPost._firstName, lastName: awsPost._lastName, preferredUsername: awsPost._preferredUsername, professionName: awsPost._professionName, profilePicUrl: awsPost._profilePicUrl)
                            let post = Post(userId: awsPost._userId, postId: awsPost._postId, categoryName: awsPost._categoryName, creationDate: awsPost._creationDate, postDescription: awsPost._description, imageUrl: awsPost._imageUrl, numberOfLikes: awsPost._numberOfLikes, title: awsPost._title, user: user)
                            self.posts.append(post)
                            self.tableView.reloadData()
                            
                            // Get like
                            if let postId = awsPost._postId {
                                let indexPath = NSIndexPath(forRow: 5, inSection: index)
                                self.getLike(postId, indexPath: indexPath)
                            }
                            
                            // Get profilePic
                            if let profilePicUrl = awsPost._profilePicUrl {
                                let indexPath = NSIndexPath(forRow: 0, inSection: index)
                                self.downloadImage(profilePicUrl, imageType: .UserProfilePic, indexPath: indexPath)
                            }
                            
                            // Get postPic.
                            if let imageUrl = awsPost._imageUrl {
                                let indexPath = NSIndexPath(forRow: 1, inSection: index)
                                self.downloadImage(imageUrl, imageType: .PostPic, indexPath: indexPath)
                            }
                        }
                    }
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
                self.posts[indexPath.section].user?.profilePic = image
                self.tableView.reloadData()
            case .PostPic:
                self.posts[indexPath.section].image = image
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
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                switch imageType {
                                case .UserProfilePic:
                                    self.posts[indexPath.section].user?.profilePic = image
                                    self.tableView.reloadData()
                                case .PostPic:
                                    self.posts[indexPath.section].image = image
                                    self.tableView.reloadData()
                                default:
                                    return
                                }
                            }
                        }
                    })
            })
        }
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
                        self.posts[indexPath.section].isLikedByCurrentUser = true
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
