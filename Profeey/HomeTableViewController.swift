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
//import TTTAttributedLabel

enum ImageType {
    case currentUserProfilePic
    case userProfilePic
    case postPic
}

class HomeTableViewController: UITableViewController {
    
    @IBOutlet var homeEmptyFeedView: HomeEmptyFeedView!
    
    fileprivate var posts: [Post] = []
    // Before any post is loaded.
    fileprivate var isLoadingPosts: Bool = false
    fileprivate var activityIndicatorView: UIActivityIndicatorView?
    // When uploading new post.
    fileprivate var isUploading: Bool = false
    fileprivate var newPostProgress: Progress?
    // Remeber if navigationBar was hidden.
    fileprivate var isNavigationBarHidden: Bool = false
    // Different behaviour depending on segue or tabBarSwitch.
    var isTabBarSwitch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.delaysContentTouches = false
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        
        // Set background views
        self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.tableView.backgroundView = self.activityIndicatorView
        Bundle.main.loadNibNamed("HomeEmptyFeedView", owner: self, options: nil)
        self.homeEmptyFeedView.homeEmptyFeedViewDelegate = self
        
        if let currentUser = AWSClientManager.defaultClientManager().userPool?.currentUser(), currentUser.isSignedIn {
            self.isLoadingPosts = true
            self.activityIndicatorView?.startAnimating()
            self.getCurrentUser()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isNavigationBarHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: !self.isTabBarSwitch)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = self.navigationController , navigationController.isNavigationBarHidden {
            self.isNavigationBarHidden = true
        } else {
            self.isNavigationBarHidden = false
        }
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Reset tabBarSwitch.
        self.isTabBarSwitch = false
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.user = self.posts[indexPath.section].user
        }
        if let destinationViewController = segue.destination as? UsersTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.usersType = UsersType.likers
            destinationViewController.postId = self.posts[indexPath.section].postId
        }
        if let destinationViewController = segue.destination as? CommentsViewController,
            let button = sender as? UIButton,
            let indexPath = self.tableView.indexPathForView(view: button) {
            destinationViewController.post = self.posts[indexPath.section]
            destinationViewController.commentsViewControllerNotificationDelegate = self
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController =  navigationController.childViewControllers[0] as? EditPostViewController,
            let button = sender as? UIButton,
            let indexPath = self.tableView.indexPathForView(view: button) {
            childViewController.post = self.posts[indexPath.section]
            childViewController.postIndexPath = indexPath
            childViewController.editPostViewControllerDelegate = self
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.isLoadingPosts {
            return 0
        }
        return self.posts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingPosts {
            return 0
        }
        if section == 0 && self.isUploading {
            return 2
        }
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && self.isUploading {
            // Dummy post user.
            let user = self.posts[indexPath.section].user
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostUser", for: indexPath) as! PostUserTableViewCell
                cell.profilePicImageView.image = user?.profilePic
                cell.preferredUsernameLabel.text = user?.preferredUsername
                cell.professionNameLabel.text = user?.professionName
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellUploading", for: indexPath) as! UploadingTableViewCell
                if let progress = self.newPostProgress {
                    cell.progressView.progress = Float(progress.fractionCompleted)
                }
                return cell
            default:
                return UITableViewCell()
            }
        }
        let post = self.posts[indexPath.section]
        let user = post.user
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostUser", for: indexPath) as! PostUserTableViewCell
            cell.profilePicImageView.image = user?.profilePic
            cell.preferredUsernameLabel.text = user?.preferredUsername
            cell.professionNameLabel.text = user?.professionName
            cell.postUserTableViewCellDelegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostImage", for: indexPath) as! PostImageTableViewCell
            cell.postImageView.image = post.image
            if let imageWidth = post.imageWidth?.floatValue, let imageHeight = post.imageHeight?.floatValue {
                let aspectRatio = CGFloat(imageWidth / imageHeight)
                cell.postImageViewHeightConstraint.constant = ceil(tableView.bounds.width / aspectRatio)
            }
            return cell
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
            self.performSegue(withIdentifier: "segueToProfileVc", sender: indexPath)
        }
        if cell is PostInfoTableViewCell {
           self.posts[indexPath.section].isExpandedCaption = true
            self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 64.0
        case 1:
            if indexPath.section == 0 && self.isUploading {
                return 40.0
            }
            return 400.0
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
            return UITableViewAutomaticDimension
        case 2:
            return UITableViewAutomaticDimension
        case 3:
            return UITableViewAutomaticDimension
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
        guard let userId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.queryUserActivitiesDateSorted(userId)
    }
    
    @IBAction func unwindToHomeTableViewController(_ segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? AddInfoTableViewController {
            guard let post = sourceViewController.post,
                let image = post.image,
                let imageData = UIImageJPEGRepresentation(image, 0.6) else {
                return
            }
            self.isUploading = true
            // Add dummy post for uploading.
            let dummyPost = Post()
            dummyPost.user = PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB
            self.posts.insert(dummyPost, at: 0)
            if let _ = self.tableView.backgroundView as? HomeEmptyFeedView {
                self.tableView.backgroundView = nil
            }
            self.tableView.reloadData()
            self.uploadImage(imageData, imageWidth: NSNumber(value: Float(image.size.width)), imageHeight: NSNumber(value: Float(image.size.height)), caption: post.caption, categoryName: post.categoryName)
        }
    }
    
    // MARK: Helpers
    
    fileprivate func reloadRow(_ indexPath: IndexPath) {
        UIView.performWithoutAnimation {
            self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        }
    }
    
    // MARK: AWS
    
    // Gets currentUser and credentialsProvider.idenityId
    // Creates currentUserDynamoDB on singleton.
    fileprivate func getCurrentUser() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getCurrentUserDynamoDB({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getCurrentUser error: \(error)")
                } else {
                    guard let awsUser = task.result as? AWSUser else {
                        return
                    }
                    let currentUser = CurrentUser(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationName: awsUser._locationName)
                    // Store properties!
                    PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB = currentUser
                    
                    if let profilePicUrl = awsUser._profilePicUrl {
                        self.downloadImage(profilePicUrl, imageType: .currentUserProfilePic, indexPath: nil)
                    }
                    if let userId = awsUser._userId {
                        self.queryUserActivitiesDateSorted(userId)
                    }
                }
            })
            return nil
        })
    }
    
    // Query the feed.
    fileprivate func queryUserActivitiesDateSorted(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserActivitiesDateSortedDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingPosts = false
                self.activityIndicatorView?.stopAnimating()
                self.refreshControl?.endRefreshing()
                if let error = error {
                    print("queryUserActivitiesDateSorted error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsActivities = response?.items as? [AWSActivity], awsActivities.count > 0 else {
                        // Set the homeEmptyFeedView.
                        self.tableView.backgroundView = self.homeEmptyFeedView
                        self.tableView.reloadData()
                        return
                    }
                    self.posts = []
                    for awsActivity in awsActivities {
                        let user = User(userId: awsActivity._postUserId, firstName: awsActivity._firstName, lastName: awsActivity._lastName, preferredUsername: awsActivity._preferredUsername, professionName: awsActivity._professionName, profilePicUrl: awsActivity._profilePicUrl)
                        let post = Post(userId: awsActivity._postUserId, postId: awsActivity._postId, creationDate: awsActivity._creationDate, caption: awsActivity._caption, categoryName: awsActivity._categoryName, imageUrl: awsActivity._imageUrl, imageWidth: awsActivity._imageWidth, imageHeight: awsActivity._imageHeight, numberOfLikes: awsActivity._numberOfLikes, numberOfComments: awsActivity._numberOfComments, user: user)
                        self.posts.append(post)
                    }
                    self.tableView.reloadData()
                    
                    for (index, post) in self.posts.enumerated() {
                        if let profilePicUrl = post.user?.profilePicUrl {
                            let indexPath = IndexPath(row: 0, section: index)
                            self.downloadImage(profilePicUrl, imageType: .userProfilePic, indexPath: indexPath)
                        }
                        if let imageUrl = post.imageUrl {
                            let indexPath = IndexPath(row: 1, section: index)
                            self.downloadImage(imageUrl, imageType: .postPic, indexPath: indexPath)
                        }
                        if let postId = post.postId {
                            let indexPath = IndexPath(row: 4, section: index)
                            self.getLike(postId, indexPath: indexPath)
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func downloadImage(_ imageKey: String, imageType: ImageType, indexPath: IndexPath?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let content = AWSUserFileManager.UserFileManager(forKey: "USEast1BucketManager").content(withKey: imageKey)
        // TODO check if content.isImage()
        if content.isCached {
            print("Content cached:")
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            switch imageType {
            case .currentUserProfilePic:
                // Store profilePic.
                PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB?.profilePic = image
            case .userProfilePic:
                if let indexPath = indexPath {
                    self.posts[indexPath.section].user?.profilePic = image
                    self.reloadRow(indexPath)
                }
            case .postPic:
                if let indexPath = indexPath {
                    self.posts[indexPath.section].image = image
                    self.reloadRow(indexPath)
                }
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
                    (content: AWSContent?, data: Data?, error:  Error?) in
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if let error = error {
                            print("downloadImage error: \(error)")
                        } else {
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                switch imageType {
                                case .currentUserProfilePic:
                                    // Store profilePic.
                                    PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB?.profilePic = image
                                case .userProfilePic:
                                    if let indexPath = indexPath {
                                        self.posts[indexPath.section].user?.profilePic = image
                                        self.reloadRow(indexPath)
                                    }
                                case .postPic:
                                    if let indexPath = indexPath {
                                        self.posts[indexPath.section].image = image
                                        self.reloadRow(indexPath)
                                    }
                                }
                            }
                        }
                    })
            })
        }
    }
    
    fileprivate func uploadImage(_ imageData: Data, imageWidth: NSNumber, imageHeight: NSNumber, caption: String?, categoryName: String?) {
        let uniqueImageName = NSUUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let imageKey = "public/\(uniqueImageName).jpg"
        let localContent = AWSUserFileManager.UserFileManager(forKey: "USEast1BucketManager").localContent(with: imageData, key: imageKey)
        
        print("uploadImageS3:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        localContent.uploadWithPin(
            onCompletion: false,
            progressBlock: {
                (content: AWSLocalContent?, progress: Progress?) -> Void in
                DispatchQueue.main.async(execute: {
                    self.newPostProgress = progress
                    let indexPath = IndexPath(row: 1, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                })
            }, completionHandler: {
                (content: AWSLocalContent?, error: Error?) -> Void in
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let error = error {
                        print("uploadImageS3 error: \(error)")
                        self.isUploading = false
                        // Remove dummy post.
                        self.posts.remove(at: 0)
                        self.tableView.reloadData()
                        let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        // Save post in DynamoDB.
                        self.createPost(imageData, imageUrl: imageKey, imageWidth: imageWidth, imageHeight: imageHeight, caption: caption, categoryName: categoryName)
                    }
                })
        })
    }
    
    fileprivate func removeImage(_ imageKey: String, postId: String) {
        let content = AWSUserFileManager.UserFileManager(forKey: "USEast1BucketManager").content(withKey: imageKey)
        print("removeImageS3:")
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
                    self.removePost(postId)
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
                    // Remove dummy post.
                    self.posts.remove(at: 0)
                    // Add HomeEmptyFeedView if there's no followed posts.
                    if self.posts.count == 0 {
                        self.tableView.backgroundView = self.homeEmptyFeedView
                    }
                    self.tableView.reloadData()
                } else {
                    if let awsPost = task.result as? AWSPost {
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, creationDate: awsPost._creationDate, caption: awsPost._caption, categoryName: awsPost._categoryName, imageUrl: awsPost._imageUrl, imageWidth: awsPost._imageWidth, imageHeight: awsPost._imageHeight, numberOfLikes: awsPost._numberOfLikes, numberOfComments: awsPost._numberOfComments, user: PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB)
                        let image = UIImage(data: imageData)
                        post.image = image
                        
                        // Remove dummy post.
                        self.posts.remove(at: 0)
                        // Add new post.
                        self.posts.insert(post, at: 0)
                        self.tableView.reloadData()
                    }
                }
            })
            return nil
        })
    }
    
    fileprivate func removePost(_ postId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removePostDynamoDB(postId, completionHandler: {
           (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("removePost error: \(error)")
                }
            })
            return nil
        })
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
                        self.posts[indexPath.section].isLikedByCurrentUser = true
                        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                    }
                }
            })
            return nil
        })
    }
    
    // Create and remove like are done in background.
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

