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
    fileprivate var isLoadingPosts: Bool = false
    fileprivate var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = self.userCategory?.categoryName
        
        if let userId = self.userCategory?.userId, let categoryName = self.userCategory?.categoryName {
            self.isLoadingPosts = true
            self.queryUserPostsDateSortedWithCategory(userId, categoryName: categoryName)
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.createPostNotification(_:)), name: NSNotification.Name(CreatePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePostNotification(_:)), name: NSNotification.Name(UpdatePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deletePostNotification(_:)), name: NSNotification.Name(DeletePostNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePostNumberOfLikesNotification(_:)), name: NSNotification.Name(UpdatePostNumberOfLikesNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createCommentNotification(_:)), name: NSNotification.Name(CreateCommentNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteCommentNotification(_:)), name: NSNotification.Name(DeleteCommentNotificationKey), object: nil)
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
        if self.isLoadingPosts || self.posts.count == 0 {
            return 1
        }
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoadingPosts {
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
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingPosts || self.posts.count == 0 {
            return 112.0
        }
        return 112.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingPosts || self.posts.count == 0 {
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
        guard let userId = self.userCategory?.userId, let categoryName = self.userCategory?.categoryName else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.queryUserPostsDateSortedWithCategory(userId, categoryName: categoryName)
    }
    
    // MARK: AWS
    
    fileprivate func queryUserPostsDateSortedWithCategory(_ userId: String, categoryName: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserPostsDateSortedWithCategoryNameDynamoDB(userId, categoryName: categoryName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingPosts = false
                self.refreshControl?.endRefreshing()
                if let error = error {
                    print("queryUserPostsDateSortedWithCategory error: \(error)")
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.none)
                    }
                } else {
                    guard let awsPosts = response?.items as? [AWSPost], awsPosts.count > 0 else {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.none)
                        }
                        return
                    }
                    self.posts = []
                    for awsPost in awsPosts {
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, creationDate: awsPost._creationDate, caption: awsPost._caption, categoryName: awsPost._categoryName, imageUrl: awsPost._imageUrl, imageWidth: awsPost._imageWidth, imageHeight: awsPost._imageHeight, numberOfLikes: awsPost._numberOfLikes, numberOfComments: awsPost._numberOfComments, user: self.user)
                        self.posts.append(post)
                        
                    }
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.none)
                    }
                    for (index, awsPost) in self.posts.enumerated() {
                        if let imageUrl = awsPost.imageUrl {
                            self.downloadImage(imageUrl, imageType: .postPic, indexPath: IndexPath(row: index, section: 0))
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func downloadImage(_ imageKey: String, imageType: ImageType, indexPath: IndexPath) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let content = AWSUserFileManager.defaultUserFileManager().content(withKey: imageKey)
        // TODO check if content.isImage()
        if content.isCached {
            print("Content cached:")
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            switch imageType {
            case .postPic:
                self.posts[indexPath.row].image = image
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
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
                            guard let imageData = data else {
                                return
                            }
                            let image = UIImage(data: imageData)
                            switch imageType {
                            case .postPic:
                                self.posts[indexPath.row].image = image
                                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                            default:
                                return
                            }
                        }
                    })
            })
        }
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
}
