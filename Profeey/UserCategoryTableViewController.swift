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

// Notifies ProfileVc that post has been updated.
protocol UserCategoryTableViewControllerDelegate {
    func updatedPost(_ post: Post)
}

class UserCategoryTableViewController: UITableViewController {
    
    var user: User?
    var userCategory: UserCategory?
    var userCategoryTableViewControllerDelegate: UserCategoryTableViewControllerDelegate?
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PostDetailsTableViewController,
            let cell = sender as? PostSmallTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.post = self.posts[indexPath.row]
            destinationViewController.postIndexPath = indexPath
            destinationViewController.postDetailsTableViewControllerDelegate = self
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
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, caption: awsPost._caption, categoryName: awsPost._categoryName, creationDate: awsPost._creationDate, imageUrl: awsPost._imageUrl, numberOfLikes: awsPost._numberOfLikes, numberOfComments: awsPost._numberOfComments, user: self.user)
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
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").content(withKey: imageKey)
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

extension UserCategoryTableViewController: PostDetailsTableViewControllerDelegate {
    
    func updatedPost(_ post: Post, postIndexPath: IndexPath) {
        self.posts[postIndexPath.row] = post
        self.tableView.reloadRows(at: [postIndexPath], with: UITableViewRowAnimation.none)
        // Notify ProfileVc
        self.userCategoryTableViewControllerDelegate?.updatedPost(post)
    }
}
