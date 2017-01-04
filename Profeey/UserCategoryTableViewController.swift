//
//  UserCategoryTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class UserCategoryTableViewController: UITableViewController {
    
    var user: User?
    var userCategory: UserCategory?
    
    fileprivate var posts: [Post] = []
    fileprivate var isLoadingInitialPosts: Bool = false
    fileprivate var isLoadingNextPosts: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    //fileprivate var isRefreshingPosts: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = self.userCategory?.categoryName
        
        if let userId = self.userCategory?.userId, let categoryName = self.userCategory?.categoryName {
            self.isLoadingInitialPosts = true
            self.queryUserPostsDateSortedWithCategory(userId, categoryName: categoryName, startFromBeginning: true)
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.createPostNotification(_:)), name: NSNotification.Name(CreatePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePostNotification(_:)), name: NSNotification.Name(UpdatePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deletePostNotification(_:)), name: NSNotification.Name(DeletePostNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePostNumberOfLikesNotification(_:)), name: NSNotification.Name(UpdatePostNumberOfLikesNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createCommentNotification(_:)), name: NSNotification.Name(CreateCommentNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteCommentNotification(_:)), name: NSNotification.Name(DeleteCommentNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PostDetailsTableViewController,
            let cell = sender as? PostSmallTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.post = self.posts[indexPath.row].copyPost()
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingInitialPosts || self.posts.count == 0 {
            return 1
        }
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoadingInitialPosts {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellLoading", for: indexPath) as! LoadingTableViewCell
            cell.activityIndicator?.startAnimating()
            return cell
        }
        if self.posts.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
            cell.emptyMessageLabel.text = "No posts yet."
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostSmall", for: indexPath) as! PostSmallTableViewCell
        let post = self.posts[indexPath.row]
        cell.postImageView.image = post.image
        cell.titleLabel.text = post.caption
        cell.categoryNameLabel.text = post.categoryName
        cell.timeLabel.text = post.creationDateString
        cell.numberOfLikesLabel.text = post.numberOfLikesSmallString
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is PostSmallTableViewCell {
            self.performSegue(withIdentifier: "segueToPostDetailsVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        // Load next posts.
        guard !self.isLoadingInitialPosts else {
            return
        }
        guard indexPath.row == self.posts.count - 1 && !self.isLoadingNextPosts && self.lastEvaluatedKey != nil else {
            return
        }
        guard let userId = self.user?.userId, let categoryName = self.userCategory?.categoryName else {
            return
        }
        self.isLoadingNextPosts = true
        self.queryUserPostsDateSortedWithCategory(userId, categoryName: categoryName, startFromBeginning: false)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingInitialPosts || self.posts.count == 0 {
            return 112.0
        }
        return 112.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingInitialPosts || self.posts.count == 0 {
            return 112.0
        }
        return 112.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 6.0
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard !self.isLoadingInitialPosts else {
            self.refreshControl?.endRefreshing()
            return
        }
        guard let userId = self.userCategory?.userId, let categoryName = self.userCategory?.categoryName else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.queryUserPostsDateSortedWithCategory(userId, categoryName: categoryName, startFromBeginning: true)
    }
    
    // MARK: AWS
    
    fileprivate func queryUserPostsDateSortedWithCategory(_ userId: String, categoryName: String, startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserPostsDateSortedWithCategoryNameDynamoDB(userId, categoryName: categoryName, lastEvaluatedKey: self.lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    print("queryUserPostsDateSortedWithCategory error: \(error)")
                }
                if startFromBeginning {
                    self.posts = []
                }
                var numberOfNewPosts = 0
                if let awsPosts = response?.items as? [AWSPost] {
                    for awsPost in awsPosts {
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, creationDate: awsPost._creationDate, caption: awsPost._caption, categoryName: awsPost._categoryName, imageUrl: awsPost._imageUrl, imageWidth: awsPost._imageWidth, imageHeight: awsPost._imageHeight, numberOfLikes: awsPost._numberOfLikes, numberOfComments: awsPost._numberOfComments, user: self.user)
                        self.posts.append(post)
                        numberOfNewPosts += 1
                        // Immediately getLike.
                        // TODO
                    }
                }
                // Reset flags and animations that were initiated.
                if self.isLoadingInitialPosts {
                    self.isLoadingInitialPosts = false
                }
                if self.isLoadingNextPosts {
                    self.isLoadingNextPosts = false
                }
                self.refreshControl?.endRefreshing()
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // Reload tableView with downloaded posts.
                if startFromBeginning {
                    self.tableView.reloadData()
                } else if numberOfNewPosts > 0 {
                    self.tableView.reloadData()
                }
                
                // Load posts images.
                if let awsPosts = response?.items as? [AWSPost] {
                    for awsPost in awsPosts {
                        if let imageUrl = awsPost._imageUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(imageUrl, imageType: .postPic)
                        }
                    }
                }
            })
        })
    }
}

