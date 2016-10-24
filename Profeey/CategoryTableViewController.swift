//
//  CategoryTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class CategoryTableViewController: UITableViewController {

    var categoryName: String?
    fileprivate var posts: [Post] = []
    fileprivate var isLoadingPosts: Bool = true
    fileprivate var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.title = self.categoryName
        
        // Get current user.
        self.getCurrentUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.user = self.posts[(indexPath as NSIndexPath).section].user
        }
        if let destinationViewController = segue.destination as? UsersTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.usersType = UsersType.likers
            destinationViewController.postId = self.posts[(indexPath as NSIndexPath).section].postId
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.isLoadingPosts {
            return 1
        }
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingPosts {
            return 1
        }
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoadingPosts {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellLoading", for: indexPath) as! LoadingTableViewCell
            return cell
        }
        let post = self.posts[(indexPath as NSIndexPath).section]
        let user = post.user
        switch (indexPath as NSIndexPath).row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostUser", for: indexPath) as! PostUserTableViewCell
            cell.profilePicImageView.image = user?.profilePic
            cell.fullNameLabel.text = user?.fullName
            cell.professionNameLabel.text = user?.professionName
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostImage", for: indexPath) as! PostImageTableViewCell
            cell.postImageView.image = post.image
            if let image = post.image {
                let aspectRatio = image.size.width / image.size.height
                cell.postImageViewHeightConstraint.constant = tableView.bounds.width / aspectRatio
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostInfo", for: indexPath) as! PostInfoTableViewCell
            cell.titleLabel.text = post.caption
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostCategory", for: indexPath)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostTime", for: indexPath)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostButtons", for: indexPath) as! PostButtonsTableViewCell
            post.isLikedByCurrentUser ? cell.setSelectedLikeButton() : cell.setUnselectedLikeButton()
//            cell.likeButton.addTarget(self, action: #selector(HomeTableViewController.likeButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            cell.numberOfLikesButton.isHidden = (post.numberOfLikesString != nil) ? false : true
            cell.numberOfLikesButton.setTitle(post.numberOfLikesString, for: UIControlState())
