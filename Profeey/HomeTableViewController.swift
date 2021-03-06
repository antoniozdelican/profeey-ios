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
import PhotosUI

enum ImageType {
    case userProfilePic
    case postPic
}

class HomeTableViewController: UITableViewController {
    
    @IBOutlet var homeEmptyFeedView: HomeEmptyFeedView!
    @IBOutlet var homeNoNetworkView: HomeNoNetworkView!
    @IBOutlet var loadingTableFooterView: UIView!
    
    fileprivate var posts: [Post] = []
    
    // Before any post is loaded.
    fileprivate var isLoadingInitialPosts: Bool = false
    fileprivate var activityIndicatorView: UIActivityIndicatorView?
    
    fileprivate var isLoadingNextPosts: Bool = false
    fileprivate var isRefreshingPosts: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    
    /*
     Special case, when new user doesn't have any posts (activities) on the feed and starts following 
     users in DiscoverVc or UsersVc or ProfileVc.
     NSNotification notifies HomeVc to start querying as soons as viewWillAppear.
     This should happen only first time and then set this flag back to false.
    */
    fileprivate var hasDiscoveredAndFollowedUsers: Bool = false
    
    // When uploading new post.
    fileprivate var isUploading: Bool = false

    fileprivate var noNetworkConnection: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "ic_logo_title"))
        self.tableView.delaysContentTouches = false

        // Set background views.
        self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.tableView.backgroundView = self.activityIndicatorView
        Bundle.main.loadNibNamed("HomeEmptyFeedView", owner: self, options: nil)
        self.homeEmptyFeedView.homeEmptyFeedViewDelegate = self
        Bundle.main.loadNibNamed("HomeNoNetworkView", owner: self, options: nil)
        self.homeNoNetworkView.homeNoNetworkViewDelegate = self
        
        // Set backgroundView for statusBar.
        if let navigationController = self.navigationController {
            let statusBarBackgroundView = UIView(frame: UIApplication.shared.statusBarFrame)
            statusBarBackgroundView.backgroundColor = Colors.whiteDark
            navigationController.view.insertSubview(statusBarBackgroundView, belowSubview: navigationController.navigationBar)
        }
        
        // Start querying activities.
        if AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            self.isLoadingInitialPosts = true
            self.activityIndicatorView?.startAnimating()
            self.queryUserActivitiesDateSorted(true)
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePostNotification(_:)), name: NSNotification.Name(UpdatePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deletePostNotification(_:)), name: NSNotification.Name(DeletePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createLikeNotification(_:)), name: NSNotification.Name(CreateLikeNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteLikeNotification(_:)), name: NSNotification.Name(DeleteLikeNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createCommentNotification(_:)), name: NSNotification.Name(CreateCommentNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteCommentNotification(_:)), name: NSNotification.Name(DeleteCommentNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.followUserNotification(_:)), name: NSNotification.Name(FollowUserNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createReportNotification(_:)), name: NSNotification.Name(CreateReportNotificationKey), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Special case.
        if self.hasDiscoveredAndFollowedUsers {
            self.isLoadingInitialPosts = true
            self.tableView.backgroundView = self.activityIndicatorView
            self.activityIndicatorView?.startAnimating()
            self.queryUserActivitiesDateSorted(true)
            // Set back to false.
            self.hasDiscoveredAndFollowedUsers = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let cell = sender as? PostUserTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.user = self.posts[indexPath.section].user?.copyUser()
        }
        if let destinationViewController = segue.destination as? UsersTableViewController,
            let cell = sender as? PostButtonsTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.usersType = UsersType.likers
            destinationViewController.postId = self.posts[indexPath.section].postId
        }
        if let destinationViewController = segue.destination as? PostDetailsViewController,
            let cell = sender as? PostSmallTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.post = self.posts[indexPath.section].copyPost()
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController =  navigationController.childViewControllers[0] as? EditPostTableViewController,
            let cell = sender as? PostUserTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            childViewController.editPost = self.posts[indexPath.section].copyEditPost()
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController =  navigationController.childViewControllers[0] as? ReportTableViewController,
            let cell = sender as? PostUserTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            childViewController.userId = self.posts[indexPath.section].userId
            childViewController.postId = self.posts[indexPath.section].postId
            childViewController.reportType = ReportType.post
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.isLoadingInitialPosts || (self.noNetworkConnection && self.posts.count == 0) {
            return 0
        }
        return self.posts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingInitialPosts || (self.noNetworkConnection && self.posts.count == 0) {
            return 0
        }
        if section == 0 && self.isUploading {
            return 2
        }
        // Reported posts.
        if self.posts[section].isReportedByCurrentUser {
            return 1
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.section]
        let user = post.user
        switch indexPath.row {
        case 0:
            // Reported posts.
            if self.posts[indexPath.section].isReportedByCurrentUser {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostReport", for: indexPath) as! PostReportTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostUser", for: indexPath) as! PostUserTableViewCell
            cell.profilePicImageView.image = user?.profilePicUrl != nil ? user?.profilePic : UIImage(named: "ic_no_profile_pic_feed")
            cell.preferredUsernameLabel.text = user?.preferredUsername
            cell.professionNameLabel.text = user?.professionNameWhitespace
            cell.postUserTableViewCellDelegate = self
            return cell
        case 1:
            if indexPath.section == 0 && self.isUploading {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellUploading", for: indexPath) as! UploadingTableViewCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostSmall", for: indexPath) as! PostSmallTableViewCell
                cell.postImageView.image = post.image
                cell.titleLabel.text = post.caption
                cell.categoryNameLabel.text = post.categoryNameWhitespace
                cell.createdLabel.text = post.createdString
                cell.numberOfLikesLabel.text = post.numberOfLikesSmallString
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is PostUserTableViewCell {
            self.performSegue(withIdentifier: "segueToProfileVc", sender: cell)
        }
        if cell is PostSmallTableViewCell {
            self.performSegue(withIdentifier: "segueToPostDetailsVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        // Load next posts.
        guard !self.isLoadingInitialPosts && !self.isRefreshingPosts else {
            return
        }
        guard indexPath.section == self.posts.count - 1 && !self.isLoadingNextPosts && self.lastEvaluatedKey != nil else {
            return
        }
        guard !self.noNetworkConnection else {
            return
        }
        // Query.
        self.isLoadingNextPosts = true
        self.tableView.tableFooterView = self.loadingTableFooterView
        self.queryUserActivitiesDateSorted(false)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            // Reported posts.
            if self.posts[indexPath.section].isReportedByCurrentUser {
                return 112.0
            }
            return 56.0
        case 1:
            if indexPath.section == 0 && self.isUploading {
                return 40.0
            }
            return 112.0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            // Reported posts.
            if self.posts[indexPath.section].isReportedByCurrentUser {
                return 112.0
            }
            return 56.0
        case 1:
            if indexPath.section == 0 && self.isUploading {
                return 40.0
            }
            return 112.0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        return 6.0
    }
    
    // MARK: IBActions
    
    @IBAction func addPostButtonTapped(_ sender: AnyObject) {
        // Check Photos access for the first time. This can happen on MainTabBarVc, HomeVc, UsernameVc, ProfileVc and EditVc.
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({
                (status: PHAuthorizationStatus) in
                self.performSegue(withIdentifier: "segueToCaptureVc", sender: self)
            })
        } else {
            self.performSegue(withIdentifier: "segueToCaptureVc", sender: self)
        }
    }
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard !self.isRefreshingPosts && !self.isLoadingInitialPosts else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.isRefreshingPosts = true
        self.queryUserActivitiesDateSorted(true)
    }
    
    
    // From Capture flow.
    @IBAction func unwindToHomeTableViewController(_ segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? AddInfoTableViewController {
            guard let image = sourceViewController.postImage,
                let imageData = UIImageJPEGRepresentation(image, 0.6) else {
                return
            }
            let newPost = Post()
            newPost.user = PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB
            
            // Prepare for uploading.
            self.isUploading = true
            self.posts.insert(newPost, at: 0)
            self.tableView.beginUpdates()
            self.tableView.insertSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
            self.tableView.endUpdates()
            self.tableView.backgroundView = nil
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
            // Upload image sync.
            self.uploadImage(imageData, imageWidth: NSNumber(value: Float(image.size.width)), imageHeight: NSNumber(value: Float(image.size.height)), caption: sourceViewController.caption, categoryName: sourceViewController.categoryName)
        }
    }
    
    // MARK: AWS
    
    fileprivate func queryUserActivitiesDateSorted(_ startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserActivitiesDateSortedDynamoDB(self.lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryUserActivitiesDateSorted error: \(error!)")
                    // Reset flags and animations that were initiated.
                    self.isLoadingInitialPosts = false
                    self.activityIndicatorView?.stopAnimating()
                    self.isRefreshingPosts = false
                    self.refreshControl?.endRefreshing()
                    self.isLoadingNextPosts = false
                    self.tableView.tableFooterView = UIView()
                    // Handle error and show banner.
                    if (error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                        if self.posts.count == 0 {
                            // Only put if no yet loaded any post.
                            self.tableView.backgroundView = self.homeNoNetworkView
                        }
                    }
                    // Reload tableView.
                    self.tableView.reloadData()
                    return
                }
                if startFromBeginning {
                    self.posts = []
                }
                var numberOfNewPosts = 0
                if let awsActivities = response?.items as? [AWSActivity] {
                    for awsActivity in awsActivities {
                        let user = User(userId: awsActivity._postUserId, firstName: awsActivity._firstName, lastName: awsActivity._lastName, preferredUsername: awsActivity._preferredUsername, professionName: awsActivity._professionName, profilePicUrl: awsActivity._profilePicUrl)
                        let post = Post(userId: awsActivity._postUserId, postId: awsActivity._postId, created: awsActivity._created, caption: awsActivity._caption, categoryName: awsActivity._categoryName, imageUrl: awsActivity._imageUrl, imageWidth: awsActivity._imageWidth, imageHeight: awsActivity._imageHeight, numberOfLikes: awsActivity._numberOfLikes, numberOfComments: awsActivity._numberOfComments, user: user)
                        self.posts.append(post)
                        numberOfNewPosts += 1
                        // Immediately getLike.
                        if let postId = awsActivity._postId {
                            self.getLike(postId)
                        }
                    }
                }
                // Reset flags and animations that were initiated.
                self.isLoadingInitialPosts = false
                self.activityIndicatorView?.stopAnimating()
                self.isRefreshingPosts = false
                self.refreshControl?.endRefreshing()
                self.isLoadingNextPosts = false
                self.tableView.backgroundView = self.posts.count == 0 ? self.homeEmptyFeedView: nil
                self.noNetworkConnection = false
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                self.tableView.tableFooterView = UIView()
                
                // Reload tableView with downloaded posts.
                if startFromBeginning || numberOfNewPosts > 0 {
                    self.tableView.reloadData()
                }
                
                // Load posts (activities) images.
                if let awsActivities = response?.items as? [AWSActivity] {
                    for awsActivity in awsActivities {
                        if let profilePicUrl = awsActivity._profilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                        }
                        if let imageUrl = awsActivity._imageUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(imageUrl, imageType: .postPic)
                        }
                    }
                }
            })
        })
    }
    
    // Check if currentUser liked a post.
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
    
    // In background.
    fileprivate func createLike(_ postId: String, postUserId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createLikeDynamoDB(postId, postUserId: postUserId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("saveLike error: \(error)")
                    // Undo UI.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: DeleteLikeNotificationKey), object: self, userInfo: ["postId": postId])
                }
            })
            return nil
        })
    }
    
    // In background.
    fileprivate func removeLike(_ postId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeLikeDynamoDB(postId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("removeLike error: \(error)")
                    // Undo UI.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreateLikeNotificationKey), object: self, userInfo: ["postId": postId])
                }
            })
            return nil
        })
    }
    
    fileprivate func uploadImage(_ imageData: Data, imageWidth: NSNumber, imageHeight: NSNumber, caption: String?, categoryName: String?) {
        let uniqueImageName = NSUUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let imageKey = "public/\(uniqueImageName).jpg"
        let localContent = AWSUserFileManager.defaultUserFileManager().localContent(with: imageData, key: imageKey)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        localContent.uploadWithPin(
            onCompletion: true,
            progressBlock: {
                (content: AWSLocalContent?, progress: Progress?) -> Void in
                DispatchQueue.main.async(execute: {
                    if let progress = progress {
                       (self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? UploadingTableViewCell)?.progressView.progress = Float(progress.fractionCompleted)
                    }
                })
            }, completionHandler: {
                (content: AWSLocalContent?, error: Error?) -> Void in
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let error = error {
                        print("uploadImageS3 error: \(error)")
                        self.isUploading = false
                        // Handle error.
                        self.posts.remove(at: 0)
                        self.tableView.beginUpdates()
                        self.tableView.deleteSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
                        self.tableView.endUpdates()
                        self.tableView.backgroundView = self.posts.count == 0 ? self.homeEmptyFeedView: nil
                        let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        // Save post in DynamoDB.
                        self.createPost(imageData, imageUrl: imageKey, imageWidth: imageWidth, imageHeight: imageHeight, caption: caption, categoryName: categoryName)
                    }
                })
        })
    }
    
    fileprivate func createPost(_ imageData: Data, imageUrl: String, imageWidth: NSNumber, imageHeight: NSNumber, caption: String?, categoryName: String?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createPostDynamoDB(imageUrl, imageWidth: imageWidth, imageHeight: imageHeight, caption: caption, categoryName: categoryName, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isUploading = false
                if let error = task.error {
                    print("savePost error: \(error)")
                    // Handle error.
                    self.posts.remove(at: 0)
                    self.tableView.beginUpdates()
                    self.tableView.deleteSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
                    self.tableView.endUpdates()
                    self.tableView.backgroundView = self.posts.count == 0 ? self.homeEmptyFeedView: nil
                    // Undo.
                    PRFYS3Manager.defaultS3Manager().removeImageS3(imageUrl)
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    if let awsPost = task.result as? AWSPost {
                        let newPost = Post(userId: awsPost._userId, postId: awsPost._postId, created: awsPost._created, caption: awsPost._caption, categoryName: awsPost._categoryName, imageUrl: awsPost._imageUrl, imageWidth: awsPost._imageWidth, imageHeight: awsPost._imageHeight, numberOfLikes: awsPost._numberOfLikes, numberOfComments: awsPost._numberOfComments, user: PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB)
                        newPost.image = UIImage(data: imageData)
                        // Update new post.
                        self.posts[0] = newPost
                        UIView.performWithoutAnimation {
                            self.tableView.beginUpdates()
                            self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
                            self.tableView.endUpdates()
                        }
                        // Notifiy observers.
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreatePostNotificationKey), object: self, userInfo: ["post": newPost.copyPost()])
                    }
                }
            })
            return nil
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
}

