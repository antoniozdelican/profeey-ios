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

enum ImageType {
    case userProfilePic
    case postPic
}

class HomeTableViewController: UITableViewController {
    
    @IBOutlet var homeEmptyFeedView: HomeEmptyFeedView!
    
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
    fileprivate var newPostProgress: Progress?
    
    // Different behaviour depending on segue or tabBarSwitch.
    fileprivate var isNavigationBarHidden: Bool = false
    var isTabBarSwitch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.delaysContentTouches = false
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)

        // Set background views.
        self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.tableView.backgroundView = self.activityIndicatorView
        Bundle.main.loadNibNamed("HomeEmptyFeedView", owner: self, options: nil)
        self.homeEmptyFeedView.homeEmptyFeedViewDelegate = self
        
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
        
        // Add observers, don't need deinit removeObserver.
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePostNotification(_:)), name: NSNotification.Name(UpdatePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deletePostNotification(_:)), name: NSNotification.Name(DeletePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePostNumberOfLikesNotification(_:)), name: NSNotification.Name(UpdatePostNumberOfLikesNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createCommentNotification(_:)), name: NSNotification.Name(CreateCommentNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteCommentNotification(_:)), name: NSNotification.Name(DeleteCommentNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.followUserNotification(_:)), name: NSNotification.Name(FollowUserNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isNavigationBarHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: !self.isTabBarSwitch)
        }
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let navigationController = self.navigationController else {
            return
        }
        if navigationController.isNavigationBarHidden {
            self.isNavigationBarHidden = true
        } else {
            self.isNavigationBarHidden = false
        }
        // Only hide navigationBar if it's push, not CaptureVc presenting modally.
        if navigationController.childViewControllers.count > 1 {
            navigationController.hidesBarsOnSwipe = false
            navigationController.setNavigationBarHidden(false, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Reset tabBarSwitch.
        self.isTabBarSwitch = false
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
        if let destinationViewController = segue.destination as? CommentsViewController,
            let cell = sender as? PostButtonsTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.postId = self.posts[indexPath.section].postId
            destinationViewController.postUserId = self.posts[indexPath.section].userId
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController =  navigationController.childViewControllers[0] as? EditPostViewController,
            let cell = sender as? PostUserTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            childViewController.editPost = self.posts[indexPath.section].copyEditPost()
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.isLoadingInitialPosts {
            return 0
        }
        return self.posts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingInitialPosts {
            return 0
        }
        if section == 0 && self.isUploading {
            return 2
        }
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.section]
        let user = post.user
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostUser", for: indexPath) as! PostUserTableViewCell
            cell.profilePicImageView.image = user?.profilePicUrl != nil ? user?.profilePic : UIImage(named: "ic_no_profile_pic_feed")
            cell.preferredUsernameLabel.text = user?.preferredUsername
            cell.professionNameLabel.text = user?.professionName
            cell.postUserTableViewCellDelegate = self
            return cell
        case 1:
            if indexPath.section == 0 && self.isUploading {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellUploading", for: indexPath) as! UploadingTableViewCell
                if let progress = self.newPostProgress {
                    cell.progressView.progress = Float(progress.fractionCompleted)
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostImage", for: indexPath) as! PostImageTableViewCell
                cell.postImageView.image = post.image
                if let imageWidth = post.imageWidth?.floatValue, let imageHeight = post.imageHeight?.floatValue {
                    let aspectRatio = CGFloat(imageWidth / imageHeight)
                    cell.postImageViewHeightConstraint.constant = ceil(tableView.bounds.width / aspectRatio)
                }
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostInfo", for: indexPath) as! PostInfoTableViewCell
            cell.captionLabel.text = post.caption
            post.isExpandedCaption ? cell.untruncate() : cell.truncate()
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostCategoryCreationDate", for: indexPath) as! PostCategoryCreationDateTableViewCell
            cell.categoryNameCreationDateLabel.text = [post.categoryName, post.creationDateString].flatMap({$0}).joined(separator: " · ")
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostButtons", for: indexPath) as! PostButtonsTableViewCell
            post.isLikedByCurrentUser ? cell.setSelectedLikeButton() : cell.setUnselectedLikeButton()
            cell.postButtonsTableViewCellDelegate = self
            cell.numberOfLikesButton.isHidden = (post.numberOfLikesString != nil) ? false : true
            cell.numberOfLikesButton.setTitle(post.numberOfLikesString, for: UIControlState())
            cell.numberOfCommentsButton.isHidden = (post.numberOfCommentsString != nil) ? false : true
            cell.numberOfCommentsButton.setTitle(post.numberOfCommentsString, for: UIControlState())
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
            self.performSegue(withIdentifier: "segueToProfileVc", sender: cell)
        }
        if cell is PostInfoTableViewCell && !self.posts[indexPath.section].isExpandedCaption {
            self.posts[indexPath.section].isExpandedCaption = true
            self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        // Load next posts.
        guard !self.isLoadingInitialPosts && !self.isRefreshingPosts else {
            return
        }
        guard indexPath.section == self.posts.count - 1 && !self.isLoadingNextPosts && self.lastEvaluatedKey != nil else {
            return
        }
        self.isLoadingNextPosts = true
        self.queryUserActivitiesDateSorted(false)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 64.0
        case 1:
            if indexPath.section == 0 && self.isUploading {
                return 40.0
            }
            if let imageWidth = self.posts[indexPath.section].imageWidth?.floatValue, let imageHeight = self.posts[indexPath.section].imageHeight?.floatValue {
                let aspectRatio = CGFloat(imageWidth / imageHeight)
                return ceil(tableView.bounds.width / aspectRatio)
            }
            return 0.0
        case 2:
            return 30.0
        case 3:
            return 26.0
        case 4:
            return 52.0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 64.0
        case 1:
            if indexPath.section == 0 && self.isUploading {
                return 40.0
            }
            if let imageWidth = self.posts[indexPath.section].imageWidth?.floatValue, let imageHeight = self.posts[indexPath.section].imageHeight?.floatValue {
                let aspectRatio = CGFloat(imageWidth / imageHeight)
                return ceil(tableView.bounds.width / aspectRatio)
            }
            return 0.0
        case 2:
            return UITableViewAutomaticDimension
        case 3:
            return 26.0
        case 4:
            return 52.0
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
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard !self.isRefreshingPosts && !self.isLoadingInitialPosts else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.isRefreshingPosts = true
        self.queryUserActivitiesDateSorted(true)
    }
    
    @IBAction func discoverPeopleButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToDiscoverPeopleVc", sender: self)
    }
    
    
    // From Capture flow.
    @IBAction func unwindToHomeTableViewController(_ segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? AddInfoTableViewController {
            guard let post = sourceViewController.post,
                let image = post.image,
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
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.isNavigationBarHidden = false
            // Upload image sync.
            self.uploadImage(imageData, imageWidth: NSNumber(value: Float(image.size.width)), imageHeight: NSNumber(value: Float(image.size.height)), caption: post.caption, categoryName: post.categoryName)
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
                guard error == nil else {
                    print("queryUserActivitiesDateSorted error: \(error!)")
                    // Reset flags and animations that were initiated.
                    self.isLoadingInitialPosts = false
                    self.activityIndicatorView?.stopAnimating()
                    self.isRefreshingPosts = false
                    self.refreshControl?.endRefreshing()
                    self.isLoadingNextPosts = false
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    // Reload tableView.
                    self.tableView.reloadData()
                    // Handle error and show banner.
                    let nsError = error as! NSError
                    let errorMessage = nsError.code == -1009 ? "No Internet Connection" : nsError.localizedDescription
                    if nsError.code == -1009 {
                        // TODO No internet connection tableBackgroundView.
                    }
                    (self.navigationController as? PRFYNavigationController)?.showBanner(errorMessage)
                    return
                }
                if startFromBeginning {
                    self.posts = []
                }
                var numberOfNewPosts = 0
                if let awsActivities = response?.items as? [AWSActivity] {
                    for awsActivity in awsActivities {
                        let user = User(userId: awsActivity._postUserId, firstName: awsActivity._firstName, lastName: awsActivity._lastName, preferredUsername: awsActivity._preferredUsername, professionName: awsActivity._professionName, profilePicUrl: awsActivity._profilePicUrl)
                        let post = Post(userId: awsActivity._postUserId, postId: awsActivity._postId, creationDate: awsActivity._creationDate, caption: awsActivity._caption, categoryName: awsActivity._categoryName, imageUrl: awsActivity._imageUrl, imageWidth: awsActivity._imageWidth, imageHeight: awsActivity._imageHeight, numberOfLikes: awsActivity._numberOfLikes, numberOfComments: awsActivity._numberOfComments, user: user)
                        self.posts.append(post)
                        numberOfNewPosts += 1
                        // Immediately getLike.
                        if let postId = awsActivity._postId {
                            self.getLike(postId)
                        }
                    }
                }
                // Reset flags and animations that were initiated.
                if self.isLoadingInitialPosts {
                    self.isLoadingInitialPosts = false
                    self.activityIndicatorView?.stopAnimating()
                }
                if self.isRefreshingPosts {
                    self.isRefreshingPosts = false
                    self.refreshControl?.endRefreshing()
                }
                if self.isLoadingNextPosts {
                    self.isLoadingNextPosts = false
                }
                if self.posts.count == 0 {
                    self.tableView.backgroundView = self.homeEmptyFeedView
                }
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // Reload tableView with downloaded posts.
                if startFromBeginning {
                    self.tableView.reloadData()
                } else if numberOfNewPosts > 0 {
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
                    self.newPostProgress = progress
                    self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.none)
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
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    if let awsPost = task.result as? AWSPost {
                        let newPost = Post(userId: awsPost._userId, postId: awsPost._postId, creationDate: awsPost._creationDate, caption: awsPost._caption, categoryName: awsPost._categoryName, imageUrl: awsPost._imageUrl, imageWidth: awsPost._imageWidth, imageHeight: awsPost._imageHeight, numberOfLikes: awsPost._numberOfLikes, numberOfComments: awsPost._numberOfComments, user: PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB)
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
    
    // TODO: refactor in PRFYS3
    // In background.
    fileprivate func removeImage(_ postId: String, imageKey: String) {
        let content = AWSUserFileManager.defaultUserFileManager().content(withKey: imageKey)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        content.removeRemoteContent(completionHandler: {
            (content: AWSContent?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("removeImageS3 error: \(error)")
                } else {
                    print("removeImageS3 success")
                    content?.removeLocal()
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
                    self.removeImage(postId, imageKey: imageKey)
                }
            })
            return nil
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
                    guard task.result != nil, let postIndex = self.posts.index(where: { $0.postId == postId }) else {
                        return
                    }
                    self.posts[postIndex].isLikedByCurrentUser = true
                    guard let indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows, indexPathsForVisibleRows.contains(where: { $0.section == postIndex }) else {
                        return
                    }
                    UIView.performWithoutAnimation {
                        self.tableView.reloadRows(at: [IndexPath(row: 4, section: postIndex)], with: UITableViewRowAnimation.none)
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
                }
            })
            return nil
        })
    }
}

