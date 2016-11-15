//
//  CommentsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol CommentsTableViewControllerDelegate {
    func scrollViewWillBeginDragging()
    func didSelectRow(_ indexPath: IndexPath)
}

class CommentsTableViewController: UITableViewController {
    
    var commentsTableViewControllerDelegate: CommentsTableViewControllerDelegate?
    fileprivate var comments: [Comment] = []
    fileprivate var isLoadingComments: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellComment", for: indexPath) as! CommentTableViewCell
        let comment = self.comments[indexPath.row]
        let user = comment.user
        cell.profilePicImageView.image = user?.profilePic
        cell.preferredUsernameLabel.text = user?.fullUsername
        cell.professionNameLabel.text = user?.professionName
        cell.commentLabel.text = comment.commentText
        cell.timeLabel.text = comment.creationDateString
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
            self.commentsTableViewControllerDelegate?.didSelectRow(indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingComments || self.comments.count == 0 {
            return 112.0
        }
        return 104.0
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
    
    // MARK: AWS
    
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

extension CommentsTableViewController: CommentsViewControllerDelegate {
    
    func isLoadingComments(_ isLoading: Bool) {
        self.isLoadingComments = isLoading
        self.tableView.reloadData()
    }
    
    func showComments(_ comments: [Comment]) {
        self.comments = comments
        self.tableView.reloadData()
        
        for (index, comment) in comments.enumerated() {
            if let profilePicUrl = comment.user?.profilePicUrl {
                let indexPath = IndexPath(row: index, section: 0)
                self.downloadImage(profilePicUrl, imageType: ImageType.userProfilePic, indexPath: indexPath)
            }
        }
    }
    
    func commentPosted(_ comment: Comment) {
        self.comments.append(comment)
        let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
    }
    
    func commentRemoved(_ indexPath: IndexPath) {
        self.comments.remove(at: indexPath.row)
        if self.comments.count == 0 {
            self.tableView.reloadData()
        } else {
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
}

extension CommentsTableViewController: CommentTableViewCellDelegate {
    
    func userTapped(_ cell: CommentTableViewCell) {
        self.performSegue(withIdentifier: "segueToProfileVc", sender: cell)
    }
}
