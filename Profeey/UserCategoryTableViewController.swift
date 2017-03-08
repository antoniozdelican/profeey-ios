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
        self.navigationItem.title = self.userCategory?.categoryName?.replacingOccurrences(of: "_", with: " ")
        
        if let userId = self.userCategory?.userId, let categoryName = self.userCategory?.categoryName {
            // Query.
            self.isLoadingPosts = true
            self.tableView.tableFooterView = self.loadingTableFooterView
            self.queryPostsDateSortedWithCategory(userId, categoryName: categoryName, startFromBeginning: true)
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.createReportNotification(_:)), name: NSNotification.Name(CreateReportNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PostDetailsViewController,
            let cell = sender as? PostSmallTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.post = self.posts[indexPath.row].copyPost()
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController =  navigationController.childViewControllers[0] as? ReportTableViewController,
            let cell = sender as? PostSmallTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            childViewController.userId = self.posts[indexPath.row].userId
            childViewController.postId = self.posts[indexPath.row].postId
            childViewController.reportType = ReportType.post
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController =  navigationController.childViewControllers[0] as? EditPostTableViewController,
            let cell = sender as? PostSmallTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            childViewController.editPost = self.posts[indexPath.row].copyEditPost()
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
        // Reported posts.
        if self.posts[indexPath.row].isReportedByCurrentUser {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostReport", for: indexPath) as! PostReportTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostSmall", for: indexPath) as! PostSmallTableViewCell
        let post = self.posts[indexPath.row]
        cell.postImageView.image = post.image
        cell.titleLabel.text = post.caption
        cell.categoryNameLabel.text = post.categoryNameWhitespace
        cell.createdLabel.text = post.createdString
        cell.numberOfLikesLabel.text = post.numberOfLikesSmallString
        cell.postSmallTableViewCellDelegate = self
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
        self.queryPostsDateSortedWithCategory(userId, categoryName: categoryName, startFromBeginning: false)
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
        self.queryPostsDateSortedWithCategory(userId, categoryName: categoryName, startFromBeginning: true)
    }
    
    // MARK: AWS
    
    fileprivate func queryPostsDateSortedWithCategory(_ userId: String, categoryName: String, startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryPostsDateSortedWithCategoryNameDynamoDB(userId, categoryName: categoryName, lastEvaluatedKey: self.lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryPostsDateSortedWithCategory error: \(error!)")
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
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, created: awsPost._created, caption: awsPost._caption, categoryName: awsPost._categoryName, imageUrl: awsPost._imageUrl, imageWidth: awsPost._imageWidth, imageHeight: awsPost._imageHeight, numberOfLikes: awsPost._numberOfLikes, numberOfComments: awsPost._numberOfComments, user: self.user)
                        self.posts.append(post)
                        numberOfNewPosts += 1
                        // Immediately getLike.
                        if let postId = awsPost._postId {
                            self.getLike(postId)
                        }
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
    
    // In background.
    fileprivate func removePost(_ postId: String, imageKey: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removePostDynamoDB(postId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("removePost error: \(error)")
                } else {
                    PRFYS3Manager.defaultS3Manager().removeImageS3(imageKey)
                }
            })
            return nil
        })
    }
    
    fileprivate func getLike(_ postId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getLikeDynamoDB(postId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getLike error: \(error)")
                } else {
                    if task.result != nil, let postIndex = self.posts.index(where: { $0.postId == postId }) {
                        // Update data source and cells.
                        let post = self.posts[postIndex]
                        post.isLikedByCurrentUser = true
                        // Notify observers (PostDetailsVc).
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GetLikeNotificationKey), object: self, userInfo: ["postId": postId])
                    }
                }
            })
            return nil
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
        (self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 0)) as? PostSmallTableViewCell)?.categoryNameLabel.text = post.categoryNameWhitespace
        
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
    
    func createReportNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.isReportedByCurrentUser = true
        self.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: UITableViewRowAnimation.none)
    }
}

extension UserCategoryTableViewController: PostSmallTableViewCellDelegate {
    
    func moreButtonTapped(_ cell: PostSmallTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        let post = self.posts[indexPath.row]
        guard let postId = post.postId, let postUserId = post.userId, let imageKey = post.imageUrl else {
            return
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        // Share.
        let shareAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
            var activityItems:[Any] = []
            if postUserId != AWSIdentityManager.defaultIdentityManager().identityId, let preferredUsername = post.user?.preferredUsername {
                activityItems.append("\(preferredUsername)'s post")
            }
            if let image = post.image {
                activityItems.append(image)
            }
            let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            activityController.popoverPresentationController?.barButtonItem = UIBarButtonItem(title: "Share", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
            self.present(activityController, animated: true, completion: nil)
        })
        alertController.addAction(shareAction)
        
        if postUserId == AWSIdentityManager.defaultIdentityManager().identityId {
            // Edit.
            let editAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction) in
                self.performSegue(withIdentifier: "segueToEditPostVc", sender: cell)
            })
            alertController.addAction(editAction)
            // Delete.
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {
                (alert: UIAlertAction) in
                let alertController = UIAlertController(title: "Delete Post?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                let deleteConfirmAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {
                    (alert: UIAlertAction) in
                    // In background
                    self.removePost(postId, imageKey: imageKey)
                    // Notifiy observers.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: DeletePostNotificationKey), object: self, userInfo: ["postId": postId])
                })
                alertController.addAction(deleteConfirmAction)
                self.present(alertController, animated: true, completion: nil)
            })
            alertController.addAction(deleteAction)
        } else {
            // Report.
            let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive, handler: {
                (alert: UIAlertAction) in
                self.performSegue(withIdentifier: "segueToReportVc", sender: cell)
            })
            alertController.addAction(reportAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
