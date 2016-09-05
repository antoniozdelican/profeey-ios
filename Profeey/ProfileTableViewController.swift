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
    private var posts: [Post] = []
    private var numberOfPosts: Int?
    var isCurrentUser: Bool = false
    var isFollowing: Bool = false
    private var isUploading: Bool = false
    
    private var selectedSegment: Int = 0
    
    private var topCategories: [String] = []
    private var topCategoriesNumberOfPosts: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.navigationItem.title = nil
        self.tableView.delaysContentTouches = false
        
        if self.isCurrentUser {
            // Set by MaintTabBarController.
            self.getCurrentUser()
        } else {
            // User should already be set by other VC.
            if self.user?.userId == AWSClientManager.defaultClientManager().credentialsProvider?.identityId {
                // In case current user come to this VC from another parent (example search).
                self.isCurrentUser = true
            }
            self.navigationItem.title = self.user?.preferredUsername
            self.getUserRelationship()
            
            // Get posts.
            if let userId = self.user?.userId {
                self.queryUserPostsDateSorted(userId)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? EditProfileTableViewController {
            destinationViewController.user = self.user
            destinationViewController.editProfileDelegate = self
        }
        if let destinationViewController = segue.destinationViewController as? UsersTableViewController {
            // Followers.
            destinationViewController.isLikers = false
        }
        if let destinationViewController = segue.destinationViewController as? PostDetailsTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.post = self.posts[indexPath.row]
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 13
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // ProfileMain.
            return 1
        case 1:
            // ProfileButtons.
            return 1
        case 2:
            // ProfileSegmentedControl.
            return 1
        case 3:
            // Uploading.
            if self.selectedSegment == 0 {
                return self.isUploading ? 1 : 0
            } else {
                return 0
            }
        case 4:
            // PostsSmall.
            return self.selectedSegment == 0 ? self.posts.count : 0
        case 5:
            // ProfileHeader About.
            return self.selectedSegment == 0 ? 0 : 1
        case 6:
            // Profile About.
            return self.selectedSegment == 0 ? 0 : 1
        case 7:
            // ProfileHeader TopCategories.
            return self.selectedSegment == 0 ? 0 : 1
        case 8:
            // ProfileTopCategories
            return self.selectedSegment == 0 ? 0 : self.topCategories.count
        case 9:
            // ProfileHeader WorkExperience.
            return self.selectedSegment == 0 ? 0 : 1
        case 10:
            // WorkExperience
            return self.selectedSegment == 0 ? 0 : 1
        case 11:
            // ProfileHeader Education.
            return self.selectedSegment == 0 ? 0 : 1
        case 12:
            // Education
            return self.selectedSegment == 0 ? 0 : 1
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileMain", forIndexPath: indexPath) as! ProfileMainTableViewCell
            cell.profilePicImageView.image = self.user?.profilePic
            cell.fullNameLabel.text = self.user?.fullName
            cell.professionLabel.text = self.user?.profession
            cell.locationLabel.text = self.user?.location
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileButtons", forIndexPath: indexPath) as! ProfileButtonsTableViewCell
            if self.isCurrentUser {
                cell.setEditButton()
                cell.followButton.addTarget(self, action: #selector(ProfileTableViewController.editButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            } else if self.isFollowing {
                cell.setFollowingButton()
                cell.followButton.addTarget(self, action: #selector(ProfileTableViewController.followButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                cell.setFollowButton()
                cell.followButton.addTarget(self, action: #selector(ProfileTableViewController.followButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            cell.numberOfPostsButton.setTitle(self.numberOfPosts?.numberToString(), forState: UIControlState.Normal)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileSegmentedControl", forIndexPath: indexPath) as! ProfileSegmentedControlTableViewCell
            self.selectedSegment == 0 ? cell.setPostsButtonActive() : cell.setAboutButtonActive()
            cell.postsButton.addTarget(self, action: #selector(ProfileTableViewController.postsSegmentButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.aboutButton.addTarget(self, action: #selector(ProfileTableViewController.aboutSegmentButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellUploading", forIndexPath: indexPath) as! UploadingTableViewCell
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPostSmall", forIndexPath: indexPath) as! PostSmallTableViewCell
            let post = posts[indexPath.row]
            cell.postImageView.image = post.image
            cell.titleLabel.text = post.title
            cell.categoryLabel.text = post.category
            cell.timeLabel.text = post.creationDateString
            return cell
        case 5:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileHeader", forIndexPath: indexPath) as! ProfileHeaderTableViewCell
            cell.headerLabel.text = "About"
            return cell
        case 6:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileAbout", forIndexPath: indexPath) as! ProfileAboutTableViewCell
            cell.aboutLabel.text = self.user?.about
            return cell
        case 7:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileHeader", forIndexPath: indexPath) as! ProfileHeaderTableViewCell
            cell.headerLabel.text = "Top Skills"
            return cell
        case 8:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileTopCategory", forIndexPath: indexPath) as! ProfileTopCategoryTableViewCell
            cell.topCategoryNameLabel.text = self.topCategories[indexPath.row]
            let numberOfPosts = self.topCategoriesNumberOfPosts[indexPath.row]
            let numberOfPostsText = numberOfPosts > 1 ? "\(numberOfPosts.numberToString()) posts" : "\(numberOfPosts.numberToString()) post"
            cell.numberOfPostsLabel.text = numberOfPostsText
            return cell
        case 9:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileHeader", forIndexPath: indexPath) as! ProfileHeaderTableViewCell
            cell.headerLabel.text = "Work Expericence"
            return cell
        case 10:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileExperience", forIndexPath: indexPath) as! ProfileExperienceTableViewCell
            cell.positionLabel.text = "Agricultural Engineer"
            cell.organizationLabel.text = "Food, Inc."
            cell.timePeriodLabel.text = "Sep 2014 - Jul 2016"
            return cell
        case 11:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileHeader", forIndexPath: indexPath) as! ProfileHeaderTableViewCell
            cell.headerLabel.text = "Education"
            return cell
        case 12:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfileExperience", forIndexPath: indexPath) as! ProfileExperienceTableViewCell
            cell.positionLabel.text = "PhD in Agricultural Engineering"
            cell.organizationLabel.text = "Stanford University"
            cell.timePeriodLabel.text = "Sep 2006 - Jun 2010"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 4 {
            self.performSegueWithIdentifier("segueToPostDetailsVc", sender: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        switch indexPath.section {
        case 0:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 3:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 4:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
        case 5:
            if self.user?.about != nil {
                cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            } else {
                cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
            }
        case 6:
            cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        case 7:
            if self.topCategories.count > 0 {
                cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            } else {
                cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
            }
        case 8:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 9:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 10:
            cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        case 11:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 12:
            cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        default:
            return
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 112.0
        case 1:
            return 50.0
        case 2:
            return 50.0
        case 3:
            return 72.0
        case 4:
            return 108.0
        case 5:
            return 50.0
        case 6:
            return 37.0
        case 7:
            return 50.0
        case 8:
            return 29.0
        case 9:
            return 50.0
        case 10:
            return 74.0
        case 11:
            return 50.0
        case 12:
            return 74.0
        default:
            return 0.0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 112.0
        case 1:
            return 50.0
        case 2:
            return 50.0
        case 3:
            return 72.0
        case 4:
            return 108.0
        case 5:
            return 50.0
        case 6:
            return UITableViewAutomaticDimension
        case 7:
            return 50.0
        case 8:
            return UITableViewAutomaticDimension
        case 9:
            return 50.0
        case 10:
            return UITableViewAutomaticDimension
        case 11:
            return 50.0
        case 12:
            return UITableViewAutomaticDimension
        default:
            return 0.0
        }
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
        if segue.identifier == "segueUnwindToProfileVc",
            let sourceViewController = segue.sourceViewController as? EditPostTableViewController {
            guard let imageData = sourceViewController.imageData else {
                    return
            }
            self.isUploading = true
            self.tableView.reloadData()
            self.uploadImage(imageData, title: sourceViewController.postTitle, description: sourceViewController.postDescription, category: sourceViewController.category)
        }
    }
    
    // MARK: Tappers
    
    func editButtonTapped(sender: UIButton) {
        self.performSegueWithIdentifier("segueToEditProfileVc", sender: self)
    }
    
    func followButtonTapped(sender: UIButton) {
        self.isFollowing ? self.unfollowUser() : self.followUser()
    }
    
    func postsSegmentButtonTapped(sender: UIButton) {
        self.selectedSegment = 0
        self.tableView.reloadData()
    }
    
    func aboutSegmentButtonTapped(sender: UIButton) {
        self.selectedSegment = 1
        self.tableView.reloadData()
    }
    
    // MARK: AWS
    
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
                        let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, profession: awsUser._profession, profilePicUrl: awsUser._profilePicUrl, location: awsUser._location, about: awsUser._about)
                        self.user = user
                        self.tableView.reloadData()
                        self.navigationItem.title = self.user?.preferredUsername
                        
                        // Get profilePic.
                        if let profilePicUrl = awsUser._profilePicUrl {
                            self.downloadImage(profilePicUrl, indexPath: nil, isUserProfilePic: true)
                        }
                        
                        // Query user posts.
                        if let userId = awsUser._userId {
                            self.queryUserPostsDateSorted(userId)
                        }
                    }
                }
            })
            return nil
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
                } else {
                    if let awsPosts = response?.items as? [AWSPost] {
                        
                        // Update posts count.
                        self.numberOfPosts = awsPosts.count
                        self.tableView.reloadData()
                        
                        // Update top categories.
                        self.updateTopCategories(awsPosts.flatMap({$0._category}))
                        
                        // Iterate through all posts.
                        for (index, awsPost) in awsPosts.enumerate() {
                            
                            let indexPath = NSIndexPath(forRow: index, inSection: 4)
                            // Data is denormalized so we store user data in posts table!
                            let user = self.user
                            let post = Post(postId: awsPost._postId, title: awsPost._title, postDescription: awsPost._description, imageUrl: awsPost._imageUrl, category: awsPost._category, creationDate: awsPost._creationDate, user: user)
                            self.posts.append(post)
                            self.tableView.reloadData()
                            
                            // Get postPic.
                            if let imageUrl = awsPost._imageUrl {
                                self.downloadImage(imageUrl, indexPath: indexPath, isUserProfilePic: false)
                            }
                        }
                    }
                }
            })
        })
    }
    
    // In background assuming it will not fail :)
    private func savePost(imageData: NSData, imageUrl: String?, title: String?, description: String?, category: String?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().savePostDynamoDB(imageUrl, title: title, description: description, category: category, user: self.user, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("savePost error: \(error)")
                } else {
                    if let awsPost = task.result as? AWSPost {
                        let user = self.user
                        let post = Post(postId: awsPost._postId, title: awsPost._title, postDescription: awsPost._description, imageUrl: awsPost._imageUrl, category: awsPost._category, creationDate: awsPost._creationDate, user: user)
                        let image = UIImage(data: imageData)
                        post.image = image
                        self.posts.insert(post, atIndex: 0)
                        self.isUploading = false
                        self.tableView.reloadData()
                    }
                }
            })
            return nil
        })
    }
    
    private func downloadImage(imageKey: String, indexPath: NSIndexPath?, isUserProfilePic: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").contentWithKey(imageKey)
        // TODO check if content.isImage()
        if content.cached {
            print("Content cached:")
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            if isUserProfilePic {
                self.user?.profilePic = image
            } else if let indexPath = indexPath {
                self.posts[indexPath.row].image = image
                self.tableView.reloadData()
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
                                if isUserProfilePic {
                                    self.user?.profilePic = image
                                    self.tableView.reloadData()
                                } else if let indexPath = indexPath {
                                    self.posts[indexPath.row].image = image
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    })
            })
        }
    }
    
    private func uploadImage(imageData: NSData, title: String?, description: String?, category: String?) {
        let uniqueImageName = NSUUID().UUIDString.lowercaseString.stringByReplacingOccurrencesOfString("-", withString: "")
        let imageKey = "public/\(uniqueImageName).jpg"
        let localContent = AWSUserFileManager.custom(key: "USEast1BucketManager").localContentWithData(imageData, key: imageKey)
        
        print("uploadImageS3:")
        self.isUploading = true
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
                        print("uploadImageS3 error: \(error)")
                        self.isUploading = false
                        self.tableView.reloadData()
                        let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        // Save post in DynamoDB.
                        self.savePost(imageData, imageUrl: imageKey, title: title, description: description, category: category)
                    }
                })
            })
    }
    
    // Check if currentUser is following this user.
    private func getUserRelationship() {
        guard let followingId = self.user?.userId else {
            return
        }
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
                        self.tableView.reloadData()
                    }
                }
            })
            return nil
        })
    }
    
    private func followUser() {
        guard let followingId = self.user?.userId else {
            return
        }
        // Setting following user info for faster query on Home.
        // Data is denormalized.
        let followingFirstName = self.user?.firstName
        let followingLastName = self.user?.lastName
        let followingPreferredUsername = self.user?.preferredUsername
        let followingProfession = self.user?.profession
        let followingProfilePicUrl = self.user?.profilePicUrl
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserRelationshipDynamoDB(followingId, followingFirstName: followingFirstName, followingLastName: followingLastName, followingPreferredUsername: followingPreferredUsername, followingProfession: followingProfession, followingProfilePicUrl: followingProfilePicUrl, numberOfNewPosts: nil,completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("followUser error: \(error)")
                } else {
                    self.isFollowing = true
                    self.tableView.reloadData()
                }
            })
            return nil
        })
    }
    
    private func unfollowUser() {
        guard let followingId = self.user?.userId else {
            return
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeUserRelationshipDynamoDB(followingId, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("unfollowUser error: \(error)")
                } else {
                    self.isFollowing = false
                    self.tableView.reloadData()
                }
            })
            return nil
        })
    }
    
    private func signOut() {
        AWSClientManager.defaultClientManager().signOut({
            (task: AWSTask) in
            if let error = task.error {
                print(error)
            }
            return nil
        })
    }
    
    private func updateTopCategories(categories: [String]) {
        // Get frequency of each category (aka number of posts).
        var categoryFrequencies = [String: Int]()
        for category in categories {
            if categoryFrequencies[category] == nil {
                categoryFrequencies[category] = 1
            } else {
                categoryFrequencies[category] = categoryFrequencies[category]! + 1
            }
        }
        
        // Sorted categories by number of frequency (aka number posts).
        let sortedCategories = Array(categoryFrequencies.keys).sort({ categoryFrequencies[$0] > categoryFrequencies[$1] })
        var sortedCategoriesNumbers = [Int]()
        for category in sortedCategories {
            sortedCategoriesNumbers.append(categoryFrequencies[category]!)
        }
        
        // Set only top 5 categories.
        self.topCategories = Array(sortedCategories.prefix(5))
        self.topCategoriesNumberOfPosts = Array(sortedCategoriesNumbers.prefix(5))
        self.tableView.reloadData()
    }
}

extension ProfileTableViewController: EditProfileDelegate {
    
    func userUpdated(user: User?) {
        self.user = user
        self.tableView.reloadData()
        self.navigationItem.title = self.user?.preferredUsername
    }
}