extension UserCategoryTableViewController {
    
    // MARK: NotificationCenterActions
    
    func createPostNotification(_ notification: NSNotification) {
        guard let post = notification.userInfo?["post"] as? Post else {
            return
        }
        guard self.user?.userId == post.userId else {
            return
        }
        guard self.userCategory?.categoryName == post.categoryName else {
            return
        }
        self.posts.insert(post, at: 0)
        if self.posts.count == 1 {
            self.tableView.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.none)
        } else {
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
        }
    }
    
    func updatePostNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.caption = notification.userInfo?["caption"] as? String
        post.categoryName = notification.userInfo?["categoryName"] as? String
        self.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: UITableViewRowAnimation.none)
        // Remove if different categoryName.
        if self.userCategory?.categoryName != post.categoryName {
            self.posts.remove(at: postIndex)
            if self.posts.count == 0 {
                self.tableView.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.none)
            } else {
                self.tableView.deleteRows(at: [IndexPath(row: postIndex, section: 0)], with: UITableViewRowAnimation.none)
            }
        }
    }
    
    func deletePostNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        self.posts.remove(at: postIndex)
        if self.posts.count == 0 {
            self.tableView.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.none)
        } else {
            self.tableView.deleteRows(at: [IndexPath(row: postIndex, section: 0)], with: UITableViewRowAnimation.fade)
        }
    }
    
    func updatePostNumberOfLikesNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String, let numberOfLikes = notification.userInfo?["numberOfLikes"] as? NSNumber else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.numberOfLikes = numberOfLikes
        post.isLikedByCurrentUser = !post.isLikedByCurrentUser
        self.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: UITableViewRowAnimation.none)
    }
    
    func createCommentNotification(_ notification: NSNotification) {
        guard let comment = notification.userInfo?["comment"] as? Comment else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == comment.postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.numberOfComments = NSNumber(value: post.numberOfCommentsInt + 1)
        self.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: UITableViewRowAnimation.none)
    }
    
    func deleteCommentNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String  else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.numberOfComments = NSNumber(value: post.numberOfCommentsInt - 1)
        self.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: UITableViewRowAnimation.none)
    }
    
    func downloadImageNotification(_ notification: NSNotification) {
        guard let imageKey = notification.userInfo?["imageKey"] as? String, let imageType = notification.userInfo?["imageType"] as? ImageType, let imageData = notification.userInfo?["imageData"] as? Data else {
            return
        }
        guard imageType == .postPic else {
            return
        }
        
        guard let postIndex = self.posts.index(where: { $0.imageUrl == imageKey }) else {
            return
        }
        self.posts[postIndex].image = UIImage(data: imageData)
        // Reload if visible.
        guard let indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows, indexPathsForVisibleRows.contains(where: { $0 == IndexPath(row: postIndex, section: 0) }) else {
            return
        }
        UIView.performWithoutAnimation {
            self.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: UITableViewRowAnimation.none)
        }
    }
}
