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
    
    // For now it's currentUser from DynamoDB.
    var user: User?
    var posts: [Post] = []
    var isCurrentUser: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.navigationItem.title = nil
        self.tableView.delaysContentTouches = false
        self.tableView.estimatedRowHeight = 120.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.settingsButton.image = UIImage(named: "ic_settings")
        
        if self.isCurrentUser {
            self.getCurrentUser()
            //self.getCurrentUserPosts()
        } else {
            // TEST
            self.navigationItem.title = self.user?.preferredUsername
            // MOCK
            let category1 = Category(categoryName: "Melon Production", numberOfUsers: 2, numberOfPosts: 12)
            let category2 = Category(categoryName: "Fruit Growing", numberOfUsers: 2, numberOfPosts: 12)
            let category3 = Category(categoryName: "Agriculture", numberOfUsers: 3, numberOfPosts: 28)
            let category4 = Category(categoryName: "Apple Production", numberOfUsers: 2, numberOfPosts: 12)
            let category5 = Category(categoryName: "Fruit agriculture", numberOfUsers: 1, numberOfPosts: 5)
            
            let post1 = Post(user: self.user, postDescription: nil, imageUrl: nil, title: "Melon harvest - peak of the season", image: UIImage(named: "post_pic_ivan"), categories: [category1, category2, category3])
            let post2 = Post(user: self.user, postDescription: nil, imageUrl: nil, title: "Garden view on our products", image: UIImage(named: "post_pic_ivan_2"), categories: [category2, category3])
            let post3 = Post(user: self.user, postDescription: nil, imageUrl: nil, title: "Granny Smith apple", image: UIImage(named: "post_pic_ivan_3"), categories: [category4])
            let post4 = Post(user: self.user, postDescription: nil, imageUrl: nil, title: "Our hothouses in the afternoon", image: UIImage(named: "post_pic_ivan_4"), categories: [category5])
            self.posts = [post1, post2, post3, post4]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureUser(user: User?) {
        self.user = user
        self.tableView.reloadData()
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
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return 1
        case 5:
            return 1
        default:
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
            cell.postsButton.setTitle(self.posts.count.numberToString(), forState: UIControlState.Normal)
            if self.isCurrentUser {
                cell.setEditButton()
                cell.followButton.addTarget(self, action: #selector(ProfileTableViewController.editButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                cell.setFollowButton()
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellAbout", forIndexPath: indexPath) as! ProfileAboutTableViewCell
            cell.aboutLabel.text = self.user?.about
//            cell.aboutLabel.text = "I’ve been working in the fruit industry for more than a decade.  Used many technologies in apple and melon production as well as in seed growing. I’m looking for new opportunities and connections."
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
            let cell = tableView.dequeueReusableCellWithIdentifier("cellTest", forIndexPath: indexPath)
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
            cell.categoriesLabel.text = post.categories?.flatMap({ $0.categoryName }).joinWithSeparator(" · ")
            cell.timeLabel.text = "2 minutes ago"
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
    
//    func profilePicImageViewTapped(sender: UITapGestureRecognizer) {
//        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//        let removePhotoAction = UIAlertAction(title: "Remove current photo", style: UIAlertActionStyle.Destructive, handler: {
//            (alert: UIAlertAction) in
//        })
//        alertController.addAction(removePhotoAction)
//        let takePhotoAction = UIAlertAction(title: "Update photo", style: UIAlertActionStyle.Default, handler: {
//            (alert: UIAlertAction) in
//            self.performSegueWithIdentifier("segueToCaptureProfilePicVc", sender: self)
//        })
//        alertController.addAction(takePhotoAction)
//        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
//        alertController.addAction(cancelAction)
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }
    
    // MARK: AWS
    
    private func getCurrentUser() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().getCurrentUser({
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else if let awsUser = task.result as? AWSUser {
                    let user = User(firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, profession: awsUser._profession, profilePicUrl: awsUser._profilePicUrl, location: awsUser._location, about: awsUser._about)
                    if let profilePicUrl = awsUser._profilePicUrl {
                        self.getProfilePic(profilePicUrl)
                    }
                    self.configureUser(user)
                } else {
                    print("This should not happen getCurrentUser!")
                }
            })
            return nil
        })
    }
    
    private func getProfilePic(imageKey: String) {
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
                            self.user?.profilePic = image
                            self.tableView.reloadData()
                        }
                    }
                })
                return nil
        })
    }
    
    private func getCurrentUserPosts() {
        AWSClientManager.defaultClientManager().getCurrentUserPosts({
            (task: AWSTask) in
            if let error = task.error {
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            } else {
                let output = task.result as? AWSDynamoDBPaginatedOutput
                if let awsPosts = output?.items as? [AWSPost] {
                    for (index, awsPost) in awsPosts.enumerate() {
                        let post = Post(postDescription: awsPost._description, imageUrl: awsPost._imageUrl, title: awsPost._title)
                        self.posts.insert(post, atIndex: index)
                        self.getPostImage(index, imageUrl: awsPost._imageUrl)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.beginUpdates()
                        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.None)
                        self.tableView.endUpdates()
                    })
                }
            }
            return nil
        })
    }
    
    // In background
    private func getPostImage(index: Int, imageUrl: String?) {
        guard let imageUrl = imageUrl else {
            return
        }
        AWSClientManager.defaultClientManager().downloadImage(
            imageUrl,
            completionHandler: {
                (task: AWSTask) in
                if let error = task.error {
                    print("Error: \(error)")
                } else {
                    if let imageData = task.result as? NSData {
                        let image = UIImage(data: imageData)
                        let indexPath = NSIndexPath(forRow: index, inSection: 1)
                        self.posts[index].image = image
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.beginUpdates()
                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                            self.tableView.endUpdates()
                        })
                    }
                }
                return nil
        })
    }
    
    // MARK: AWS
    
    private func signOut() {
        AWSClientManager.defaultClientManager().signOut({
            (task: AWSTask) in
            if let error = task.error {
                print(error)
            }
            return nil
        })
    }
}

extension ProfileTableViewController: EditProfileDelegate {
    
    func userUpdated(user: User?) {
        self.configureUser(user)
    }
}