extension HomeTableViewController {
    
     // MARK: NotificationCenterActions
    
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
        (self.tableView.cellForRow(at: IndexPath(row: 1, section: postIndex)) as? PostSmallTableViewCell)?.titleLabel.text = post.caption
        (self.tableView.cellForRow(at: IndexPath(row: 1, section: postIndex)) as? PostSmallTableViewCell)?.categoryNameLabel.text = post.categoryNameWhitespace
    }
    
    func deletePostNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        self.posts.remove(at: postIndex)
        self.tableView.beginUpdates()
        self.tableView.deleteSections(IndexSet(integer: postIndex), with: UITableViewRowAnimation.top)
        self.tableView.endUpdates()
        self.tableView.backgroundView = self.posts.count == 0 ? self.homeEmptyFeedView: nil
    }
    
    func createLikeNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.numberOfLikes = NSNumber(value: post.numberOfLikesInt + 1)
        post.isLikedByCurrentUser = true
        (self.tableView.cellForRow(at: IndexPath(row: 1, section: postIndex)) as? PostSmallTableViewCell)?.numberOfLikesLabel.text = post.numberOfLikesSmallString
    }
    
    func deleteLikeNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.numberOfLikes = NSNumber(value: post.numberOfLikesInt - 1)
        post.isLikedByCurrentUser = false
        (self.tableView.cellForRow(at: IndexPath(row: 1, section: postIndex)) as? PostSmallTableViewCell)?.numberOfLikesLabel.text = post.numberOfLikesSmallString
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
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        // Update data source and cells.
        let post = self.posts[postIndex]
        post.numberOfComments = NSNumber(value: post.numberOfCommentsInt - 1)
    }
    
    // Special case used only when there's no posts(activities) for a new user.
    func followUserNotification(_ notification: NSNotification) {
        guard let _ = notification.userInfo?["followingId"] as? String else {
            return
        }
        guard self.posts.count == 0, self.hasDiscoveredAndFollowedUsers == false else {
            return
        }
        self.hasDiscoveredAndFollowedUsers = true
    }
    
    func downloadImageNotification(_ notification: NSNotification) {
        guard let imageKey = notification.userInfo?["imageKey"] as? String, let imageType = notification.userInfo?["imageType"] as? ImageType, let imageData = notification.userInfo?["imageData"] as? Data else {
            return
        }
        switch imageType {
        case .userProfilePic:
            for post in self.posts.filter( { $0.user?.profilePicUrl == imageKey }) {
                if let postIndex = self.posts.index(of: post) {
                    /*
                     Update data source and UI.
                     This is better for memory than reloading row because it's not initializing new cells!
                     */
                    self.posts[postIndex].user?.profilePic = UIImage(data: imageData)
                    (self.tableView.cellForRow(at: IndexPath(row: 0, section: postIndex)) as? PostUserTableViewCell)?.profilePicImageView.image = self.posts[postIndex].user?.profilePic
                }
            }
        case .postPic:
            for post in self.posts.filter( { $0.imageUrl == imageKey }) {
                if let postIndex = self.posts.index(of: post) {
                    self.posts[postIndex].image = UIImage(data: imageData)
                    (self.tableView.cellForRow(at: IndexPath(row: 1, section: postIndex)) as? PostSmallTableViewCell)?.postImageView.image = self.posts[postIndex].image
                }
            }
        }
    }
    
    func createReportNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String, notification.userInfo?["commentId"] == nil else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.isReportedByCurrentUser = true
        self.tableView.reloadSections(IndexSet([postIndex]), with: UITableViewRowAnimation.none)
    }
    
    // MARK: Public
    
    func homeTabBarButtonTapped() {
        guard self.posts.count > 0 else {
            return
        }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
}

extension HomeTableViewController: PostUserTableViewCellDelegate {
    
    func expandButtonTapped(_ cell: PostUserTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        let post = self.posts[indexPath.section]
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

extension HomeTableViewController: HomeEmptyFeedViewDelegate {
    
    func discoverButtonTapped() {
        self.performSegue(withIdentifier: "segueToDiscoverPeopleVc", sender: self)
    }
}

extension HomeTableViewController: HomeNoNetworkViewDelegate {
    
    func noNetworkViewTapped() {
        self.tableView.backgroundView = self.activityIndicatorView
        if AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            self.isLoadingInitialPosts = true
            self.activityIndicatorView?.startAnimating()
            self.queryUserActivitiesDateSorted(true)
        }
    }
}
