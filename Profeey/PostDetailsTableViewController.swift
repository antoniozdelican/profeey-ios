//
//  PostDetailsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class PostDetailsTableViewController: UITableViewController {
    
    // If comming from NotificationVc, we have to download the post, otherwise it's already set.
    var shouldDownloadPost: Bool = false
    // If comming from NotificationVc.
    var notificationPostId: String?
    // If comming from ProfileVc or UserCategoriesVc (copied).
    var post: Post?
    
    fileprivate var isLoadingPost: Bool = false
    fileprivate var activityIndicatorView: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        
        if self.shouldDownloadPost, let notificationPostId = self.notificationPostId {
            // Downlod the post.
            self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            self.tableView.backgroundView = self.activityIndicatorView
            self.activityIndicatorView?.startAnimating()
            self.isLoadingPost = true
            self.getPost(notificationPostId)
        } else if let postId = self.post?.postId {
            // Just check if currentUser liked this post.
            self.getLike(postId)
        }
        
        // Add observers.
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
        if let destinationViewController = segue.destination as? ProfileTableViewController {
            destinationViewController.user = self.post?.user?.copyUser()
        }
        if let destinationViewController = segue.destination as? UsersTableViewController {
            destinationViewController.usersType = UsersType.likers
            destinationViewController.postId = self.post?.postId
        }
        if let destinationViewController = segue.destination as? CommentsViewController {
            destinationViewController.postId = self.post?.postId
            destinationViewController.postUserId = self.post?.userId
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController =  navigationController.childViewControllers[0] as? EditPostViewController {
            childViewController.editPost = self.post?.copyEditPost()
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.shouldDownloadPost, self.isLoadingPost {
            return 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = self.post?.user
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostUser", for: indexPath) as! PostUserTableViewCell
            cell.profilePicImageView.image = user?.profilePicUrl != nil ? user?.profilePic : UIImage(named: "ic_no_profile_pic_feed")
            cell.preferredUsernameLabel.text = user?.preferredUsername
            cell.professionNameLabel.text = user?.professionName
            cell.postUserTableViewCellDelegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostImage", for: indexPath) as! PostImageTableViewCell
            cell.postImageView.image = self.post?.image
            if let imageWidth = self.post?.imageWidth?.floatValue, let imageHeight = self.post?.imageHeight?.floatValue {
                let aspectRatio = CGFloat(imageWidth / imageHeight)
                cell.postImageViewHeightConstraint.constant = ceil(tableView.bounds.width / aspectRatio)
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostInfo", for: indexPath) as! PostInfoTableViewCell
            cell.captionLabel.text = self.post?.caption
            cell.untruncate()
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostCategoryCreationDate", for: indexPath) as! PostCategoryCreationDateTableViewCell
            cell.categoryNameCreationDateLabel.text = [self.post?.categoryName, self.post?.creationDateString].flatMap({$0}).joined(separator: " · ")
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostButtons", for: indexPath) as! PostButtonsTableViewCell
            (self.post?.isLikedByCurrentUser != nil && self.post!.isLikedByCurrentUser) ? cell.setSelectedLikeButton() : cell.setUnselectedLikeButton()
            cell.postButtonsTableViewCellDelegate = self
            cell.numberOfLikesButton.isHidden = (self.post?.numberOfLikesString != nil) ? false : true
            cell.numberOfLikesButton.setTitle(self.post?.numberOfLikesString, for: UIControlState())
            cell.numberOfCommentsButton.isHidden = (self.post?.numberOfCommentsString != nil) ? false : true
            cell.numberOfCommentsButton.setTitle(self.post?.numberOfCommentsString, for: UIControlState())
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
            self.post?.isExpandedCaption = true
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
        return 1.0
    }
    
    // MARK: Helpers
    
    fileprivate func setDownloadedImages(_ image: UIImage, imageType: ImageType, indexPath: IndexPath) {
        switch imageType {
        case .userProfilePic:
            self.post?.user?.profilePic = image
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
        case .postPic:
            self.post?.image = image
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
        }
    }
    
    // MARK: AWS
    
    fileprivate func getPost(_ postId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getPostDynamoDB(postId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingPost = false
                self.activityIndicatorView?.stopAnimating()
                if let error = task.error {
                    print("getPost error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsPost = task.result as? AWSPost else {
                        self.tableView.reloadData()
                        return
                    }
                    let user = User(userId: awsPost._userId, firstName: awsPost._firstName, lastName: awsPost._lastName, preferredUsername: awsPost._preferredUsername, professionName: awsPost._professionName, profilePicUrl: awsPost._profilePicUrl)
                    let post = Post(userId: awsPost._userId, postId: awsPost._postId, creationDate: awsPost._creationDate, caption: awsPost._caption, categoryName: awsPost._categoryName, imageUrl: awsPost._imageUrl, imageWidth: awsPost._imageWidth, imageHeight: awsPost._imageHeight, numberOfLikes: awsPost._numberOfLikes, numberOfComments: awsPost._numberOfComments, user: user)
                    self.post = post
                    self.tableView.reloadData()
                    if let profilePicUrl = post.user?.profilePicUrl {
                        PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                    }
                    if let imageUrl = post.imageUrl {
                        PRFYS3Manager.defaultS3Manager().downloadImageS3(imageUrl, imageType: .postPic)
                    }
                    if let postId = post.postId {
                        self.getLike(postId)
                    }
                }
            })
            return nil
        })
    }
    
    fileprivate func removePost(_ postId: String, imageKey: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().removePostDynamoDB(postId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("removePost error: \(error)")
                } else {
                    PRFYS3Manager.defaultS3Manager().removeImageS3(imageKey)
                    // Notifiy obervers.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: DeletePostNotificationKey), object: self, userInfo: ["postId": postId])
                    self.performSegue(withIdentifier: "segueUnwindToProfileVc", sender: self)
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
                    if task.result != nil {
                        self.post?.isLikedByCurrentUser = true
                        self.tableView.reloadVisibleRow(IndexPath(row: 4, section: 0))
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
}

extension PostDetailsTableViewController {
    
    // MARK: NotificationCenterActions
    
    func updatePostNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let post = self.post, post.postId == postId else {
            return
        }
        post.caption = notification.userInfo?["caption"] as? String
        post.categoryName = notification.userInfo?["categoryName"] as? String
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
        }
    }
    
    func deletePostNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let post = self.post, post.postId == postId else {
            return
        }
        // Just unwind to ProfileVc in case deletion was on HomeVc.
        self.performSegue(withIdentifier: "segueUnwindToProfileVc", sender: self)
    }
    
    func createLikeNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let post = self.post, post.postId == postId else {
            return
        }
        post.numberOfLikes = NSNumber(value: post.numberOfLikesInt + 1)
        post.isLikedByCurrentUser = true
        self.tableView.reloadVisibleRow(IndexPath(row: 4, section: 0))
    }
    
    func deleteLikeNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let post = self.post, post.postId == postId else {
            return
        }
        post.numberOfLikes = NSNumber(value: post.numberOfLikesInt - 1)
        post.isLikedByCurrentUser = false
        self.tableView.reloadVisibleRow(IndexPath(row: 4, section: 0))
    }
    
    func createCommentNotification(_ notification: NSNotification) {
        guard let comment = notification.userInfo?["comment"] as? Comment else {
            return
        }
        guard let post = self.post, post.postId == comment.postId else {
            return
        }
        post.numberOfComments = NSNumber(value: post.numberOfCommentsInt + 1)
        self.tableView.reloadVisibleRow(IndexPath(row: 4, section: 0))
    }
    
    func deleteCommentNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let post = self.post, post.postId == postId else {
            return
        }
        post.numberOfComments = NSNumber(value: post.numberOfCommentsInt - 1)
        self.tableView.reloadVisibleRow(IndexPath(row: 4, section: 0))
    }
    
    func downloadImageNotification(_ notification: NSNotification) {
        guard let imageKey = notification.userInfo?["imageKey"] as? String, let imageType = notification.userInfo?["imageType"] as? ImageType, let imageData = notification.userInfo?["imageData"] as? Data else {
            return
        }
        switch imageType {
        case .userProfilePic:
            guard self.post?.user?.profilePicUrl == imageKey else {
                return
            }
            self.post?.user?.profilePic = UIImage(data: imageData)
            self.tableView.reloadVisibleRow(IndexPath(row: 0, section: 0))
        case .postPic:
            guard self.post?.imageUrl == imageKey else {
                return
            }
            self.post?.image = UIImage(data: imageData)
            self.tableView.reloadVisibleRow(IndexPath(row: 1, section: 0))
        }
    }
}

extension PostDetailsTableViewController: PostUserTableViewCellDelegate {
    
    func expandButtonTapped(_ cell: PostUserTableViewCell) {
        guard let post = self.post, let postId = post.postId, let postUserId = post.userId, let imageKey = post.imageUrl else {
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
                    self.removePost(postId, imageKey: imageKey)
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

extension PostDetailsTableViewController: PostButtonsTableViewCellDelegate {
    
    func likeButtonTapped(_ cell: PostButtonsTableViewCell) {
        guard let _ = self.tableView.indexPath(for: cell) else {
            return
        }
        guard let post = self.post, let postId = post.postId, let postUserId = post.userId else {
            return
        }
        if post.isLikedByCurrentUser {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: DeleteLikeNotificationKey), object: self, userInfo: ["postId": postId])
            self.removeLike(postId)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreateLikeNotificationKey), object: self, userInfo: ["postId": postId])
            self.createLike(postId, postUserId: postUserId)
        }
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
