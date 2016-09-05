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

class HomeTableViewController: UITableViewController {
    
    private var user: User?
    private var followingUsers: [User] = []
    private var popularCategories: [Category] = []
    private var isLoadingFollowing: Bool = true
    //private var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        // Get currentUser in background immediately for later use.
        if let currentUser = AWSClientManager.defaultClientManager().userPool?.currentUser() where currentUser.signedIn {
            self.getCurrentUser()
        }
        
        // MOCK
        let category1 = Category(categoryName: "Melon Production", numberOfUsers: 2, numberOfPosts: 12, featuredImage: UIImage(named: "post_pic_ivan"))
        let category2 = Category(categoryName: "Yachting", numberOfUsers: 2, numberOfPosts: 12, featuredImage: UIImage(named: "post_pic_filip"))
        let category3 = Category(categoryName: "Agriculture", numberOfUsers: 2, numberOfPosts: 12, featuredImage: UIImage(named: "post_pic_ivan_2"))
        self.popularCategories = [category1, category2, category3]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? ProfileTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.user = self.followingUsers[indexPath.row]
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // PopularSkills Header.
            return 1
        case 1:
            // PopularSkills Header.
            return 1
        case 2:
            // Following Header.
            return 1
        case 3:
            // Following Header.
            if self.isLoadingFollowing {
                return 1
            } else if self.followingUsers.count == 0 {
                return 1
            } else {
                return self.followingUsers.count
            }
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHomeHeader", forIndexPath: indexPath) as! HomeHeaderTableViewCell
            cell.headerTitleLabel.text = "POPULAR SKILLS"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHomeCategories", forIndexPath: indexPath) as! HomeCategoriesTableViewCell
            cell.categoriesCollectionView.dataSource = self
            cell.categoriesCollectionView.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHomeHeader", forIndexPath: indexPath) as! HomeHeaderTableViewCell
            cell.headerTitleLabel.text = "FOLLOWING"
            return cell
        case 3:
            if self.isLoadingFollowing {
                let cell = tableView.dequeueReusableCellWithIdentifier("cellHomeLoading", forIndexPath: indexPath) as! HomeLoadingTableViewCell
                cell.activityIndicator.startAnimating()
                return cell
            } else if self.followingUsers.count == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("cellNotFollowing", forIndexPath: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("cellHomeUser", forIndexPath: indexPath) as! HomeUserTableViewCell
                let user = self.followingUsers[indexPath.row]
                cell.profilePicImageView.image = user.profilePic
                cell.fullNameLabel.text = user.fullName
                cell.professionLabel.text = user.profession
                if let numberOfNewPosts = user.numberOfNewPosts {
                    cell.numberOfPostsLabel.text = numberOfNewPosts.intValue == 1 ? "\(numberOfNewPosts) new post" : "\(numberOfNewPosts) new posts"
                    if numberOfNewPosts.intValue > 0 {
                        cell.numberOfPostsLabel.textColor = Colors.green
                    }
                }
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is HomeUserTableViewCell {
           self.performSegueWithIdentifier("segueToProfileVc", sender: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        switch indexPath.section {
        case 0:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 2:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 3:
            if self.isLoadingFollowing {
                cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            } else if self.followingUsers.count == 0 {
                cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
        default:
            return
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 40.0
        case 1:
            return 163.0
        case 2:
            return 40.0
        case 3:
            if self.isLoadingFollowing {
                return 120.0
            } else if self.followingUsers.count == 0 {
                return 120.0
            } else {
                return 85.0
            }
        default:
            return 0.0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 40.0
        case 1:
            return 163.0
        case 2:
            return 40.0
        case 3:
            if self.isLoadingFollowing {
                return 120.0
            } else if self.followingUsers.count == 0 {
                return 120.0
            } else {
                return UITableViewAutomaticDimension
            }
        default:
            return 0.0
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
                    if let awsUser = task.result as? AWSUser {
                        let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, profession: awsUser._profession, profilePicUrl: awsUser._profilePicUrl, location: awsUser._location, about: awsUser._about)
                        self.user = user
                        
                        // Get profilePic.
                        if let profilePicUrl = awsUser._profilePicUrl {
                            self.downloadImage(profilePicUrl, indexPath: nil, isCurrentUserProfilePic: true)
                        }
                        
                        // Query user following.
                        if let userId = awsUser._userId {
                            self.queryUserFollowing(userId)
                        }
                    }
                }
            })
            return nil
        })
    }
    
    private func queryUserFollowing(userId: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserFollowingDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("queryUserFollowing error: \(error)")
                } else {
                    if let awsUserRelationships = response?.items as? [AWSUserRelationship] {
                        
                        self.isLoadingFollowing = false
                        self.tableView.reloadData()
                        
                        for (index, awsUserRelationship) in awsUserRelationships.enumerate() {
                            
                            let followingUser = User(userId: awsUserRelationship._followingId, firstName: awsUserRelationship._followingFirstName, lastName: awsUserRelationship._followingLastName, preferredUsername: awsUserRelationship._followingPreferredUsername, profession: awsUserRelationship._followingProfession, profilePicUrl: awsUserRelationship._followingProfilePicUrl, numberOfNewPosts: awsUserRelationship._numberOfNewPosts)
                            self.followingUsers.append(followingUser)
                            self.tableView.reloadData()
                            
                            // Get profilePic.
                            if let profilePicUrl = awsUserRelationship._followingProfilePicUrl {
                                let indexpath = NSIndexPath(forRow: index, inSection: 3)
                                self.downloadImage(profilePicUrl, indexPath: indexpath, isCurrentUserProfilePic: false)
                            }
                        }
                    }
                }
            })
        })
    }
    
    private func scanFollowedPosts(followedIds: [String]) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        PRFYDynamoDBManager.defaultDynamoDBManager().scanFollowedPosts(followedIds, completionHandler: {
//            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
//            if let error = error {
//                print("scanFollowedPosts error: \(error)")
//                dispatch_async(dispatch_get_main_queue(), {
//                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                })
//            } else {
//                dispatch_async(dispatch_get_main_queue(), {
//                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                    if let awsPosts = response?.items as? [AWSPost] {
//                        for (index, awsPost) in awsPosts.enumerate() {
//                            let user = User(userId: awsPost._userId, firstName: awsPost._userFirstName, lastName: awsPost._userLastName, preferredUsername: nil, profession: awsPost._userProfession, profilePicUrl: awsPost._userProfilePicUrl, location: nil, about: nil)
//                            let post = Post(postId: awsPost._postId, title: awsPost._title, postDescription: awsPost._description, imageUrl: awsPost._imageUrl, category: awsPost._category, creationDate: awsPost._creationDate, user: user)
//                            self.posts.append(post)
//                            self.tableView.reloadData()
//                            
//                            let indexPath = NSIndexPath(forRow: index, inSection: 3)
//                            
//                            // Get profilePic.
//                            if let profilePicUrl = awsPost._userProfilePicUrl {
//                                self.downloadImage(profilePicUrl, indexPath: indexPath, isProfilePic: true)
//                            }
//                            
//                            // Get postPic.
//                            if let imageUrl = awsPost._imageUrl {
//                                self.downloadImage(imageUrl, indexPath: indexPath, isProfilePic: false)
//                            }
//                        }
//                    }
//                })
//            }
//        })
    }
    
    private func queryUserPostsDateSorted(userId: String) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        AWSClientManager.defaultClientManager().queryUserPostsDateSorted(userId, completionHandler: {
//            (task: AWSTask) in
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//            if let error = task.error {
//                print("Error: \(error.userInfo["message"])")
//            } else {
//                if let output = task.result as? AWSDynamoDBPaginatedOutput,
//                    let awsPosts = output.items as? [AWSPost] {
//                    
//                    // Iterate through all posts. This should change and fetch only certain or?
//                    for (index, awsPost) in awsPosts.enumerate() {
//                        let indexPath = NSIndexPath(forRow: index, inSection: 3)
//
//                        dispatch_async(dispatch_get_main_queue(), {
//                            
//                            // Data is denormalized so we store user data in posts table!
//                            let user = User(userId: awsPost._userId, firstName: awsPost._userFirstName, lastName: awsPost._userLastName, preferredUsername: nil, profession: awsPost._userProfession, profilePicUrl: awsPost._userProfilePicUrl, location: nil, about: nil)
//                            let post = Post(postId: awsPost._postId, title: awsPost._title, postDescription: awsPost._description, imageUrl: awsPost._imageUrl, category: awsPost._category, creationDate: awsPost._creationDate, user: user)
//                            self.posts.append(post)
//                            self.tableView.reloadData()
//                            //self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
//                        })
//                        
//                        // Query likers.
//                        if let postId = awsPost._postId {
//                            self.queryPostLikers(postId, indexPath: indexPath)
//                        }
//                        
//                        // Get profilePic.
//                        if let profilePicUrl = awsPost._userProfilePicUrl {
//                            self.downloadImage(profilePicUrl, indexPath: indexPath, isProfilePic: true)
//                        }
//
//                        // Get postPic.
//                        if let imageUrl = awsPost._imageUrl {
//                            self.downloadImage(imageUrl, indexPath: indexPath, isProfilePic: false)
//                        }
//                    }
//                }
//            }
//            return nil
//        })
    }
    private func queryPostLikers(postId: String, indexPath: NSIndexPath) {
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
//                        self.posts[indexPath.row].numberOfLikes = awsLikes.count
//                        //self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
//                        self.tableView.reloadData()
//                    }
//                }
//            })
//            return nil
//        })
    }
    
    private func downloadImage(imageKey: String, indexPath: NSIndexPath?, isCurrentUserProfilePic: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").contentWithKey(imageKey)
        // TODO check if content.isImage()
        if content.cached {
            print("Content cached:")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            let image = UIImage(data: content.cachedData)
            if isCurrentUserProfilePic {
                self.user?.profilePic = image
            } else if let indexPath = indexPath {
                self.followingUsers[indexPath.row].profilePic = image
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
                                if isCurrentUserProfilePic {
                                    self.user?.profilePic = image
                                } else if let indexPath = indexPath {
                                    self.followingUsers[indexPath.row].profilePic = image
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    })
            })
        }
    }
    
    private func savePost(imageData: NSData, title: String?, description: String?, category: String?) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        