extension HomeTableViewController: PostUserTableViewCellDelegate {
    
    func expandButtonTapped(_ button: UIButton) {
        guard let indexPath = self.tableView.indexPathForView(view: button) else {
            return
        }
        let post = self.posts[indexPath.section]
        guard let postId = post.postId, let postUserId = post.userId, let imageKey = post.imageUrl else {
            return
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        if postUserId == AWSClientManager.defaultClientManager().credentialsProvider?.identityId {
            // DELETE
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {
                (alert: UIAlertAction) in
                let alertController = UIAlertController(title: "Delete Post?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                let deleteConfirmAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {
                   (alert: UIAlertAction) in
                    // In background
                    self.removeImage(imageKey, postId: postId)
                    self.posts.remove(at: indexPath.section)
                    if self.posts.count == 0 {
                        // Add HomeEmptyFeedView if there's no followed posts.
                        self.tableView.backgroundView = self.homeEmptyFeedView
                        self.tableView.reloadData()
                    } else {
                        self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.top)
                    }
                })
                alertController.addAction(deleteConfirmAction)
                self.present(alertController, animated: true, completion: nil)
            })
            alertController.addAction(deleteAction)
            // EDIT
            let editAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction) in
                self.performSegue(withIdentifier: "segueToEditPostVc", sender: button)
            })
            alertController.addAction(editAction)
        } else {
            // REPORT
            let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive, handler: nil)
            alertController.addAction(reportAction)
        }
        // CANCEL
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension HomeTableViewController: PostButtonsTableViewCellDelegate {
    
    func likeButtonTapped(_ button: UIButton) {
        guard let indexPath = self.tableView.indexPathForView(view: button) else {
            return
        }
        let post = self.posts[indexPath.section]
        guard let postId = post.postId, let postUserId = post.userId else {
            return
        }
        let numberOfLikes = (post.numberOfLikes != nil) ? post.numberOfLikes! : 0
        let numberOfLikesInteger = numberOfLikes.intValue
        if post.isLikedByCurrentUser {
            post.isLikedByCurrentUser = false
            post.numberOfLikes = NSNumber(value: (numberOfLikesInteger - 1) as Int)
            self.removeLike(postId)
        } else {
            post.isLikedByCurrentUser = true
            post.numberOfLikes = NSNumber(value: (numberOfLikesInteger + 1) as Int)
            self.createLike(postId, postUserId: postUserId)
        }
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
    
    func commentButtonTapped(_ button: UIButton) {
        self.performSegue(withIdentifier: "segueToCommentsVc", sender: button)
    }
    
    func numberOfLikesButtonTapped(_ button: UIButton) {
        guard let indexPath = self.tableView.indexPathForView(view: button) else {
            return
        }
        self.performSegue(withIdentifier: "segueToUsersVc", sender: indexPath)
    }
    
    func numberOfCommentsButtonTapped(_ button: UIButton) {
        self.performSegue(withIdentifier: "segueToCommentsVc", sender: button)
    }
}

extension HomeTableViewController: EditPostViewControllerDelegate {
    
    func updatedPost(_ post: Post, withIndexPath postIndexPath: IndexPath) {
        self.posts[postIndexPath.section].caption = post.caption
        self.posts[postIndexPath.section].categoryName = post.categoryName
        self.tableView.reloadSections(IndexSet(integer: postIndexPath.section), with: UITableViewRowAnimation.none)
    }
}

extension HomeTableViewController: HomeEmptyFeedViewDelegate {
    
    func discoverButtonTapped() {
        self.performSegue(withIdentifier: "segueToDiscoverPeopleVc", sender: self)
    }
}

extension HomeTableViewController: CommentsViewControllerNotificationDelegate {
    
    func commentCreated(_ postId: String) {
        guard let updatedPost = self.posts.first(where: { $0.postId == postId }), let postIndex = self.posts.index(of: updatedPost) else {
            return
        }
        if let numberOfComments = self.posts[postIndex].numberOfComments {
            self.posts[postIndex].numberOfComments = NSNumber(value: numberOfComments.intValue + 1)
        } else {
            self.posts[postIndex].numberOfComments = NSNumber(value: 1)
        }
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: postIndex), with: UITableViewRowAnimation.none)
        }
        
    }
    
    func commentRemoved(_ postId: String) {
        guard let updatedPost = self.posts.first(where: { $0.postId == postId }), let postIndex = self.posts.index(of: updatedPost) else {
            return
        }
        if let numberOfComments = self.posts[postIndex].numberOfComments, numberOfComments.intValue > 0 {
            self.posts[postIndex].numberOfComments = NSNumber(value: numberOfComments.intValue - 1)
        } else {
            self.posts[postIndex].numberOfComments = NSNumber(value: 0)
        }
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: postIndex), with: UITableViewRowAnimation.none)
        }
    }
}
