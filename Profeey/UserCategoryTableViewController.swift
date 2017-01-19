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
    
    @IBOutlet var loadingTableFooterView: UIView!
    
    var user: User?
    var userCategory: UserCategory?
    
    fileprivate var posts: [Post] = []
    fileprivate var isLoadingPosts: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    fileprivate var noNetworkConnection: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = self.userCategory?.categoryName
        
        if let userId = self.userCategory?.userId, let categoryName = self.userCategory?.categoryName {
            // Query.
            self.isLoadingPosts = true
            self.tableView.tableFooterView = self.loadingTableFooterView
            self.queryUserPostsDateSortedWithCategory(userId, categoryName: categoryName, startFromBeginning: true)
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.createPostNotification(_:)), name: NSNotification.Name(CreatePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePostNotification(_:)), name: NSNotification.Name(UpdatePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deletePostNotification(_:)), name: NSNotification.Name(DeletePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createLikeNotification(_:)), name: NSNotification.Name(CreateLikeNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteLikeNotification(_:)), name: NSNotification.Name(DeleteLikeNotificationKey), object: nil)
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
        if !self.isLoadingPosts && self.posts.count == 0 {
            return 1
        }
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !self.isLoadingPosts && self.posts.count == 0 {
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
        if !(cell is PostSmallTableViewCell) {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
        // Load next posts and reset tableFooterView.
        guard indexPath.row == self.posts.count - 1 && !self.isLoadingPosts && self.lastEvaluatedKey != nil else {
            return
        }
        guard let userId = self.user?.userId, let categoryName = self.userCategory?.categoryName else {
            return
        }
        guard !self.noNetworkConnection else {
            return
        }
        self.isLoadingPosts = true
        self.tableView.tableFooterView = self.loadingTableFooterView
        self.queryUserPostsDateSortedWithCategory(userId, categoryName: categoryName, startFromBeginning: false)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.posts.count == 0 {
            return 64.0
        }
        return 112.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.posts.count == 0 {
            return 64.0
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
        guard !self.isLoadingPosts else {
            self.refreshControl?.endRefreshing()
            return
        }
        guard let userId = self.userCategory?.userId, let categoryName = self.userCategory?.categoryName else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.isLoadingPosts = true
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
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryUserPostsDateSortedWithCategory error: \(error!)")
                    self.isLoadingPosts = false
                    self.refreshControl?.endRefreshing()
                    self.tableView.tableFooterView = UIView()
                    self.tableView.reloadData()
                    let nsError = error as! NSError
                    if nsError.code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    return
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
                    }
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingPosts = false
                self.refreshControl?.endRefreshing()
                self.noNetworkConnection = false
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                self.tableView.tableFooterView = UIView()
                
                // Reload tableView.
                if startFromBeginning || numberOfNewPosts > 0 {
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
            self.tableView.reloadData()
        } else {
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func updatePostNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        // Update data source and cells.
        let post = self.posts[postIndex]
        post.caption = notification.userInfo?["caption"] as? String
        post.categoryName = notification.userInfo?["categoryName"] as? String
        (self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 0)) as? PostSmallTableViewCell)?.titleLabel.text = post.caption
        (self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 0)) as? PostSmallTableViewCell)?.categoryNameLabel.text = post.categoryName
        
        // Remove if different categoryName.
        if self.userCategory?.categoryName != post.categoryName {
            self.posts.remove(at: postIndex)
            if self.posts.count == 0 {
                self.tableView.reloadData()
            } else {
                self.tableView.deleteRows(at: [IndexPath(row: postIndex, section: 0)], with: UITableViewRowAnimation.automatic)
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
            self.tableView.reloadData()
        } else {
            self.tableView.deleteRows(at: [IndexPath(row: postIndex, section: 0)], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func createLikeNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        // Update data source and cells.
        let post = self.posts[postIndex]
        post.numberOfLikes = NSNumber(value: post.numberOfLikesInt + 1)
        post.isLikedByCurrentUser = true
        (self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 0)) as? PostSmallTableViewCell)?.numberOfLikesLabel.text = post.numberOfLikesSmallString
    }
    
    func deleteLikeNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        // Update data source and cells.
        let post = self.posts[postIndex]
        post.numberOfLikes = NSNumber(value: post.numberOfLikesInt - 1)
        post.isLikedByCurrentUser = false
        (self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 0)) as? PostSmallTableViewCell)?.numberOfLikesLabel.text = post.numberOfLikesSmallString
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
        // Update data source and cells.
        let post = self.posts[postIndex]
        post.image = UIImage(data: imageData)
        (self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 0)) as? PostSmallTableViewCell)?.postImageView.image = post.image
    }
}