//            cell.numberOfLikesButton.addTarget(self, action: #selector(HomeTableViewController.numberOfLikesButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is PostUserTableViewCell {
            self.performSegue(withIdentifier: "segueToProfileVc", sender: indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        if (indexPath as NSIndexPath).row == 5 {
            cell.separatorInset = UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingPosts {
            return 120.0
        }
        switch (indexPath as NSIndexPath).row {
        case 0:
            return 65.0
        case 1:
            return 300.0
        case 2:
            return 30.0
        case 3:
            return 21.0
        case 4:
            return 21.0
        case 5:
            return 49.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingPosts {
            return 120.0
        }
        switch (indexPath as NSIndexPath).row {
        case 0:
            return 65.0
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return UITableViewAutomaticDimension
        case 3:
            return UITableViewAutomaticDimension
        case 4:
            return 21.0
        case 5:
            return 49.0
        default:
            return 0.0
        }
    }
    
    // MARK: Tappers
    
    func likeButtonTapped(_ sender: AnyObject) {
        let point = sender.convert(CGPoint.zero, to: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: point) else {
            return
        }
        let post = self.posts[(indexPath as NSIndexPath).section]
        guard let postId = post.postId else {
            return
        }
        guard let postUserId = post.userId else {
            return
        }
        let numberOfLikes = (post.numberOfLikes != nil) ? post.numberOfLikes! : 0
        let numberOfLikesInteger = numberOfLikes.intValue
        if post.isLikedByCurrentUser {
            post.isLikedByCurrentUser = false
            post.numberOfLikes = NSNumber(value: (numberOfLikesInteger - 1) as Int)
            self.removeLike(postId, postUserId: postUserId)
        } else {
            post.isLikedByCurrentUser = true
            post.numberOfLikes = NSNumber(value: (numberOfLikesInteger + 1) as Int)
            self.saveLike(postId, postUserId: postUserId)
        }
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
    
    func numberOfLikesButtonTapped(_ sender: AnyObject) {
        let point = sender.convert(CGPoint.zero, to: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: point) else {
            return
        }
        self.performSegue(withIdentifier: "segueToUsersVc", sender: indexPath)
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard let categoryName = self.categoryName else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.posts = []
        self.queryCategoryPostsDateSorted(categoryName)
    }
    
    // MARK: AWS
    
    // Get currentUser data so we can perform actions (like, comment)
    fileprivate func getCurrentUser() {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        PRFYDynamoDBManager.defaultDynamoDBManager().getCurrentUserDynamoDB({
//            (task: AWSTask) in
//            DispatchQueue.main.async(execute: {
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                if let error = task.error {
//                    print("getCurrentUser error: \(error)")
//                } else {
//                    guard let awsUser = task.result as? AWSUser else {
//                        return
//                    }
//                    let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl)
//                    self.currentUser = user
//                    
//                    if let categoryName = self.categoryName {
//                        self.queryCategoryPostsDateSorted(categoryName)
//                    }
//                }
//            })
//            return nil
//        })
    }
    
    fileprivate func queryCategoryPostsDateSorted(_ categoryName: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryCategoryPostsDateSortedDynamoDB(categoryName, completionHandler: {
            (reponse: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("queryCategoryPostsDateSorted error: \(error)")
                    self.isLoadingPosts = false
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                } else {
                    guard let awsPosts = reponse?.items as? [AWSPost] else {
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
                    for (index, awsPost) in awsPosts.enumerated() {
                        let user = User(userId: awsPost._userId, firstName: awsPost._firstName, lastName: awsPost._lastName, preferredUsername: awsPost._preferredUsername, professionName: awsPost._professionName, profilePicUrl: awsPost._profilePicUrl)
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, caption: awsPost._caption, categoryName: awsPost._categoryName, creationDate: awsPost._creationDate, imageUrl: awsPost._imageUrl, numberOfLikes: awsPost._numberOfLikes, user: user)
                        self.posts.append(post)
                        self.isLoadingPosts = false
                        self.tableView.reloadData()
                        
                        if let profilePicUrl = awsPost._profilePicUrl {
                            let indexPath = IndexPath(row: 0, section: index)
                            self.downloadImage(profilePicUrl, imageType: .userProfilePic, indexPath: indexPath)
                        }
                        if let imageUrl = awsPost._imageUrl {
                            let indexPath = IndexPath(row: 1, section: index)
                            self.downloadImage(imageUrl, imageType: .postPic, indexPath: indexPath)
                        }
                        if let postId = awsPost._postId {
                            let indexPath = IndexPath(row: 5, section: index)
                            self.getLike(postId, indexPath: indexPath)
                        }
                    }
                    self.refreshControl?.endRefreshing()
                }
            })
        })
    }
    
    fileprivate func downloadImage(_ imageKey: String, imageType: ImageType, indexPath: IndexPath) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").content(withKey: imageKey)
        // TODO check if content.isImage()
        if content.isCached {
            print("Content cached:")
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            switch imageType {
            case .userProfilePic:
                self.posts[indexPath.section].user?.profilePic = image
                self.tableView.reloadData()
            case .postPic:
                self.posts[indexPath.section].image = image
                self.tableView.reloadData()
            default:
                return
            }
        } else {
            print("Download content:")
            content.download(
                with: AWSContentDownloadType.ifNewerExists,
                pinOnCompletion: false,
                progressBlock: {
                    (content: AWSContent?, progress: Progress?) -> Void in
                    // TODO
                },
                completionHandler: {
                    (content: AWSContent?, data: Data?, error: Error?) in
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if let error = error {
                            print("downloadImage error: \(error)")
                        } else {
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                switch imageType {
                                case .userProfilePic:
                                    self.posts[indexPath.section].user?.profilePic = image
                                    self.tableView.reloadData()
                                case .postPic:
                                    self.posts[indexPath.section].image = image
                                    self.tableView.reloadData()
                                default:
                                    return
                                }
                            }
                        }
                    })
            })
        }
    }
    
    // Check if currentUser liked a post.
    fileprivate func getLike(_ postId: String, indexPath: IndexPath) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getLikeDynamoDB(postId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getLike error: \(error)")
                } else {
                    if task.result != nil {
                        self.posts[(indexPath as NSIndexPath).section].isLikedByCurrentUser = true
                        self.tableView.reloadData()
                    }
                }
            })
            return nil
        })
    }
    
    fileprivate func saveLike(_ postId: String, postUserId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveLikeDynamoDB(postId, postUserId: postUserId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("saveLike error: \(error)")
                }
            })
            return nil
        })
    }
    
    fileprivate func removeLike(_ postId: String, postUserId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeLikeDynamoDB(postId, postUserId: postUserId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("removeLike error: \(error)")
                }
            })
            return nil
        })
    }
}
