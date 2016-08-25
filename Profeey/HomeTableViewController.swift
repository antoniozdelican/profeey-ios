//
//  HomeTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class HomeTableViewController: UITableViewController {
    
    //TEST
    private var popularCategories: [Category] = []
    
    private var user: User?
    private var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.tableView.estimatedRowHeight = 155.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // TEST
        // Just in case get identityId for later use.
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId()
        // Get currentUser in background immediately for later use.
        self.getCurrentUser()
        
        // MOCK
        let user1 = User(firstName: "Ivan", lastName: "Zdelican", preferredUsername: "ivan", profession: "Fruit Grower", profilePic: UIImage(named: "pic_ivan"))
        let user2 = User(firstName: "Filip", lastName: "Vargovic", preferredUsername: "filja", profession: "Yacht Skipper", profilePic: UIImage(named: "pic_filip"))
        let user3 = User(firstName: "Josip", lastName: "Zdelican", preferredUsername: "jole", profession: "Agricultural Engineer", profilePic: UIImage(named: "pic_josip"))
        
        // MOCK
        let category1 = Category(categoryName: "Melon Production", numberOfUsers: 2, numberOfPosts: 12, featuredImage: UIImage(named: "post_pic_ivan_4"))
        let category2 = Category(categoryName: "Yachting", numberOfUsers: 1, numberOfPosts: 5, featuredImage: UIImage(named: "post_pic_filip"))
        let category3 = Category(categoryName: "Agriculture", numberOfUsers: 3, numberOfPosts: 28, featuredImage: UIImage(named: "post_pic_ivan_2"))
        let category4 = Category(categoryName: "Tobacco industry", numberOfUsers: 1, numberOfPosts: 1, featuredImage: UIImage(named: "post_pic_josip"))
        self.popularCategories = [category1, category2, category3, category4]
        
        let creationDate = NSNumber(double: NSDate().timeIntervalSince1970)
        let post1 = Post(title: "Melon harvest - peak of the season", postDescription: nil, imageUrl: nil, category: "Agriculture", creationDate: creationDate, user: user1)
        post1.image = UIImage(named: "post_pic_ivan")
        let post2 = Post(title: "New boat for this summer's tour", postDescription: nil, imageUrl: nil, category: "Yachting", creationDate: creationDate, user: user2)
        post2.image = UIImage(named: "post_pic_filip")
        let post3 = Post(title: "Desired tobacco color of type Berlej before the final stage of drying", postDescription: nil, imageUrl: nil, category: "Agriculture", creationDate: creationDate, user: user3)
        post3.image = UIImage(named: "post_pic_josip")
        self.posts = [post1, post2, post3]
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
    
    // MARK: IBActions
    
    @IBAction func unwindToHomeTableViewController(segue: UIStoryboardSegue) {
        if segue.identifier == "segueUnwindToHomeVc",
            let sourceViewController = segue.sourceViewController as? EditPostTableViewController {
            guard let imageData = sourceViewController.imageData else {
                    return
            }
            self.createPost(imageData, title: sourceViewController.postTitle, description: sourceViewController.postDescription, category: sourceViewController.category)
            
        }
    }
    
    // MARK: AWS
    
    private func createPost(imageData: NSData, title: String?, description: String?, category: String?) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        AWSClientManager.defaultClientManager().createPost(imageData, title: title, description: description, category: category, isProfilePic: false, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else if let awsPost = task.result as? AWSPost {
                    let post = Post(title: awsPost._title, postDescription: awsPost._description, imageUrl: awsPost._imageUrl, category: awsPost._category, creationDate: awsPost._creationDate, user: self.user)
                    
                    // Inert at the beginning.
                    self.posts.insert(post, atIndex: 0)
                    
                    // Get postPic.
                    let image = UIImage(data: imageData)
                    post.image = image
                    
                    self.tableView.reloadData()
                } else {
                    print("This should not happen createPost!")
                }
                
            })
            return nil
        })
    }
    
    private func getCurrentUser() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().getCurrentUser({
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    print("Error: \(error.userInfo["message"])")
                } else if let awsUser = task.result as? AWSUser {
                    let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, profession: awsUser._profession, profilePicUrl: awsUser._profilePicUrl, location: awsUser._location, about: awsUser._about)
                    
                    // Set current user.
                    self.user = user
                    
                    // Get profilePic.
                    if let profilePicUrl = awsUser._profilePicUrl {
                        self.downloadImage(profilePicUrl, postIndex: nil)
                    }
                } else {
                    print("This should not happen getCurrentUser!")
                }
            })
            return nil
        })
    }
    
    private func downloadImage(imageKey: String, postIndex: Int?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().downloadImage(
            imageKey,
            completionHandler: {
                (task: AWSTask) in
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    if let error = task.error {
                        print("Error: \(error.userInfo["message"])")
                    } else {
                        if let imageData = task.result as? NSData {
                            let image = UIImage(data: imageData)
                            if let index = postIndex {
                                // It's postPic.
                                self.posts[index].image = image
                                self.tableView.reloadData()
                            } else {
                                // It's profilePic.
                                self.user?.profilePic = image
                            }
                        }
                    }
                })
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
