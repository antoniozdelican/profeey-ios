//
//  CommentsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol CommentsTableViewControllerDelegate {
    func scrollViewWillBeginDragging()
}

class CommentsTableViewController: UITableViewController {
    
    var postId: String?
    var commentsTableViewControllerDelegate: CommentsTableViewControllerDelegate?
    fileprivate var comments: [Comment] = []
    fileprivate var isLoadingComments: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let postId = self.postId {
            self.isLoadingComments = true
            self.queryPostCommentsDateSorted(postId)
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.createCommentNotification(_:)), name: NSNotification.Name(CreateCommentNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteCommentNotification(_:)), name: NSNotification.Name(DeleteCommentNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let cell = sender as? CommentTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.user = self.comments[indexPath.row].user
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingComments {
            return 1
        }
        if self.comments.count == 0 {
            return 1
        }
        return self.comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoadingComments {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellLoading", for: indexPath) as! LoadingTableViewCell
            cell.activityIndicator?.startAnimating()
            return cell
        }
        if self.comments.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
            cell.emptyMessageLabel.text = "No comments yet"
            return cell
        }
        let comment = self.comments[indexPath.row]
        let user = comment.user
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellComment", for: indexPath) as! CommentTableViewCell
        cell.profilePicImageView.image = user?.profilePicUrl != nil ? user?.profilePic : UIImage(named: "ic_no_profile_pic_feed")
        cell.preferredUsernameLabel.text = user?.preferredUsername
        cell.professionNameLabel.text = user?.professionName
        cell.timeLabel.text = comment.createdString
        cell.commentTextLabel.text = comment.commentText
        comment.isExpandedCommentText ? cell.untruncate() : cell.truncate()
        cell.commentTableViewCellDelegate = self
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if !(cell is CommentTableViewCell) {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is CommentTableViewCell {
            self.commentCellTapped(cell as! CommentTableViewCell)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingComments || self.comments.count == 0 {
            return 112.0
        }
        return 87.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingComments || self.comments.count == 0 {
            return 112.0
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.commentsTableViewControllerDelegate?.scrollViewWillBeginDragging()
    }
    
    // MARK: Helpers
    
    fileprivate func commentCellTapped(_ cell: CommentTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        guard let userId = self.comments[indexPath.row].userId, let commentId = self.comments[indexPath.row].commentId , let postId = self.comments[indexPath.row].postId else {
                return
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        if userId == AWSIdentityManager.defaultIdentityManager().identityId {
            // DELETE
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
            // REPORT
            let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive, handler: nil)
            alertController.addAction(reportAction)
        }
        // CANCEL
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func queryPostCommentsDateSorted(_ postId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryPostCommentsDateSortedDynamoDB(postId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingComments = false
                if let error = error {
                    print("queryPostCommentsDateSorted error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsComments = response?.items as? [AWSComment] else {
                        self.tableView.reloadData()
                        return
                    }
                    for awsComment in awsComments {
                        let user = User(userId: awsComment._userId, firstName: awsComment._firstName, lastName: awsComment._lastName, preferredUsername: awsComment._preferredUsername, professionName: awsComment._professionName, profilePicUrl: awsComment._profilePicUrl)
                        let comment = Comment(userId: awsComment._userId, commentId: awsComment._commentId, created: awsComment._created, commentText: awsComment._commentText, postId: awsComment._postId, postUserId: awsComment._postUserId, user: user)
                        self.comments.append(comment)
                    }
                    self.tableView.reloadData()
                    for (index, comment) in self.comments.enumerated() {
                        if let profilePicUrl = comment.user?.profilePicUrl {
                            let indexPath = IndexPath(row: index, section: 0)
                            self.downloadImage(profilePicUrl, imageType: .userProfilePic, indexPath: indexPath)
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
            case .userProfilePic:
                self.comments[indexPath.row].user?.profilePic = image
                UIView.performWithoutAnimation {
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
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
                            case .userProfilePic:
                                self.comments[indexPath.row].user?.profilePic = image
                                UIView.performWithoutAnimation {
                                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                                }
                            default:
                                return
                            }
                        }
                    })
            })
        }
    }
}

extension CommentsTableViewController {
    
    // MARK: NotificationCenterActions
    
    func createCommentNotification(_ notification: NSNotification) {
        guard let comment = notification.userInfo?["comment"] as? Comment else {
            return
        }
        guard self.postId == comment.postId else {
            return
        }
        self.comments.insert(comment, at: self.comments.count)
        if self.comments.count == 1 {
            self.tableView.reloadData()
        } else {
            self.tableView.insertRows(at: [IndexPath(row: self.comments.count - 1, section: 0)], with: UITableViewRowAnimation.fade)
        }
        self.tableView.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
    }
    
    func deleteCommentNotification(_ notification: NSNotification) {
        guard let commentId = notification.userInfo?["commentId"] as? String else {
            return
        }
        guard let commentIndex = self.comments.index(where: { $0.commentId == commentId }) else {
            return
        }
        self.comments.remove(at: commentIndex)
        if self.comments.count == 0 {
            self.tableView.reloadData()
        } else {
            self.tableView.deleteRows(at: [IndexPath(row: commentIndex, section: 0)], with: UITableViewRowAnimation.fade)
        }
    }
    
}

extension CommentsTableViewController: CommentTableViewCellDelegate {
    
    func userTapped(_ cell: CommentTableViewCell) {
        self.performSegue(withIdentifier: "segueToProfileVc", sender: cell)
    }
    
    func commentTextLabelTapped(_ cell: CommentTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        if !self.comments[indexPath.row].isExpandedCommentText {
            self.comments[indexPath.row].isExpandedCommentText = true
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
        }
    }
}
