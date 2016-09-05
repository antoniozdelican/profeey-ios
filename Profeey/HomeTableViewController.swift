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
    case FeaturedCategoryImage
}

class HomeTableViewController: UITableViewController {
    
    private var user: User?
    private var followingUsers: [User] = []
    private var featuredCategories: [FeaturedCategory] = []
    private var isLoadingFollowing: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        // Get currentUser and featured categories.
        if let currentUser = AWSClientManager.defaultClientManager().userPool?.currentUser() where currentUser.signedIn {
            self.getCurrentUser()
            self.scanFeaturedCategories()
        }
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
            // FeaturedSkills Header.
            return 1
        case 1:
            // FeaturedSkills.
            return 1
        case 2:
            // Following Header.
            return 1
        case 3:
            // Following Users.
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
            cell.headerTitleLabel.text = "FEATURED SKILLS"
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
                    let numberOfNewPostsInt = numberOfNewPosts.integerValue
                    cell.numberOfPostsLabel.text = numberOfNewPostsInt == 1 ? "\(numberOfNewPostsInt) new post" : "\(numberOfNewPostsInt) new posts"
                    if numberOfNewPostsInt > 0 {
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
                            self.downloadImage(profilePicUrl, imageType: .CurrentUserProfilePic, indexPath: nil)
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
                                self.downloadImage(profilePicUrl, imageType: .UserProfilePic, indexPath: indexpath)
                            }
                        }
                    }
                }
            })
        })
    }
    
    private func scanFeaturedCategories() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanFeaturedCategories({
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanFeaturedCategories error: \(error)")
                } else {
                    if let awsFeaturedCategories = response?.items as? [AWSFeaturedCategory] {
                        
                        for (index, awsFeaturedCategory) in awsFeaturedCategories.enumerate() {
                            let featuredCategory = FeaturedCategory(categoryName: awsFeaturedCategory._categoryName, featuredImageUrl: awsFeaturedCategory._featuredImageUrl, numberOfPosts: awsFeaturedCategory._numberOfPosts)
                            self.featuredCategories.append(featuredCategory)
                            self.tableView.reloadData()
                            
                            // Get featuredImage.
                            if let featuredImageUrl = awsFeaturedCategory._featuredImageUrl {
                                let indexpath = NSIndexPath(forRow: index, inSection: 1)
                                self.downloadImage(featuredImageUrl, imageType: .FeaturedCategoryImage, indexPath: indexpath)
                            }
                        }
                    }
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
                    self.followingUsers[indexPath.row].profilePic = image
                    self.tableView.reloadData()
                }
            case .FeaturedCategoryImage:
                if let indexPath = indexPath {
                    self.featuredCategories[indexPath.row].featuredImage = image
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
                                        self.followingUsers[indexPath.row].profilePic = image
                                        self.tableView.reloadData()
                                    }
                                case .FeaturedCategoryImage:
                                    if let indexPath = indexPath {
                                        self.featuredCategories[indexPath.row].featuredImage = image
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    })
            })
        }
    }
}

extension HomeTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.featuredCategories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellHomeCategory", forIndexPath: indexPath) as! HomeCategoryCollectionViewCell
        let featuredCategory = self.featuredCategories[indexPath.row]
        cell.categoryNameLabel.text = featuredCategory.categoryName
        if let numberOfPosts = featuredCategory.numberOfPosts {
            let numberOfPostsInt = numberOfPosts.integerValue
            cell.numberOfPostsLabel.text = numberOfPostsInt > 1 ? "\(numberOfPostsInt.numberToString()) posts" : "\(numberOfPostsInt.numberToString()) post"
        }
        cell.categoryImageView.image = featuredCategory.featuredImage
        return cell
    }
}
