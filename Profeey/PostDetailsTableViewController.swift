//
//  PostDetailsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol PostDetailsTableViewControllerDelegate: class {
    func scrollViewWillBeginDecelerating()
    func commentButtonTapped()
}

class PostDetailsTableViewController: UITableViewController {
    
    @IBOutlet var loadingTableFooterView: UIView!
    
    // If comming from NotificationVc, we have to download the post, otherwise it's already set.
    var shouldDownloadPost: Bool = false
    // If comming from NotificationVc.
    var notificationPostId: String?
    // If comming from ProfileVc or UserCategoriesVc (copied).
    var post: Post?
    
    weak var postDetailsTableViewControllerDelegate: PostDetailsTableViewControllerDelegate?
    fileprivate var isLoadingPost: Bool = false
    fileprivate var activityIndicatorView: UIActivityIndicatorView?
    
    // Comments.
    fileprivate var comments: [Comment] = []
    fileprivate var isLoadingComments: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    fileprivate var noNetworkConnection: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        self.tableView.register(UINib(nibName: "CommentsTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "commentsTableSectionHeader")
        
        if self.shouldDownloadPost, let notificationPostId = self.notificationPostId {
            // Downlod the post.
            self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            self.tableView.backgroundView = self.activityIndicatorView
            self.activityIndicatorView?.startAnimating()
            self.isLoadingPost = true
            self.isLoadingComments = true
            self.getPost(notificationPostId)
        } else if let postId = self.post?.postId {
            // Just check if currentUser liked this post.
            self.getLike(postId)
            // Query comments.
            if let postId = self.post?.postId {
                self.isLoadingComments = true
                self.tableView.tableFooterView = self.loadingTableFooterView
                self.queryCommentsDateSorted(postId, startFromBeginning: true)
            }
        }
        
        // Add observers.
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
        if let destinationViewController = segue.destination as? ProfileTableViewController {
            if let cell = sender as? CommentTableViewCell,
                let indexPath = self.tableView.indexPath(for: cell) {
                destinationViewController.user = self.comments[indexPath.row].user?.copyUser()
            } else {
               destinationViewController.user = self.post?.user?.copyUser()
            }
        }
        if let destinationViewController = segue.destination as? UsersTableViewController {
            destinationViewController.usersType = UsersType.likers
            destinationViewController.postId = self.post?.postId
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController =  navigationController.childViewControllers[0] as? EditPostTableViewController {
            childViewController.editPost = self.post?.copyEditPost()
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController =  navigationController.childViewControllers[0] as? ReportTableViewController {
            if let cell = sender as? CommentTableViewCell, let indexPath = self.tableView.indexPath(for: cell) {
                childViewController.userId = self.comments[indexPath.row].userId
                childViewController.reportType = ReportType.user
            } else {
                childViewController.userId = self.post?.userId
                childViewController.postId = self.post?.postId
                childViewController.reportType = ReportType.post
            }
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.shouldDownloadPost, self.isLoadingPost {
            return 0
        }
        // Reported post.
        if let post = self.post, post.isReportedByCurrentUser {
            return 1
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Reported post.
        if let post = self.post, post.isReportedByCurrentUser {
            return 1
        }
        if section == 0 {
            return 5
        }
        if !self.isLoadingComments && self.comments.count == 0 {
            return 1
        }
        return self.comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reported post.
        if let post = self.post, post.isReportedByCurrentUser {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostReport", for: indexPath) as! PostReportTableViewCell
            return cell
        }
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostUser", for: indexPath) as! PostUserTableViewCell
                let user = self.post?.user
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostCaption", for: indexPath) as! PostCaptionTableViewCell
                cell.captionLabel.text = self.post?.caption
                cell.untruncate()
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostCategoryCreated", for: indexPath) as! PostCategoryCreatedTableViewCell
                cell.categoryNameCreatedLabel.text = [self.post?.categoryName, self.post?.createdString].flatMap({$0}).joined(separator: " · ")
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
        if !self.isLoadingComments && self.comments.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
            cell.emptyMessageLabel.text = "No comments yet."
            return cell
        }
        let comment = self.comments[indexPath.row]
        let commentUser = comment.user
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellComment", for: indexPath) as! CommentTableViewCell
        cell.profilePicImageView.image = commentUser?.profilePicUrl != nil ? commentUser?.profilePic : UIImage(named: "ic_no_profile_pic_feed")
        cell.preferredUsernameCreatedLabel.text = [commentUser?.preferredUsername, comment.createdString].flatMap({$0}).joined(separator: " · ")
        cell.commentTextLabel.text = comment.commentText
        comment.isExpandedCommentText ? cell.untruncate() : cell.truncate()
        cell.commentTableViewCellDelegate = self
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is PostUserTableViewCell {
            self.performSegue(withIdentifier: "segueToProfileVc", sender: indexPath)
        }
        if cell is PostCaptionTableViewCell {
            self.post?.isExpandedCaption = true
            (self.tableView.cellForRow(at: indexPath) as? PostCaptionTableViewCell)?.untruncate()
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        // Load next comments and reset tableFooterView.
        guard indexPath.section == 1 && indexPath.row == self.comments.count - 1 && !self.isLoadingComments && self.lastEvaluatedKey != nil else {
            return
        }
        guard let postId = self.post?.postId else {
            return
        }
        guard !self.noNetworkConnection else {
            return
        }
        self.isLoadingComments = true
        self.tableView.tableFooterView = self.loadingTableFooterView
        self.queryCommentsDateSorted(postId, startFromBeginning: false)
        
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Reported post.
        if let post = self.post, post.isReportedByCurrentUser {
            return 200.0
        }
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                return 60.0
            case 1:
                return 400.0
            case 2:
                return 30.0
            case 3:
                return 26.0
            case 4:
                return 50.0
            default:
                return 0
            }
        }
        if self.comments.count == 0 {
            return 64.0
        }
        return 87.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Reported post.
        if let post = self.post, post.isReportedByCurrentUser {
            return 200.0
        }
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                return 60.0
            case 1:
                return UITableViewAutomaticDimension
            case 2:
                return UITableViewAutomaticDimension
            case 3:
                return 26.0
            case 4:
                return 50.0
            default:
                return 0
            }
        }
        if self.comments.count == 0 {
            return 64.0
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        if (self.isLoadingComments) || (!self.isLoadingComments && self.comments.count == 0) {
            return UIView()
        }
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "commentsTableSectionHeader") as? CommentsTableSectionHeader
        header?.titleLabel.text = "Comments"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        if (self.isLoadingComments) || (!self.isLoadingComments && self.comments.count == 0) {
            return 1.0
        }
        return 32.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        return 12.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 {
            // Handle to dragging down.
            self.postDetailsTableViewControllerDelegate?.scrollViewWillBeginDecelerating()
        }
    }
    
    // MARK: IBActions
    
//    @IBAction func refreshControlChanged(_ sender: AnyObject) {
//        guard !self.isLoadingComments else {
//            self.refreshControl?.endRefreshing()
//            return
//        }
//        guard let postId = self.postId else {
//            self.refreshControl?.endRefreshing()
//            return
//        }
//        self.isLoadingComments = true
//        self.queryCommentsDateSorted(postId, startFromBeginning: true)
//    }
    
    // MARK: Helpers
    
    fileprivate func commentMoreButtonTapped(_ cell: CommentTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        guard let userId = self.comments[indexPath.row].userId, let commentId = self.comments[indexPath.row].commentId , let postId = self.comments[indexPath.row].postId else {
            return
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        if userId == AWSIdentityManager.defaultIdentityManager().identityId {
            // Delete.
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {
                (alert: UIAlertAction) in
                let alertController = UIAlertController(title: "Delete Comment?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                let deleteConfirmAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {
                    (alert: UIAlertAction) in
                    // In background
                    self.removeComment(commentId)
                    // Notify observers.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: DeleteCommentNotificationKey), object: self, userInfo: ["commentId": commentId, "postId": postId])
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
        // Cancel.
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func getPost(_ postId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getPostDynamoDB(postId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    print("getPost error: \(task.error!)")
                    self.isLoadingPost = false
                    self.isLoadingComments = false
                    self.refreshControl?.endRefreshing()
                    self.tableView.tableFooterView = UIView()
                    self.tableView.reloadData()
                    if (task.error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    return
                }
                if let awsPost = task.result as? AWSPost {
                    let user = User(userId: awsPost._userId, firstName: awsPost._firstName, lastName: awsPost._lastName, preferredUsername: awsPost._preferredUsername, professionName: awsPost._professionName, profilePicUrl: awsPost._profilePicUrl)
                    let post = Post(userId: awsPost._userId, postId: awsPost._postId, created: awsPost._created, caption: awsPost._caption, categoryName: awsPost._categoryName, imageUrl: awsPost._imageUrl, imageWidth: awsPost._imageWidth, imageHeight: awsPost._imageHeight, numberOfLikes: awsPost._numberOfLikes, numberOfComments: awsPost._numberOfComments, user: user)
                    self.post = post
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingPost = false
                self.refreshControl?.endRefreshing()
                self.noNetworkConnection = false
                self.tableView.tableFooterView = UIView()
                
                // Reload tableView.
                self.tableView.reloadData()
                
                // Load other data.
                if let awsPost = task.result as? AWSPost {
                    if let profilePicUrl = awsPost._profilePicUrl {
                        PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                    }
                    if let imageUrl = awsPost._imageUrl {
                        PRFYS3Manager.defaultS3Manager().downloadImageS3(imageUrl, imageType: .postPic)
                    }
                    if let postId = awsPost._postId {
                        // Get like.
                        self.getLike(postId)
                        // Query comments.
                        self.isLoadingComments = true
                        self.tableView.tableFooterView = self.loadingTableFooterView
                        self.queryCommentsDateSorted(postId, startFromBeginning: true)
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
                        // Update data source and cells.
                        self.post?.isLikedByCurrentUser = true
                        (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? PostButtonsTableViewCell)?.setSelectedLikeButton()
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
    
    fileprivate func queryCommentsDateSorted(_ postId: String, startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryCommentsDateSortedDynamoDB(postId, lastEvaluatedKey: self.lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryCommentsDateSorted error: \(error!)")
                    self.isLoadingComments = false
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
                    self.comments = []
                }
                var numberOfNewComments = 0
                if let awsComments = response?.items as? [AWSComment] {
                    for awsComment in awsComments {
                        let user = User(userId: awsComment._userId, firstName: awsComment._firstName, lastName: awsComment._lastName, preferredUsername: awsComment._preferredUsername, professionName: awsComment._professionName, profilePicUrl: awsComment._profilePicUrl)
                        let comment = Comment(userId: awsComment._userId, commentId: awsComment._commentId, created: awsComment._created, commentText: awsComment._commentText, postId: awsComment._postId, postUserId: awsComment._postUserId, user: user)
                        self.comments.append(comment)
                        numberOfNewComments += 1
                    }
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingComments = false
                self.refreshControl?.endRefreshing()
                self.noNetworkConnection = false
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                self.tableView.tableFooterView = UIView()
                
                // Reload tableView.
                if startFromBeginning || numberOfNewComments > 0 {
                    self.tableView.reloadData()
                }
                
                // Load profilePics.
                if let awsComments = response?.items as? [AWSComment] {
                    for awsComment in awsComments {
                        if let profilePicUrl = awsComment._profilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                        }
                    }
                }
            })
        })
    }
    
    // In background
    fileprivate func removeComment(_ commentId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeCommentDynamoDB(commentId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("removeComment error: \(error)")
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
        // Update data source and cells.
        post.caption = notification.userInfo?["caption"] as? String
        post.categoryName = notification.userInfo?["categoryName"] as? String
        (self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? PostCaptionTableViewCell)?.captionLabel.text = post.caption
        (self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? PostCategoryCreatedTableViewCell)?.categoryNameCreatedLabel.text = [post.categoryName, post.createdString].flatMap({$0}).joined(separator: " · ")
        UIView.performWithoutAnimation {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
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
        // Update data source and cells.
        post.numberOfLikes = NSNumber(value: post.numberOfLikesInt + 1)
        post.isLikedByCurrentUser = true
        (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? PostButtonsTableViewCell)?.numberOfLikesButton.isHidden = (post.numberOfLikesString != nil) ? false : true
        (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? PostButtonsTableViewCell)?.numberOfLikesButton.setTitle(post.numberOfLikesString, for: UIControlState())
        (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? PostButtonsTableViewCell)?.setSelectedLikeButton()
    }
    
    func deleteLikeNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let post = self.post, post.postId == postId else {
            return
        }
        // Update data source and cells.
        post.numberOfLikes = NSNumber(value: post.numberOfLikesInt - 1)
        post.isLikedByCurrentUser = false
        (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? PostButtonsTableViewCell)?.numberOfLikesButton.isHidden = (post.numberOfLikesString != nil) ? false : true
        (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? PostButtonsTableViewCell)?.numberOfLikesButton.setTitle(post.numberOfLikesString, for: UIControlState())
        (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? PostButtonsTableViewCell)?.setUnselectedLikeButton()
    }
    
    func createCommentNotification(_ notification: NSNotification) {
        guard let comment = notification.userInfo?["comment"] as? Comment else {
            return
        }
        guard let post = self.post, post.postId == comment.postId else {
            return
        }
        // Update data source and cells.
        post.numberOfComments = NSNumber(value: post.numberOfCommentsInt + 1)
        (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? PostButtonsTableViewCell)?.numberOfCommentsButton.isHidden = (post.numberOfCommentsString != nil) ? false : true
        (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? PostButtonsTableViewCell)?.numberOfCommentsButton.setTitle(post.numberOfCommentsString, for: UIControlState())
        // Update comments.
        self.comments.insert(comment, at: self.comments.count)
        if self.comments.count == 1 {
            self.tableView.reloadData()
        } else {
            self.tableView.insertRows(at: [IndexPath(row: self.comments.count - 1, section: 1)], with: UITableViewRowAnimation.automatic)
        }
        self.tableView.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 1), at: UITableViewScrollPosition.bottom, animated: false)
    }
    
    func deleteCommentNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String, let commentId = notification.userInfo?["commentId"] as? String else {
            return
        }
        guard let post = self.post, post.postId == postId else {
            return
        }
        guard let commentIndex = self.comments.index(where: { $0.commentId == commentId }) else {
            return
        }
        // Update data source and cells.
        post.numberOfComments = NSNumber(value: post.numberOfCommentsInt - 1)
        (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? PostButtonsTableViewCell)?.numberOfCommentsButton.isHidden = (post.numberOfCommentsString != nil) ? false : true
        (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? PostButtonsTableViewCell)?.numberOfCommentsButton.setTitle(post.numberOfCommentsString, for: UIControlState())
        // Update comments.
        self.comments.remove(at: commentIndex)
        if self.comments.count == 0 {
            self.tableView.reloadData()
        } else {
            self.tableView.deleteRows(at: [IndexPath(row: commentIndex, section: 1)], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func downloadImageNotification(_ notification: NSNotification) {
        guard let imageKey = notification.userInfo?["imageKey"] as? String, let imageType = notification.userInfo?["imageType"] as? ImageType, let imageData = notification.userInfo?["imageData"] as? Data else {
            return
        }
        switch imageType {
        case .userProfilePic:
            // Update post userProfilePic
            if self.post?.user?.profilePicUrl == imageKey {
                self.post?.user?.profilePic = UIImage(data: imageData)
                (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PostUserTableViewCell)?.profilePicImageView.image = self.post?.user?.profilePic
            }
            // Update comments userProfilePics
            for comments in self.comments.filter( { $0.user?.profilePicUrl == imageKey } ) {
                if let commentIndex = self.comments.index(of: comments) {
                    // Update user profilePic.
                    self.comments[commentIndex].user?.profilePic = UIImage(data: imageData)
                    // Update cell profilePicImageView.
                    (self.tableView.cellForRow(at: IndexPath(row: commentIndex, section: 1)) as? CommentTableViewCell)?.profilePicImageView.image = self.comments[commentIndex].user?.profilePic
                }
            }
        case .postPic:
            guard self.post?.imageUrl == imageKey else {
                return
            }
            self.post?.image = UIImage(data: imageData)
            (self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PostImageTableViewCell)?.postImageView.image = self.post?.image
        }
    }
    
    func createReportNotification(_ notification: NSNotification) {
        if let postId = notification.userInfo?["postId"] as? String {
            // It's a post report.
            guard let post = self.post, post.postId == postId else {
                return
            }
            post.isReportedByCurrentUser = true
            self.tableView.reloadData()
        } else {
            // It's a comment (user) report.
            // Do nothing for now with UI.
        }
    }
}

extension PostDetailsTableViewController: PostUserTableViewCellDelegate {
    
    func expandButtonTapped(_ cell: PostUserTableViewCell) {
        guard let post = self.post, let postId = post.postId, let postUserId = post.userId, let imageKey = post.imageUrl else {
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
                    self.removePost(postId, imageKey: imageKey)
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
        self.postDetailsTableViewControllerDelegate?.commentButtonTapped()
    }
    
    func numberOfLikesButtonTapped(_ cell: PostButtonsTableViewCell) {
        self.performSegue(withIdentifier: "segueToUsersVc", sender: cell)
    }
    
    func numberOfCommentsButtonTapped(_ cell: PostButtonsTableViewCell) {
        if self.comments.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: UITableViewScrollPosition.top, animated: true)
        }
    }
}

extension PostDetailsTableViewController: CommentTableViewCellDelegate {
    
    func userTapped(_ cell: CommentTableViewCell) {
        self.performSegue(withIdentifier: "segueToProfileVc", sender: cell)
    }
    
    func commentTextLabelTapped(_ cell: CommentTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        if !self.comments[indexPath.row].isExpandedCommentText {
            self.comments[indexPath.row].isExpandedCommentText = true
            cell.untruncate()
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
    
    func moreButtonTapped(_ cell: CommentTableViewCell) {
        self.commentMoreButtonTapped(cell)
    }
}

extension PostDetailsTableViewController: PostDetailsViewControllerDelegate {
    
    func toggleTableViewContentOffsetY(_ offsetY: CGFloat) {
        // TODO
    }
}
