//
//  HomeTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

enum ImageType {
    case CurrentUserProfilePic
    case UserProfilePic
    case PostPic
}

class HomeTableViewController: UITableViewController {
    
    private var user: User?
    private var posts: [Post] = []
    // Before any post is loaded.
    private var isLoadingPosts: Bool = true
    // When uploading new post.
    private var isUploading: Bool = false
    private var newPostProgress: NSProgress?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        // Get currentUser.
        if let currentUser = AWSClientManager.defaultClientManager().userPool?.currentUser() where currentUser.signedIn {
            self.getCurrentUser()
        }
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
        if let destinationViewController = segue.destinationViewController as? CategoryTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.categoryName = self.posts[indexPath.section].categoryName
        }
        if let destinationViewController = segue.destinationViewController as? UsersTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.usersType = UsersType.Likers
            destinationViewController.postId = self.posts[indexPath.section].postId
        }
        
        // TEST
        if let destinationViewController = segue.destinationViewController as? PostDetailsTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.post = self.posts[indexPath.section]
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.isLoadingPosts {
            return 1
        }
        if !self.isLoadingPosts && self.posts.count == 0 {
            return 1
        }
        return self.posts.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingPosts {
            return 1
        }
        if !self.isLoadingPosts && self.posts.count == 0 {
            return 1
        }
        if section == 0 && self.isUploading {
            return 2
        }
        return 6
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.isLoadingPosts {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellLoading", forIndexPath: indexPath) as! LoadingTableViewCell
            return cell
        }
        if !self.isLoadingPosts && self.posts.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellEmpty", forIndexPath: indexPath) as! EmptyTableViewCell
            cell.emptyMessageLabel.text = "You are not following anyone. \n Connect with people and discover their skills."
            return cell
        }
        if indexPath.section == 0 && self.isUploading {
            // Dummy post user.
            let user = self.posts[indexPath.section].user
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellPostUser", forIndexPath: indexPath) as! PostUserTableViewCell
                cell.profilePicImageView.image = user?.profilePic
                cell.fullNameLabel.text = user?.fullName
                cell.professionNameLabel.text = user?.professionName
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellUploading", forIndexPath: indexPath) as! UploadingTableViewCell
                if let progress = self.newPostProgress {
                    cell.progressView.progress = Float(progress.fractionCompleted)
                }
                return cell
            default:
                return UITableViewCell()
            }
        }
        let post = self.posts[indexPath.section]
        let user = post.user
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostUser", forIndexPath: indexPath) as! PostUserTableViewCell
            cell.profilePicImageView.image = user?.profilePic
            cell.fullNameLabel.text = user?.fullName
            cell.professionNameLabel.text = user?.professionName
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostImage", forIndexPath: indexPath) as! PostImageTableViewCell
            cell.postImageView.image = post.image
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
            cell.likeButton.addTarget(self, action: #selector(HomeTableViewController.likeButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.numberOfLikesButton.hidden = (post.numberOfLikesString != nil) ? false : true
            cell.numberOfLikesButton.setTitle(post.numberOfLikesString, forState: UIControlState.Normal)
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
        // TEST
        if cell is PostSmallTableViewCell {
            self.performSegueWithIdentifier("segueToPostDetailsVc", sender: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        if indexPath.row == 5 {
           cell.separatorInset = UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0)
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.isLoadingPosts {
            return 120.0
        }
        if !self.isLoadingPosts && self.posts.count == 0 {
            return 120.0
        }
        switch indexPath.row {
        case 0:
            return 65.0
        case 1:
            if indexPath.section == 0 && self.isUploading {
                return 40.0
            }
            let width = tableView.bounds.width - 24.0
            let height = width / 1.5
            return height
        case 2:
            return 30.0
        case 3:
            return 21.0
        case 4:
            return 21.0
        case 5:
            return 49.0
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.isLoadingPosts {
            return 120.0
        }
        if !self.isLoadingPosts && self.posts.count == 0 {
            return 120.0
        }
        switch indexPath.row {
        case 0:
            return 65.0
        case 1:
            if indexPath.section == 0 && self.isUploading {
                return 40.0
            }
            let width = tableView.bounds.width - 24.0
            let height = width / 1.5
            return height
        case 2:
            return UITableViewAutomaticDimension
        case 3:
            return UITableViewAutomaticDimension
        case 4:
            return 21.0
        case 5:
            return 49.0
        default:
            return 0
        }
    }
    
    // MARK: Tappers
    
    func likeButtonTapped(sender: AnyObject) {
        let point = sender.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(point) else {
            return
        }
        let post = self.posts[indexPath.section]
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
    }
    
    func numberOfLikesButtonTapped(sender: AnyObject) {
        let point = sender.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(point) else {
            return
        }
        self.performSegueWithIdentifier("segueToUsersVc", sender: indexPath)
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(sender: AnyObject) {
        guard let userId = self.user?.userId else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.posts = []
        self.queryUserActivitiesDateSorted(userId)
    }
    
    @IBAction func unwindToHomeTableViewController(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.sourceViewController as? EditPostTableViewController {
            guard let imageData = sourceViewController.imageData else {
                return
            }
            self.isUploading = true
            // Add dummy post for uploading.
            let dummyPost = Post()
            dummyPost.user = self.user
            self.posts.insert(dummyPost, atIndex: 0)
            self.tableView.reloadData()
            
            self.uploadImage(imageData, title: sourceViewController.postTitle, description: sourceViewController.postDescription, categoryName: sourceViewController.categoryName)
        }
    }
    
    // MARK: AWS
    
    // Gets currentUser and credentialsProvider.idenityId
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
                    self.user = user
                    
                    if let profilePicUrl = awsUser._profilePicUrl {
                        self.downloadImage(profilePicUrl, imageType: .CurrentUserProfilePic, indexPath: nil)
                    }
                    if let userId = awsUser._userId {
                        self.queryUserActivitiesDateSorted(userId)
                    }
                }
            })
            return nil
        })
    }
    
    // Query the FEED!!!
    private func queryUserActivitiesDateSorted(userId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserActivitiesDateSortedDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("queryUserActivitiesDateSorted error: \(error)")
                    self.isLoadingPosts = false
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                } else {
                    guard let awsActivities = response?.items as? [AWSActivity] else {
                        self.isLoadingPosts = false
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    guard awsActivities.count > 0 else {
                        self.isLoadingPosts = false
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    for (index, awsActivity) in awsActivities.enumerate() {
                        let user = User(userId: awsActivity._postUserId, firstName: awsActivity._firstName, lastName: awsActivity._lastName, preferredUsername: awsActivity._preferredUsername, professionName: awsActivity._professionName, profilePicUrl: awsActivity._profilePicUrl)
                        let post = Post(userId: awsActivity._postUserId, postId: awsActivity._postId, categoryName: awsActivity._categoryName, creationDate: awsActivity._creationDate, postDescription: awsActivity._description, imageUrl: awsActivity._imageUrl, numberOfLikes: awsActivity._numberOfLikes, title: awsActivity._title, user: user)
                        self.posts.append(post)
                        self.isLoadingPosts = false
                        self.tableView.reloadData()
                        
                        if let profilePicUrl = awsActivity._profilePicUrl {
                            let indexPath = NSIndexPath(forRow: 0, inSection: index)
                            self.downloadImage(profilePicUrl, imageType: .UserProfilePic, indexPath: indexPath)
                        }
                        if let imageUrl = awsActivity._imageUrl {
                            let indexPath = NSIndexPath(forRow: 1, inSection: index)
                            self.downloadImage(imageUrl, imageType: .PostPic, indexPath: indexPath)
                        }
                        if let postId = awsActivity._postId {
                            let indexPath = NSIndexPath(forRow: 5, inSection: index)
                            self.getLike(postId, indexPath: indexPath)
                        }
                    }
                    self.refreshControl?.endRefreshing()
                }
            })
        })
    }
    
    private func downloadImage(imageKey: String, imageType: ImageType, indexPath: NSIndexPath?) {
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
            case .CurrentUserProfilePic:
                self.user?.profilePic = image
            case .UserProfilePic:
                if let indexPath = indexPath {
                    self.posts[indexPath.section].user?.profilePic = image
                    self.tableView.reloadData()
                }
            case .PostPic:
                if let indexPath = indexPath {
                    self.posts[indexPath.section].image = image
                    self.tableView.reloadData()
                }
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
                                case .CurrentUserProfilePic:
                                    self.user?.profilePic = image
                                case .UserProfilePic:
                                    if let indexPath = indexPath {
                                        self.posts[indexPath.section].user?.profilePic = image
                                        self.tableView.reloadData()
                                    }
                                case .PostPic:
                                    if let indexPath = indexPath {
                                        self.posts[indexPath.section].image = image
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    })
            })
        }
    }
    
    private func uploadImage(imageData: NSData, title: String?, description: String?, categoryName: String?) {
        let uniqueImageName = NSUUID().UUIDString.lowercaseString.stringByReplacingOccurrencesOfString("-", withString: "")
        let imageKey = "public/\(uniqueImageName).jpg"
        let localContent = AWSUserFileManager.custom(key: "USEast1BucketManager").localContentWithData(imageData, key: imageKey)
        
        print("uploadImageS3:")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        localContent.uploadWithPinOnCompletion(
            false,
            progressBlock: {
                (content: AWSLocalContent?, progress: NSProgress?) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.newPostProgress = progress
                    let indexPath = NSIndexPath(forRow: 1, inSection: 0)
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                })
            }, completionHandler: {
                (content: AWSLocalContent?, error: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    if let error = error {
                        print("uploadImageS3 error: \(error)")
                        self.isUploading = false
                        // Remove dummy post.
                        self.posts.removeAtIndex(0)
                        self.tableView.reloadData()
                        let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        // Save post in DynamoDB.
                        self.savePost(imageData, imageUrl: imageKey, title: title, description: description, categoryName: categoryName)
                    }
                })
        })
    }
    
    private func savePost(imageData: NSData, imageUrl: String?, title: String?, description: String?, categoryName: String?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().savePostDynamoDB(imageUrl, title: title, description: description, categoryName: categoryName, user: self.user, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("savePost error: \(error)")
                    self.isUploading = false
                    // Remove dummy post.
                    self.posts.removeAtIndex(0)
                    self.tableView.reloadData()
                } else {
                    if let awsPost = task.result as? AWSPost {
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, categoryName: awsPost._categoryName, creationDate: awsPost._creationDate, postDescription: awsPost._description, imageUrl: awsPost._imageUrl, numberOfLikes: awsPost._numberOfLikes, title: awsPost._title, user: self.user)
                        let image = UIImage(data: imageData)
                        post.image = image
                        
                        self.isUploading = false
                        // Remove dummy post.
                        self.posts.removeAtIndex(0)
                        // Add new post.
                        self.posts.insert(post, atIndex: 0)
                        self.tableView.reloadData()
                    }
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
                        self.posts[indexPath.section].isLikedByCurrentUser = true
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                    }
                }
            })
            return nil
        })
    }
    
    // Save and remove like are done in background.
    private func saveLike(postId: String, postUserId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveLikeDynamoDB(postId, postUserId: postUserId, liker: self.user, completionHandler: {
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