extension HomeTableViewController {
    
     // MARK: NotificationCenterActions
    
    func createPostNotification() {
        // TODO
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
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: postIndex), with: UITableViewRowAnimation.none)
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
        self.tableView.beginUpdates()
        self.tableView.deleteSections(IndexSet(integer: postIndex), with: UITableViewRowAnimation.top)
        self.tableView.endUpdates()
        self.tableView.backgroundView = self.posts.count == 0 ? self.homeEmptyFeedView: nil
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
        UIView.performWithoutAnimation {
            self.tableView.reloadRows(at: [IndexPath(row: 4, section: postIndex)], with: UITableViewRowAnimation.none)
        }
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
        UIView.performWithoutAnimation {
            self.tableView.reloadRows(at: [IndexPath(row: 4, section: postIndex)], with: UITableViewRowAnimation.none)
        }
    }
    
    func deleteCommentNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.numberOfComments = NSNumber(value: post.numberOfCommentsInt - 1)
        UIView.performWithoutAnimation {
            self.tableView.reloadRows(at: [IndexPath(row: 4, section: postIndex)], with: UITableViewRowAnimation.none)
        }
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
                guard let postIndex = self.posts.index(of: post) else {
                    continue
                }
                self.posts[postIndex].user?.profilePic = UIImage(data: imageData)
                guard let indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows, indexPathsForVisibleRows.contains(where: { $0.section == postIndex }) else {
                    continue
                }
                UIView.performWithoutAnimation {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: postIndex)], with: UITableViewRowAnimation.none)
                    self.tableView.endUpdates()
                }
            }
        case .postPic:
            for post in self.posts.filter( { $0.imageUrl == imageKey }) {
                guard let postIndex = self.posts.index(of: post) else {
                    continue
                }
                self.posts[postIndex].image = UIImage(data: imageData)
                // Reload only if visible.
                guard let indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows, indexPathsForVisibleRows.contains(where: { $0.section == postIndex }) else {
                    continue
                }
                UIView.performWithoutAnimation {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: 1, section: postIndex)], with: UITableViewRowAnimation.none)
                    self.tableView.endUpdates()
                }
            }
        }
    }
    
    // MARK: Public
    
    func homeTabBarButtonTapped() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
        if postUserId == AWSIdentityManager.defaultIdentityManager().identityId {
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
            let editAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction) in
                self.performSegue(withIdentifier: "segueToEditPostVc", sender: cell)
            })
            alertController.addAction(editAction)
        } else {
            let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive, handler: nil)
            alertController.addAction(reportAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension HomeTableViewController: PostButtonsTableViewCellDelegate {
    
    func likeButtonTapped(_ cell: PostButtonsTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        let post = self.posts[indexPath.section]
        guard let postId = post.postId, let postUserId = post.userId else {
            return
        }
        var numberOfLikes = (post.numberOfLikes != nil) ? post.numberOfLikes! : 0
        if post.isLikedByCurrentUser {
            numberOfLikes = NSNumber(value: numberOfLikes.intValue - 1)
            self.removeLike(postId)
        } else {
            numberOfLikes = NSNumber(value: numberOfLikes.intValue + 1)
            self.createLike(postId, postUserId: postUserId)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UpdatePostNumberOfLikesNotificationKey), object: self, userInfo: ["postId": postId, "numberOfLikes": numberOfLikes])
    }
    
    func commentButtonTapped(_ cell: PostButtonsTableViewCell) {
        self.performSegue(withIdentifier: "segueToCommentsVc", sender: cell)
    }
    
    func numberOfLikesButtonTapped(_ cell: PostButtonsTableViewCell) {
        self.performSegue(withIdentifier: "segueToUsersVc", sender: cell)
    }
    
    func numberOfCommentsButtonTapped(_ cell: PostButtonsTableViewCell) {
        self.performSegue(withIdentifier: "segueToCommentsVc", sender: cell)
    }
}

extension HomeTableViewController: HomeEmptyFeedViewDelegate {
    
    func discoverButtonTapped() {
        self.performSegue(withIdentifier: "segueToDiscoverPeopleVc", sender: self)
    }
}
