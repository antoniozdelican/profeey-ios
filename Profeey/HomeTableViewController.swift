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
    case PostPic
}

protocol FeaturedCategoriesDelegate {
    func reloadData()
}

class HomeTableViewController: UITableViewController {
    
    private var user: User?
    private var posts: [Post] = []
    
    //private var followingUsers: [User] = []
    
    private var featuredCategories: [FeaturedCategory] = []
    private var fakeFeaturedCategories: [FeaturedCategory] = []
    private var featuredCategoriesDelegate: FeaturedCategoriesDelegate?
    
    //private var isLoadingFollowing: Bool = true
    private var isLoadingFeaturedCategories: Bool = true
    private var isUploading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        // Get currentUser and featured categories.
        if let currentUser = AWSClientManager.defaultClientManager().userPool?.currentUser() where currentUser.signedIn {
            self.getCurrentUser()
            self.scanFeaturedCategories()
        }
        
        // Placeholders for featuredCategories before they load.
        for _ in 0...5 {
            self.fakeFeaturedCategories.append(FeaturedCategory(categoryName: nil, featuredImageUrl: nil, numberOfPosts: nil))
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
        if let destinationViewController = segue.destinationViewController as? PostDetailsTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.post = self.posts[indexPath.section]
        }
        if let destinationViewController = segue.destinationViewController as? CategoryTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.categoryName = self.featuredCategories[indexPath.row].categoryName
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        if self.isUploading {
//            return 1 + self.posts.count
//        } else {
//            return self.posts.count
//        }
        return self.posts.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && self.isUploading {
            return 2
        } else {
            return 6
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 && self.isUploading {
            let user = self.user
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellPostUser", forIndexPath: indexPath) as! PostUserTableViewCell
                cell.profilePicImageView.image = user?.profilePic
                cell.fullNameLabel.text = user?.fullName
                cell.professionNameLabel.text = user?.professionName
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellUploading", forIndexPath: indexPath) as! UploadingTableViewCell
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
            //cell.likeButton.text = post.categoryName
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
    
    // MARK: IBActions
    
    @IBAction func unwindToHomeTableViewController(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.sourceViewController as? EditPostTableViewController {
            guard let imageData = sourceViewController.imageData else {
                return
            }
            self.isUploading = true
            self.posts.insert(Post(), atIndex: 0)
            self.tableView.reloadData()
            //self.uploadImage(imageData, title: sourceViewController.postTitle, description: sourceViewController.postDescription, categoryName: sourceViewController.categoryName)
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
                        let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationName: awsUser._locationName, about: awsUser._about)
                        self.user = user
                        
                        if let profilePicUrl = awsUser._profilePicUrl {
                            self.downloadImage(profilePicUrl, imageType: .CurrentUserProfilePic, indexPath: nil)
                        }
                        if let userId = awsUser._userId {
                            self.queryUserActivitiesDateSorted(userId)
                        }
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
                } else {
                    if let awsActivities = response?.items as? [AWSActivity] {
                        for (index, awsActivity) in awsActivities.enumerate() {
                            let user = User(userId: awsActivity._postUserId, firstName: awsActivity._firstName, lastName: awsActivity._lastName, preferredUsername: awsActivity._preferredUsername, professionName: awsActivity._professionName, profilePicUrl: awsActivity._profilePicUrl)
                            let post = Post(userId: awsActivity._postUserId, postId: awsActivity._postId, categoryName: awsActivity._categoryName, creationDate: awsActivity._creationDate, postDescription: awsActivity._description, imageUrl: awsActivity._imageUrl, numberOfLikes: awsActivity._numberOfLikes, title: awsActivity._title, user: user)
                            self.posts.append(post)
                            self.tableView.reloadData()
                            
                            if let profilePicUrl = awsActivity._profilePicUrl {
                                let indexPath = NSIndexPath(forRow: 0, inSection: index)
                                self.downloadImage(profilePicUrl, imageType: .UserProfilePic, indexPath: indexPath)
                            }
                            if let imageUrl = awsActivity._imageUrl {
                                let indexPath = NSIndexPath(forRow: 1, inSection: index)
                                self.downloadImage(imageUrl, imageType: .PostPic, indexPath: indexPath)
                            }
                        }
                    }
                }
            })
        })
    }
    
    private func scanFeaturedCategories() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanFeaturedCategoriesDynamoDB({
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
                            //self.isLoadingFeaturedCategories = false
                            self.featuredCategoriesDelegate?.reloadData()
                            
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
                    self.posts[indexPath.section].user?.profilePic = image
                    self.tableView.reloadData()
                }
            case .PostPic:
                if let indexPath = indexPath {
                    self.posts[indexPath.section].image = image
                    self.tableView.reloadData()
                }
            case .FeaturedCategoryImage:
                if let indexPath = indexPath {
                    self.featuredCategories[indexPath.row].featuredImage = image
                    self.featuredCategoriesDelegate?.reloadData()
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
                                case .FeaturedCategoryImage:
                                    if let indexPath = indexPath {
                                        self.featuredCategories[indexPath.row].featuredImage = image
                                        self.featuredCategoriesDelegate?.reloadData()
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
        //self.isUploading = true
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
                        //self.isUploading = false
                        self.tableView.reloadData()
                        let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        // Save post in DynamoDB.
                        print("uploadImageS3 success")
//                        self.savePost(imageData, imageUrl: imageKey, title: title, description: description, categoryName: categoryName)
                    }
                })
        })
    }
}

extension HomeTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.isLoadingFeaturedCategories ? self.fakeFeaturedCategories.count : self.featuredCategories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellHomeCategory", forIndexPath: indexPath) as! HomeCategoryCollectionViewCell
        let featuredCategory = self.isLoadingFeaturedCategories ? self.fakeFeaturedCategories[indexPath.row] : self.featuredCategories[indexPath.row]
        cell.categoryNameLabel.text = featuredCategory.categoryName
        cell.numberOfPostsLabel.text = featuredCategory.numberOfPostsString
        cell.categoryImageView.image = featuredCategory.featuredImage
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if !self.isLoadingFeaturedCategories {
            self.performSegueWithIdentifier("segueToCategoryVc", sender: indexPath)
        }
    }
}
