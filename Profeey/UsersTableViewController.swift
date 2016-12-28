//
//  UsersTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

enum UsersType {
    case likers
    case followers
    case following
}

class UsersTableViewController: UITableViewController {
    
    var usersType: UsersType?
    // In case of likes.
    var postId: String?
    // In case of followers/following.
    var userId: String?
    
    fileprivate var users: [User] = []
    fileprivate var isLoadingUsers: Bool = false
    
    fileprivate var isLoadingFollowingIds: Bool = false
    fileprivate var followingIds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.prepareForQueries()
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.followUserNotification(_:)), name: NSNotification.Name(FollowUserNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.unfollowUserNotification(_:)), name: NSNotification.Name(UnfollowUserNotificationKey), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let cell = sender as? UserTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.user = self.users[indexPath.row]
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingUsers {
            return 1
        }
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoadingUsers {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellLoading", for: indexPath) as! LoadingTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellUser", for: indexPath) as! UserTableViewCell
        let user = self.users[indexPath.row]
        cell.profilePicImageView.image = user.profilePicUrl != nil ? user.profilePic : UIImage(named: "ic_no_profile_pic_feed")
        cell.preferredUsernameLabel.text = user.preferredUsername
        cell.professionNameLabel.text = user.professionName
        if !self.isLoadingFollowingIds, let userId = user.userId {
            self.followingIds.contains(userId) ? cell.setFollowingButton() : cell.setFollowButton()
        }
        cell.userTableViewCellDelegate = self
        cell.followButton.isHidden = (user.userId == AWSIdentityManager.defaultIdentityManager().identityId) ? true : false
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is UserTableViewCell {
           self.performSegue(withIdentifier: "segueToProfileVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if !(cell is UserTableViewCell) {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingUsers {
            return 112.0
        }
        return 68.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingUsers {
            return 112.0
        }
        return 68.0
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        self.prepareForQueries()
    }
    
    // MARK: Helpers
    
    fileprivate func prepareForQueries() {
        guard let usersType = self.usersType else {
            self.refreshControl?.endRefreshing()
            return
        }
        switch usersType {
        case .likers:
            guard let postId = self.postId else {
                self.refreshControl?.endRefreshing()
                return
            }
            self.users = []
            self.isLoadingUsers = true
            self.queryPostLikes(postId)
        case .followers:
            guard let followingId = self.userId else {
                self.refreshControl?.endRefreshing()
                return
            }
            self.users = []
            self.isLoadingUsers = true
            self.queryFollowers(followingId)
        case .following:
            guard let userId = self.userId else {
                self.refreshControl?.endRefreshing()
                return
            }
            self.users = []
            self.isLoadingUsers = true
            self.queryFollowing(userId)
        }
        if let currentUserId = AWSIdentityManager.defaultIdentityManager().identityId {
            self.isLoadingFollowingIds = true
            self.queryFollowingIds(currentUserId)
        }
    }
    
    // MARK: AWS
    
    fileprivate func queryPostLikes(_ postId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryPostLikesDynamoDB(postId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingUsers = false
                self.refreshControl?.endRefreshing()
                if let error = error {
                    print("queryPostLikes error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsLikes = response?.items as? [AWSLike] else {
                        self.tableView.reloadData()
                        return
                    }
                    for awsLike in awsLikes {
                        let user = User(userId: awsLike._userId, firstName: awsLike._firstName, lastName: awsLike._lastName, preferredUsername: awsLike._preferredUsername, professionName: awsLike._professionName, profilePicUrl: awsLike._profilePicUrl)
                        self.users.append(user)
                    }
                    self.tableView.reloadData()
                    for (index, user) in self.users.enumerated() {
                        if let profilePicUrl = user.profilePicUrl {
                            let indexPath = IndexPath(row: index, section: 0)
                            self.downloadImage(profilePicUrl, imageType: .userProfilePic, indexPath: indexPath)
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func queryFollowers(_ followingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryFollowersDynamoDB(followingId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingUsers = false
                self.refreshControl?.endRefreshing()
                if let error = error {
                    print("queryFollowers error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsRelationships = response?.items as? [AWSRelationship] else {
                        self.tableView.reloadData()
                        return
                    }
                    for awsRelationship in awsRelationships {
                        let user = User(userId: awsRelationship._userId, firstName: awsRelationship._firstName, lastName: awsRelationship._lastName, preferredUsername: awsRelationship._preferredUsername, professionName: awsRelationship._professionName, profilePicUrl: awsRelationship._profilePicUrl)
                        self.users.append(user)
                    }
                    self.tableView.reloadData()
                    for (index, user) in self.users.enumerated() {
                        if let profilePicUrl = user.profilePicUrl {
                            let indexPath = IndexPath(row: index, section: 0)
                            self.downloadImage(profilePicUrl, imageType: .userProfilePic, indexPath: indexPath)
                        }
                    }
                }
            })
        })
        
    }
    
    fileprivate func queryFollowing(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryFollowingDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingUsers = false
                self.refreshControl?.endRefreshing()
                if let error = error {
                    print("queryFollowing error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsRelationships = response?.items as? [AWSRelationship] else {
                        self.tableView.reloadData()
                        return
                    }
                    for awsRelationship in awsRelationships {
                        let user = User(userId: awsRelationship._followingId, firstName: awsRelationship._followingFirstName, lastName: awsRelationship._followingLastName, preferredUsername: awsRelationship._followingPreferredUsername, professionName: awsRelationship._followingProfessionName, profilePicUrl: awsRelationship._followingProfilePicUrl)
                        self.users.append(user)
                    }
                    self.tableView.reloadData()
                    for (index, user) in self.users.enumerated() {
                        if let profilePicUrl = user.profilePicUrl {
                            let indexPath = IndexPath(row: index, section: 0)
                            self.downloadImage(profilePicUrl, imageType: .userProfilePic, indexPath: indexPath)
                        }
                    }
                }
            })
        })
    }
    
    // Only to check if user already follows some users.
    fileprivate func queryFollowingIds(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryFollowingIdsDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingFollowingIds = false
                if let error = error {
                    print("queryFollowingIds error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsRelationships = response?.items as? [AWSRelationship] else {
                        self.tableView.reloadData()
                        return
                    }
                    for awsRelationship in awsRelationships {
                        if let followingId = awsRelationship._followingId {
                            self.followingIds.append(followingId)
                        }
                    }
                    self.tableView.reloadData()
                }
            })
        })
    }
    
    // In background.
    fileprivate func followUser(_ followingId: String, followingFirstName: String?, followingLastName: String?, followingPreferredUsername: String?, followingProfessionName: String?, followingProfilePicUrl: String?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createRelationshipDynamoDB(followingId, followingFirstName: followingFirstName, followingLastName: followingLastName, followingPreferredUsername: followingPreferredUsername, followingProfessionName: followingProfessionName, followingProfilePicUrl: followingProfilePicUrl, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("followUser error: \(error)")
                }
            })
            return nil
        })
    }
