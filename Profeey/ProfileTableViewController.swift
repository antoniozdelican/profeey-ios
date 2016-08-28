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
    private var postsCount = 0
    var isCurrentUser: Bool = false
    var isFollowing: Bool = false
    
    private var topCategories: [String] = []
    private var topCategoriesNumberOfPosts: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.navigationItem.title = nil
        self.tableView.delaysContentTouches = false
        self.settingsButton.image = UIImage(named: "ic_settings")
        
        if self.isCurrentUser {
            self.getCurrentUser()
        } else {
            // User should already be set by other vc.
            self.navigationItem.title = self.user?.preferredUsername
            // Check if this user is followed by currentUser.
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
    
    // MARK: Configuration
    
    private func configureUser(user: User?) {
        self.user = user
        // Always reload section 0 for a user!
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
        self.navigationItem.title = self.user?.preferredUsername
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
        
        if let navigationController = segue.destinationViewController as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? PostDetailsTableViewController,
            let indexPath = sender as? NSIndexPath {
            childViewController.post = self.posts[indexPath.row]
        }
        if let destinationViewController = segue.destinationViewController as? PostDetailsTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.post = self.posts[indexPath.row]
        }
        if let destinationViewController = segue.destinationViewController as? ExperienceTableViewController,
            let indexPath = sender as? NSIndexPath {
            if indexPath.section == 2 {
                destinationViewController.isEducation = false
            } else {
                destinationViewController.isEducation = true
            }
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 7
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Profile cell.
            return 1
        case 1:
            // About cell.
            return 1
        case 2:
            return 0
        case 3:
            return 0
        case 4:
            // Top categories cells.
            return self.topCategories.count
        case 5:
            return 1
        default:
            // Posts cells.
            return self.posts.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellProfile", forIndexPath: indexPath) as! ProfileTableViewCell
            cell.profilePicImageView.image = self.user?.profilePic
            cell.fullNameLabel.text = self.user?.fullName
            cell.professionLabel.text = self.user?.profession
            cell.locationLabel.text = self.user?.location
            cell.postsButton.setTitle(self.postsCount.numberToString(), forState: UIControlState.Normal)
            if self.isCurrentUser {
                cell.setEditButton()
                cell.followButton.addTarget(self, action: #selector(ProfileTableViewController.editButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                if self.isFollowing {
                    cell.setFollowingButton()
                } else {
                    cell.setFollowButton()
                }
                cell.followButton.addTarget(self, action: #selector(ProfileTableViewController.followButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellAbout", forIndexPath: indexPath) as! ProfileAboutTableViewCell
            cell.aboutLabel.text = self.user?.about
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader", forIndexPath: indexPath) as! ProfileHeaderTableViewCell
            cell.headerLabel.text = "Work Experience"
            cell.experienceImageView.image = UIImage(named: "ic_work_blue")
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader", forIndexPath: indexPath) as! ProfileHeaderTableViewCell
            cell.headerLabel.text = "Education"
            cell.experienceImageView.image = UIImage(named: "ic_education_blue")
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellTopCategory", forIndexPath: indexPath) as! TopCategoryTableViewCell
            cell.categoryNameLabel.text = self.topCategories[indexPath.row]
            let numberOfPosts = self.topCategoriesNumberOfPosts[indexPath.row]
            let numberOfPostsText = numberOfPosts > 1 ? "\(numberOfPosts.numberToString()) posts" : "\(numberOfPosts.numberToString()) post"
            cell.numberOfPostsLabel.text = numberOfPostsText
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 5:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeaderPosts", forIndexPath: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPost", forIndexPath: indexPath) as! PostSmallTableViewCell
            let post = posts[indexPath.row]
            cell.postImageView.image = post.image
            cell.titleLabel.text = post.title
            cell.categoryLabel.text = post.category
            cell.timeLabel.text = post.creationDateString
            
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is PostSmallTableViewCell {
            self.performSegueWithIdentifier("segueToPostVc", sender: indexPath)
        }
        if indexPath.section == 2 || indexPath.section == 3 {
            self.performSegueWithIdentifier("segueToExperienceVc", sender: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        if indexPath.section == 4 {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 7 {
            return 133.0
        } else {
            return 120.0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 7 {
            return 133.0
        } else {
            return UITableViewAutomaticDimension
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
    
    @IBAction func followersButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("segueToUsersVc", sender: self)
    }
    
    
    // MARK: Tappers
    
    func editButtonTapped(sender: UIButton) {
        self.performSegueWithIdentifier("segueToEditProfileVc", sender: self)
    }
    
    func followButtonTapped(sender: UIButton) {
        self.isFollowing ? self.unfollowUser() : self.followUser()
    }
    
    // MARK: AWS
    
    private func getCurrentUser() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().getCurrentUser({
            (task: AWSTask) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let error = task.error {
                print("getCurrentUser error: \(error.localizedDescription)")
            } else if let awsUser = task.result as? AWSUser {
                let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, profession: awsUser._profession, profilePicUrl: awsUser._profilePicUrl, location: awsUser._location, about: awsUser._about)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.user = user
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.None)
                    self.navigationItem.title = self.user?.preferredUsername
                })
                
                // Get profilePic.
                if let profilePicUrl = awsUser._profilePicUrl {
                    self.downloadImage(profilePicUrl, indexPath: nil, isProfilePic: true)
                }
                
                // Query user posts.
                if let userId = awsUser._userId {
                    self.queryUserPostsDateSorted(userId)
                }
            } else {
                print("This should not happen with getCurrentUser!")
            }
            return nil
        })
    }
    
    private func queryUserPostsDateSorted(userId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().queryUserPostsDateSorted(userId, completionHandler: {
            (task: AWSTask) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let error = task.error {
                print("queryUserPostsDateSorted error: \(error.localizedDescription)")
            } else {
                if let output = task.result as? AWSDynamoDBPaginatedOutput,
                    let awsPosts = output.items as? [AWSPost] {
                    
                    // Update posts count.
                    dispatch_async(dispatch_get_main_queue(), {
                        self.postsCount = awsPosts.count
                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                    })
                    
                    // Update top categories.
                    self.updateTopCategories(awsPosts.flatMap({$0._category}))
                    
                    // Iterate through all posts. This should change and fetch only certain or?
                    for (index, awsPost) in awsPosts.enumerate() {
                        let indexPath = NSIndexPath(forRow: index, inSection: 6)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            // Data is denormalized so we store user data in posts table!
                            let user = self.user
                            let post = Post(postId: awsPost._postId, title: awsPost._title, postDescription: awsPost._description, imageUrl: awsPost._imageUrl, category: awsPost._category, creationDate: awsPost._creationDate, user: user)
                            self.posts.append(post)
                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                        })
                        
                        // Get postPic.
                        if let imageUrl = awsPost._imageUrl {
                            self.downloadImage(imageUrl, indexPath: indexPath, isProfilePic: false)
                        }
                    }
                }
            }
            return nil
        })
    }
    
    private func downloadImage(imageKey: String, indexPath: NSIndexPath?, isProfilePic: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").contentWithKey(imageKey)
        // TODO check if content.isImage()
        var image: UIImage?
        if content.cached {
            print("Content cached:")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            image = UIImage(data: content.cachedData)
            self.updateUIWithImage(image, indexPath: indexPath, isProfilePic: isProfilePic)
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
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    if let error = error {
                        print("Download content error: \(error.localizedDescription)")
                    } else if let imageData = data {
                        image = UIImage(data: imageData)
                        self.updateUIWithImage(image, indexPath: indexPath, isProfilePic: isProfilePic)
                    } else {
                        print("This should not happen with download content!")
                    }
            })
        }
    }
    
    // Check if currentUser is following this user.
    private func getUserRelationship() {
        guard let followedId = self.user?.userId else {
            return
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().getUserRelationship(followedId, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("Error: \(error.userInfo["message"])")
                } else {
                    if task.result != nil {
                        self.isFollowing = true
                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                    }
                }
            })
            return nil
        })
    }
    
    private func followUser() {
        guard let followedId = self.user?.userId else {
            return
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().saveUserRelationship(followedId, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("Error: \(error.userInfo["message"])")
                } else {
                    self.isFollowing = true
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                }
            })
            return nil
        })
    }
    
    private func unfollowUser() {
        guard let followedId = self.user?.userId else {
            return
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().removeUserRelationship(followedId, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("Error: \(error.userInfo["message"])")
                } else {
                    self.isFollowing = false
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
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
    
    // MARK: Helpers
    
    private func updateUIWithImage(image: UIImage?, indexPath: NSIndexPath?, isProfilePic: Bool) {
        if let indexPath = indexPath {
            if isProfilePic {
                dispatch_async(dispatch_get_main_queue(), {
                    self.posts[indexPath.row].user?.profilePic = image
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.posts[indexPath.row].image = image
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                })
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.user?.profilePic = image
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
            })
        }
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
        
        dispatch_async(dispatch_get_main_queue(), {
            // Set only top 5 categories.
            self.topCategories = Array(sortedCategories.prefix(5))
            self.topCategoriesNumberOfPosts = Array(sortedCategoriesNumbers.prefix(5))
            self.tableView.reloadSections(NSIndexSet(index: 4), withRowAnimation: UITableViewRowAnimation.None)
        })
    }
}

extension ProfileTableViewController: EditProfileDelegate {
    
    func userUpdated(user: User?) {
        self.configureUser(user)
    }
}