//        // Data is denormalized so we store some user data in posts table.
//        AWSClientManager.defaultClientManager().savePost(imageData, title: title, description: description, category: category, user: self.user, isProfilePic: false, completionHandler: {
//            (task: AWSTask) in
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//            if let error = task.error {
//                dispatch_async(dispatch_get_main_queue(), {
//                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
//                    self.presentViewController(alertController, animated: true, completion: nil)
//                })
//            } else if let awsPost = task.result as? AWSPost {
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    
//                    let post = Post(postId: awsPost._postId, title: awsPost._title, postDescription: awsPost._description, imageUrl: awsPost._imageUrl, category: awsPost._category, creationDate: awsPost._creationDate, user: self.user)
//                    let image = UIImage(data: imageData)
//                    post.image = image
//                    // Inert at the beginning.
//                    self.posts.insert(post, atIndex: 0)
//                    let indexPath = NSIndexPath(forRow: 0, inSection: 3)
//                    //self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
//                    self.tableView.reloadData()
//                })
//            } else {
//                print("This should not happen with savePost!")
//            }
//            return nil
//        })
    }
}

extension HomeTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.popularCategories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellHomeCategory", forIndexPath: indexPath) as! HomeCategoryCollectionViewCell
        let popularCategory = self.popularCategories[indexPath.row]
        cell.categoryImageView.image = popularCategory.featuredImage
        cell.categoryNameLabel.text = popularCategory.categoryName
        if let numberOfPosts = popularCategory.numberOfPosts {
            let numberOfPostsText = numberOfPosts > 1 ? "\(numberOfPosts.numberToString()) posts" : "\(numberOfPosts.numberToString()) post"
            cell.numberOfPostsLabel.text = numberOfPostsText
        }
        return cell
    }
}
