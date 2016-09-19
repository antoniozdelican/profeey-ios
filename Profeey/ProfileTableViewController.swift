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
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    var user: User?
    var isCurrentUser: Bool = false
    
    private var currentUser: User?
    private var posts: [Post] = []
    private var topCategories: [Category] = []
    private var isLoadingPosts: Bool = true
    private var isFollowing: Bool = false
    private var selectedSegment: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.tableView.delaysContentTouches = false
        self.navigationItem.title = self.user?.preferredUsername
        
        // In case we come from another Vc.
        if self.user?.userId == AWSClientManager.defaultClientManager().credentialsProvider?.identityId {
            self.isCurrentUser = true
        }
        
        // Get currentUser.
        self.getCurrentUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? EditProfileTableViewController {
            childViewController.user = self.user
        }
        if let destinationViewController = segue.destinationViewController as? UsersTableViewController {
            destinationViewController.usersType = UsersType.Followers
            destinationViewController.userId = self.user?.userId
        }
        if let destinationViewController = segue.destinationViewController as? PostDetailsTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.post = self.posts[indexPath.row]
            // For likes delegate.
            destinationViewController.postIndexPath = indexPath
            destinationViewController.likeDelegate = self
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            guard self.selectedSegment == 0 else {
                return 0
            }
            if self.isLoadingPosts {
                return 1
            }
            if !self.isLoadingPosts && self.posts.count == 0 {
                return 1
            }
            return self.posts.count
        case 2:
            guard self.selectedSegment == 1 else {
                return 0
            }
            return self.topCategories.count
        case 3:
            guard self.selectedSegment == 1 else {
                return 0
            }
            return 0
        case 4:
            guard self.selectedSegment == 1 else {
                return 0
            }
            return 0
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileMain", forIndexPath: indexPath) as! ProfileMainTableViewCell
                cell.profilePicImageView.image = self.user?.profilePic
                cell.fullNameLabel.text = self.user?.fullName
                cell.professionNameLabel.text = self.user?.professionName
                cell.locationNameLabel.text = self.user?.locationName
                cell.aboutLabel.text = self.user?.about
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileButtons", forIndexPath: indexPath) as! ProfileButtonsTableViewCell
                
                cell.numberOfPostsButton.setTitle(self.user?.numberOfPostsInt.numberToString(), forState: UIControlState.Normal)
                cell.numberOfPostsButton.addTarget(self, action: #selector(ProfileTableViewController.postsButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                cell.numberOfFollowersButton.setTitle(self.user?.numberOfFollowersInt.numberToString(), forState: UIControlState.Normal)
                cell.numberOfFollowersButton.addTarget(self, action: #selector(ProfileTableViewController.followersButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                if self.user?.numberOfFollowersInt == 0 {
                    cell.numberOfFollowersButton.enabled = false
                    cell.setDisabledNumberOfFollowersButton()
                } else {
                    cell.numberOfFollowersButton.enabled = true
                    cell.setEnabledNumberOfFollowersButton()
                }
                
                if self.isCurrentUser {
                    cell.setEditButton()
                    cell.followButton.addTarget(self, action: #selector(ProfileTableViewController.editButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                } else {
                    self.isFollowing ? cell.setFollowingButton() : cell.setFollowButton()
                    cell.followButton.addTarget(self, action: #selector(ProfileTableViewController.followButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileSegmentedControl", forIndexPath: indexPath) as! ProfileSegmentedControlTableViewCell
                self.selectedSegment == 0 ? cell.setPostsButtonActive() : cell.setAboutButtonActive()
                cell.postsButton.addTarget(self, action: #selector(ProfileTableViewController.postsSegmentButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.aboutButton.addTarget(self, action: #selector(ProfileTableViewController.experienceSegmentButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            if self.isLoadingPosts {
                let cell = tableView.dequeueReusableCellWithIdentifier("cellLoading", forIndexPath: indexPath) as! LoadingTableViewCell
                return cell
            }
            if !self.isLoadingPosts && self.posts.count == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("cellEmpty", forIndexPath: indexPath) as! EmptyTableViewCell
                cell.emptyMessageLabel.text = "There's no posts yet"
                return cell
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostSmall", forIndexPath: indexPath) as! PostSmallTableViewCell
            let post = self.posts[indexPath.row]
            cell.postImageView.image = post.image
            cell.titleLabel.text = post.title
            cell.categoryNameLabel.text = post.categoryName
            cell.timeLabel.text = post.creationDateString
            cell.numberOfLikesLabel.text = post.numberOfLikesSmallString
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellTopCategory", forIndexPath: indexPath) as! TopCategoryTableViewCell
            let topCategory = self.topCategories[indexPath.row]
            cell.topCategoryNameLabel.text = topCategory.categoryName
            cell.numberOfPostsLabel.text = topCategory.numberOfPostsString
            return cell
        case 3:
            return UITableViewCell()
        case 4:
            return UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard self.selectedSegment == 1 else {
            return UITableViewCell()
        }
        guard section == 2 || section == 3 || section == 4 else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader") as! HeaderTableViewCell
        if section == 2 {
            cell.headerTitle.text = "TOP SKILLS"
        }
        if section == 3 {
            cell.headerTitle.text = "WORK EXPERIENCE"
        }
        if section == 4 {
            cell.headerTitle.text = "EDUCATION"
        }
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is PostSmallTableViewCell {
            self.performSegueWithIdentifier("segueToPostDetailsVc", sender: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            case 2:
                cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            default:
                return
            }
        case 1:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
        case 2:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        default:
            return
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 112.0
            case 1:
                return 50.0
            case 2:
                return 48.0
            default:
                return 0.0
            }
        case 1:
            if self.isLoadingPosts {
                return 120.0
            }
            if !self.isLoadingPosts && self.posts.count == 0 {
                return 120.0
            }
            return 108.0
        case 2:
            return 25.0
        default:
            return 0.0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                //return 112.0
                return UITableViewAutomaticDimension
            case 1:
                return 50.0
            case 2:
                return 48.0
            default:
                return 0.0
            }
        case 1:
            if self.isLoadingPosts {
                return 120.0
            }
            if !self.isLoadingPosts && self.posts.count == 0 {
                return 120.0
            }
            return 108.0
        case 2:
            return UITableViewAutomaticDimension
        default:
            return 0.0
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.selectedSegment == 1 else {
            return 0.0
        }
        guard section == 2 || section == 3 || section == 4 else {
            return 0.0
        }
        return 32.0
    }
    
    // MARK: IBActions
    
    @IBAction func settingsButtonTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let signOutAction = UIAlertAction(title: "Sign out", style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction) in
            self.signOut()
        })
        alertController.addAction(signOutAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToProfileTableViewController(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.sourceViewController as? EditProfileTableViewController {
            let updatedUser = sourceViewController.updatedUser
            self.user = updatedUser
            self.tableView.reloadData()
            // Remove image in background.
            if let profilePicUrlToRemove = sourceViewController.profilePicUrlToRemove {
                self.removeImage(profilePicUrlToRemove)
            }
        }
    }
    
    // MARK: Tappers
    
    func postsButtonTapped(sender: AnyObject) {
        let indexPath = NSIndexPath(forRow: 0, inSection: 1)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    func followersButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("segueToUsersVc", sender: self)
    }
    
    func editButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("segueToEditProfileVc", sender: self)
    }
    
    func followButtonTapped(sender: AnyObject) {
        let point = sender.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(point) else {
            return
        }
        guard let user = self.user else {
            return
        }
        guard let followingId = user.userId else {
            return
        }
        let numberOfFollowers = (user.numberOfFollowers != nil) ? user.numberOfFollowers! : 0
        let numberOfFollowersInteger = numberOfFollowers.integerValue
        if self.isFollowing {
            self.isFollowing = false
            user.numberOfFollowers = NSNumber(integer: (numberOfFollowersInteger - 1))
            self.unfollowUser(followingId)
        } else {
            self.isFollowing = true
            user.numberOfFollowers = NSNumber(integer: (numberOfFollowersInteger + 1))
            self.followUser(followingId)
        }
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func postsSegmentButtonTapped(sender: UIButton) {
        self.selectedSegment = 0
        self.tableView.reloadData()
    }
    
    func experienceSegmentButtonTapped(sender: UIButton) {
        self.selectedSegment = 1
        self.tableView.reloadData()
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(sender: AnyObject) {
        guard let userId = self.user?.userId else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.getUser(userId)
    }
    
    // MARK: AWS
    
    // So we can do actions!
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
                    let currentUser = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl)
                    self.currentUser = currentUser
                    
                    // In case it's an actual app user.
                    // Set by MainTabBarVc or if we come from another Vc.
                    // We duplicate call here to fetch all the data but that doesn't matter.
                    if self.isCurrentUser {
                        if let userId = currentUser.userId {
                            self.getUser(userId)
                        }
                    } else {
                        if let userId = self.user?.userId {
                            self.getUser(userId)
                            let indexPath = NSIndexPath(forRow: 1, inSection: 0)
                            self.getUserRelationship(userId, indexPath: indexPath)
                        }
                    }
                }
            })
            return nil
        })
    }
    
    private func getUser(userId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getUserDynamoDB(userId, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getUser error: \(error)")
                    self.refreshControl?.endRefreshing()
                } else {
                    guard let awsUser = task.result as? AWSUser else {
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, about: awsUser._about, locationName: awsUser._locationName, numberOfFollowers: awsUser._numberOfFollowers, numberOfPosts: awsUser._numberOfPosts, topCategories: awsUser._topCategories)
                    self.user = user
                    self.navigationItem.title = self.user?.preferredUsername
                    let indexSet = NSIndexSet(index: 0)
                    self.tableView.reloadSections(indexSet, withRowAnimation: UITableViewRowAnimation.None)
                    
                    if let profilePicUrl = awsUser._profilePicUrl {
                        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                        self.downloadImage(profilePicUrl, imageType: .UserProfilePic, indexPath: indexPath)
                    }
                    if let userId = awsUser._userId {
                        self.queryUserCategoriesNumberOfPostsSorted(userId)
                        self.queryUserPostsDateSorted(userId)
                    }
                }
            })
            return nil
        })
    }
    
    private func queryUserCategoriesNumberOfPostsSorted(userId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserCategoriesNumberOfPostsSortedDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("queryUserCategoriesNumberOfPostsSorted error: \(error)")
                    self.refreshControl?.endRefreshing()
                } else {
                    guard let awsUserCategories = response?.items as? [AWSUserCategory] else {
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    guard awsUserCategories.count > 0 else {
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    // Reset topCategories.
                    self.topCategories = []
                    for (_, awsUserCategory) in awsUserCategories.enumerate() {
                        let category = Category(categoryName: awsUserCategory._categoryName, numberOfPosts: awsUserCategory._numberOfPosts)
                        self.topCategories.append(category)
                    }
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            })
        })
    }
    
    private func queryUserPostsDateSorted(userId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserPostsDateSortedDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("queryUserPostsDateSorted error: \(error)")
                    self.isLoadingPosts = false
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                } else {
                    guard let awsPosts = response?.items as? [AWSPost] else {
                        self.isLoadingPosts = false
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    guard awsPosts.count > 0 else {
                        self.isLoadingPosts = false
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    // Reset posts.
                    self.posts = []
                    for (index, awsPost) in awsPosts.enumerate() {
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, categoryName: awsPost._categoryName, creationDate: awsPost._creationDate, postDescription: awsPost._description, imageUrl: awsPost._imageUrl, numberOfLikes: awsPost._numberOfLikes, title: awsPost._title, user: self.user)
                        self.posts.append(post)
                        self.isLoadingPosts = false
                        self.tableView.reloadData()
                        
                        if let imageUrl = awsPost._imageUrl {
                            let indexPath = NSIndexPath(forRow: index, inSection: 1)
                            self.downloadImage(imageUrl, imageType: .PostPic, indexPath: indexPath)
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
                self.user?.profilePic = image
                self.tableView.reloadData()
            case .PostPic:
                self.posts[indexPath.row].image = image
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
                                self.user?.profilePic = image
                                self.tableView.reloadData()
                            case .PostPic:
                                self.posts[indexPath.row].image = image
                                self.tableView.reloadData()
                            default:
                                return
                            }
                        }
                    })
            })
        }
    }
    
    // In background when user deletes/changes profilePic.
    private func removeImage(imageKey: String) {
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").contentWithKey(imageKey)
        
        print("removeImageS3:")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        content.removeRemoteContentWithCompletionHandler({
            (content: AWSContent?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                   print("removeImageS3 error: \(error)")
                } else {
                    print("removeImageS3 success")
                    content?.removeLocal()
                }
            })
        })
    }
    
    // Check if currentUser is following this user.
    private func getUserRelationship(followingId: String, indexPath: NSIndexPath) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getUserRelationshipDynamoDB(followingId, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getUserRelationship error: \(error)")
                } else {
                    if task.result != nil {
                        self.isFollowing = true
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                    }
                }
            })
            return nil
        })
    }
    
    // Followings are done in background.
    private func followUser(followingId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserRelationshipDynamoDB(followingId, follower: self.currentUser,completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("followUser error: \(error)")
                }
            })
            return nil
        })
    }
    
    private func unfollowUser(followingId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeUserRelationshipDynamoDB(followingId, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("unfollowUser error: \(error)")
                }
            })
            return nil
        })
    }
    
    private func signOut() {
        AWSClientManager.defaultClientManager().signOut({
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                if let error = task.error {
                    print("signOut error: \(error)")
                } else {
                    self.redirectToOnboarding()
                }
            })
            return nil
        })
    }
    
    // MARK: Helpers
    
    private func redirectToOnboarding() {
        guard let window = UIApplication.sharedApplication().keyWindow,
            let initialViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
}

extension ProfileTableViewController: LikeDelegate {
    
    func togglePostLike(postIndexPath: NSIndexPath?, numberOfLikes: NSNumber?) {
        guard let indexPath = postIndexPath else {
            return
        }
        guard let numberOfLikes = numberOfLikes else {
            return
        }
        self.posts[indexPath.row].numberOfLikes = numberOfLikes
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
}