//    fileprivate func followUser(_ followingId: String) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        PRFYDynamoDBManager.defaultDynamoDBManager().createRelationshipDynamoDB(followingId, completionHandler: {
//            (task: AWSTask) in
//            DispatchQueue.main.async(execute: {
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                if let error = task.error {
//                    print("followUser error: \(error)")
//                }
//            })
//            return nil
//        })
//    }
    
    // In background.
    fileprivate func unfollowUser(_ followingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeRelationshipDynamoDB(followingId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("unfollowUser error: \(error)")
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
                self.users[indexPath.row].profilePic = image
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
                            case .userProfilePic:
                                self.users[indexPath.row].profilePic = image
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

extension UsersTableViewController {
    
    // MARK: NotificationCenterActions
    
    func followUserNotification(_ notification: NSNotification) {
        guard let followingId = notification.userInfo?["followingId"] as? String else {
            return
        }
        guard let userIndex = self.users.index(where: { $0.userId == followingId }) else {
            return
        }
        guard !self.followingIds.contains(followingId) else {
            return
        }
        self.followingIds.append(followingId)
        self.tableView.reloadRows(at: [IndexPath(row: userIndex, section: 0)], with: UITableViewRowAnimation.none)
    }
    
    func unfollowUserNotification(_ notification: NSNotification) {
        guard let followingId = notification.userInfo?["followingId"] as? String else {
            return
        }
        guard let userIndex = self.users.index(where: { $0.userId == followingId }) else {
            return
        }
        guard let followingIdIndex = self.followingIds.index(of: followingId) else {
            return
        }
        self.followingIds.remove(at: followingIdIndex)
        self.tableView.reloadRows(at: [IndexPath(row: userIndex, section: 0)], with: UITableViewRowAnimation.none)
    }
}

extension UsersTableViewController: UserTableViewCellDelegate {
    
    func followButtonTapped(_ cell: UserTableViewCell) {
        guard !self.isLoadingFollowingIds, let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        guard let userId = self.users[indexPath.row].userId else {
            return
        }
        if self.followingIds.contains(userId) {
            // In background.
            self.unfollowUser(userId)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: UnfollowUserNotificationKey), object: self, userInfo: ["followingId": userId])
        } else {
            let followingUser = self.users[indexPath.row]
            // In background.
            self.followUser(userId, followingFirstName: followingUser.firstName, followingLastName: followingUser.lastName, followingPreferredUsername: followingUser.preferredUsername, followingProfessionName: followingUser.professionName, followingProfilePicUrl: followingUser.profilePicUrl)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: FollowUserNotificationKey), object: self, userInfo: ["followingId": userId])
        }
    }
}
