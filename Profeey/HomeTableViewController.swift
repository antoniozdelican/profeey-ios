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
    
    //TEST
    private var popularCategories: [Category] = []
    
    private var user: User?
    private var posts: [Post] = []
    // Used to track which users have been loaded.
    private var followedUsers: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        // Get currentUser in background immediately for later use.
        self.getCurrentUser()
    
        // MOCK
        let category1 = Category(categoryName: "Melon Production", numberOfUsers: 2, numberOfPosts: 12, featuredImage: UIImage(named: "post_pic_ivan_4"))
        let category2 = Category(categoryName: "Yachting", numberOfUsers: 1, numberOfPosts: 5, featuredImage: UIImage(named: "post_pic_filip"))
        let category3 = Category(categoryName: "Agriculture", numberOfUsers: 3, numberOfPosts: 28, featuredImage: UIImage(named: "post_pic_ivan_2"))
        let category4 = Category(categoryName: "Tobacco industry", numberOfUsers: 1, numberOfPosts: 1, featuredImage: UIImage(named: "post_pic_josip"))
        self.popularCategories = [category1, category2, category3, category4]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? PostDetailsTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.post = self.posts[indexPath.row]
        }
        if let destinationViewController = segue.destinationViewController as? CategoryTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.category = self.popularCategories[indexPath.row]
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            return self.posts.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader", forIndexPath: indexPath) as! HomeHeaderTableViewCell
            cell.headerTitleLabel.text = "Subscribed Skills"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellCategory", forIndexPath: indexPath) as! MyCategoriesTableViewCell
            // Set dataSource and delegate.
            cell.categoriesCollectionView.dataSource = self
            cell.categoriesCollectionView.delegate = self
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader", forIndexPath: indexPath) as! HomeHeaderTableViewCell
            cell.headerTitleLabel.text = "Following"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPost", forIndexPath: indexPath) as! PostTableViewCell
            let post = self.posts[indexPath.row]
            let user = post.user
            cell.profilePicImageView.image = user?.profilePic
            cell.fullNameLabel.text = user?.fullName
            cell.professionLabel.text = user?.profession
            cell.postPicImageView.image = post.image
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
        if cell is PostTableViewCell {
           self.performSegueWithIdentifier("segueToPostDetailsVc", sender: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        if indexPath.section == 0 || indexPath.section == 2 {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 || indexPath.section == 2 {
            return 62.0
        }
        if indexPath.section == 1 {
            return 249.0
        }
        if indexPath.section == 3 {
            return tableView.bounds.width - 8.0
        }
        return 0.0
    }
    
    // MARK: IBActions
    
    @IBAction func unwindToHomeTableViewController(segue: UIStoryboardSegue) {
        if segue.identifier == "segueUnwindToHomeVc",
            let sourceViewController = segue.sourceViewController as? EditPostTableViewController {
            guard let imageData = sourceViewController.imageData else {
                    return
            }
            self.savePost(imageData, title: sourceViewController.postTitle, description: sourceViewController.postDescription, category: sourceViewController.category)
            
        }
    }
    
    // MARK: AWS
    
    // Gets currentUser and credentialsProvider.idenityId
    // 1.
    private func getCurrentUser() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().getCurrentUser({
            (task: AWSTask) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let error = task.error {
                print("Error: \(error.userInfo["message"])")
            } else if let awsUser = task.result as? AWSUser {
                let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, profession: awsUser._profession, profilePicUrl: awsUser._profilePicUrl, location: awsUser._location, about: awsUser._about)
                self.user = user
                
                // Get profilePic.
                if let profilePicUrl = awsUser._profilePicUrl {
                    self.downloadImage(profilePicUrl, indexPath: nil, isProfilePic: true)
                }
                
                // Query followed.
                self.queryUserFollowed(awsUser._userId)
                
            } else {
                print("This should not happen with getCurrentUser!")
            }
        return nil
        })
    }
    
    //2.
    private func queryUserFollowed(userId: String?) {
        guard let userId = userId else {
            print("No userId.")
            return
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().queryUserFollowed(userId, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                print("Error: \(error.userInfo["message"])")
            } else {
                if let output = task.result as? AWSDynamoDBPaginatedOutput,
                    let awsUserRelationships = output.items as? [AWSUserRelationship] {
                    
                    // Query all posts from followed users and own posts.
                    var followedIds = awsUserRelationships.flatMap({$0._followedId})
                    followedIds.append(userId)
                    for userId in followedIds {
                        self.queryUserPostsDateSorted(userId)
                    }
                }
            }
            return nil
        })
    }
    
    //3.
    private func queryUserPostsDateSorted(userId: String?) {
        guard let userId = userId else {
            print("No userId.")
            return
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().queryUserPostsDateSorted(userId, completionHandler: {
            (task: AWSTask) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let error = task.error {
                print("Error: \(error.userInfo["message"])")
            } else {
                if let output = task.result as? AWSDynamoDBPaginatedOutput,
                    let awsPosts = output.items as? [AWSPost] {
                    
                    // Iterate through all posts. This should change and fetch only certain or?
                    for (index, awsPost) in awsPosts.enumerate() {
                        
                        let indexPath = NSIndexPath(forRow: index, inSection: 3)
                        let followedUserIndex = self.followedUsers.indexOf({$0.userId == userId})

                        dispatch_async(dispatch_get_main_queue(), {
                            var user: User
                            if followedUserIndex != nil {
                                // If followed user already exists, don't create a new user object!
                                user = self.followedUsers[followedUserIndex!]
                            } else {
                                // Else create a new object.
                                user = User(userId: awsPost._userId, firstName: awsPost._userFirstName, lastName: awsPost._userLastName, preferredUsername: nil, profession: awsPost._userProfession, profilePicUrl: awsPost._userProfilePicUrl, location: nil, about: nil)
                                self.followedUsers.append(user)
                            }
                            
                            // Data is denormalized so we store user data in posts table!
                            let post = Post(title: awsPost._title, postDescription: awsPost._description, imageUrl: awsPost._imageUrl, category: awsPost._category, creationDate: awsPost._creationDate, user: user)
                            self.posts.append(post)
                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                        })

                        // Get post userProfilePic.
                        // But only if followed user doesn't yet exist!
                        if followedUserIndex == nil {
                            if let profilePicUrl = awsPost._userProfilePicUrl {
                                self.downloadImage(profilePicUrl, indexPath: indexPath, isProfilePic: true)
                            }
                        }

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
    
    //4.a
    private func downloadImage(imageKey: String, indexPath: NSIndexPath?, isProfilePic: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().downloadImage(imageKey, completionHandler: {
            (task: AWSTask) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let error = task.error {
                print("Error: \(error.userInfo["message"])")
            } else {
                if let imageData = task.result as? NSData {
                    
                    if let indexPath = indexPath {
                        if isProfilePic {
                            dispatch_async(dispatch_get_main_queue(), {
                                let image = UIImage(data: imageData)
                                // Update followedUsers profilePic.
                                self.followedUsers[indexPath.row].profilePic = image
                                self.posts[indexPath.row].user?.profilePic = image
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                            })
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                let image = UIImage(data: imageData)
                                self.posts[indexPath.row].image = image
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                            })
                        }
                        
                    } else {
                        // Update only currentUser profilePic.
                        let image = UIImage(data: imageData)
                        self.user?.profilePic = image
                    }
                }
            }
            return nil
        })
    }
    
    private func savePost(imageData: NSData, title: String?, description: String?, category: String?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Data is denormalized so we store some user data in posts table.
        AWSClientManager.defaultClientManager().savePost(imageData, title: title, description: description, category: category, user: self.user, isProfilePic: false, completionHandler: {
            (task: AWSTask) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let error = task.error {
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            } else if let awsPost = task.result as? AWSPost {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let post = Post(title: awsPost._title, postDescription: awsPost._description, imageUrl: awsPost._imageUrl, category: awsPost._category, creationDate: awsPost._creationDate, user: self.user)
                    let image = UIImage(data: imageData)
                    post.image = image
                    // Inert at the beginning.
                    self.posts.insert(post, atIndex: 0)
                    let indexPath = NSIndexPath(forRow: 0, inSection: 3)
                    self.tableView.beginUpdates()
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                    self.tableView.endUpdates()
                })
            } else {
                print("This should not happen with savePost!")
            }
            return nil
        })
    }
}

extension HomeTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.popularCategories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellCategory", forIndexPath: indexPath) as! MyCategoryCollectionViewCell
        let category = self.popularCategories[indexPath.row]
        cell.categoryImageView.image = category.featuredImage
        cell.categoryNameLabel.text = category.categoryName
        if let numberOfPosts = category.numberOfPosts {
            cell.numberOfPostsLabel.text = "\(numberOfPosts.numberToString()) posts"
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueToCategoryVc", sender: indexPath)
    }
}
