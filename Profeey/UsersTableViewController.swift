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
    
    @IBOutlet var loadingTableFooterView: UIView!
    
    var usersType: UsersType?
    // In case of likes.
    var postId: String?
    // In case of followers/following.
    var userId: String?
    
    fileprivate var users: [User] = []
    fileprivate var isLoadingUsers: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    fileprivate var noNetworkConnection: Bool = false
    
    fileprivate var isLoadingFollowingIds: Bool = false
    fileprivate var followingIds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Query ids.
        if let currentUserId = AWSIdentityManager.defaultIdentityManager().identityId {
            self.isLoadingFollowingIds = true
            self.queryFollowingIds(currentUserId)
        }
        
        // Query users.
        if let usersType = self.usersType {
            switch usersType {
            case .likers:
                self.navigationItem.title = "Likes"
                if let postId = self.postId {
                    // Query.
                    self.isLoadingUsers = true
                    self.tableView.tableFooterView = self.loadingTableFooterView
                    self.queryLikes(postId, startFromBeginning: true)
                }
            case .followers:
                if let followingId = self.userId {
                    // Query.
                    self.isLoadingUsers = true
                    self.tableView.tableFooterView = self.loadingTableFooterView
                    self.queryFollowers(followingId, startFromBeginning: true)
                }
            case .following:
                if let userId = self.userId {
                    // Query.
                    self.isLoadingUsers = true
                    self.tableView.tableFooterView = self.loadingTableFooterView
                    self.queryFollowing(userId, startFromBeginning: true)
                }
            }
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.followUserNotification(_:)), name: NSNotification.Name(FollowUserNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.unfollowUserNotification(_:)), name: NSNotification.Name(UnfollowUserNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let cell = sender as? UserTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.user = self.users[indexPath.row].copyUser()
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.isLoadingUsers && self.users.count == 0 {
            return 1
        }
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !self.isLoadingUsers && self.users.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
            if let usersType = self.usersType {
                switch usersType {
                case .followers:
                    cell.emptyMessageLabel.text = "No followers yet."
                case .following:
                    cell.emptyMessageLabel.text = "No followings yet."
                case .likers:
                    cell.emptyMessageLabel.text = "No likes yet."
                }
            }
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
        guard indexPath.row == self.users.count - 1 && !self.isLoadingUsers && self.lastEvaluatedKey != nil else {
            return
        }
        guard !self.noNetworkConnection else {
            return
        }
        guard let usersType = self.usersType else {
            return
        }
        switch usersType {
        case .likers:
            guard let postId = self.postId else {
                return
            }
            self.isLoadingUsers = true
            self.queryLikes(postId, startFromBeginning: true)
        case .followers:
            guard let followingId = self.userId else {
                return
            }
            self.isLoadingUsers = true
            self.queryFollowers(followingId, startFromBeginning: true)
        case .following:
            guard let userId = self.userId else {
                return
            }
            self.isLoadingUsers = true
            self.queryFollowing(userId, startFromBeginning: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.users.count == 0 {
            return 64.0
        }
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.users.count == 0 {
            return 64.0
        }
        return 64.0
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard !self.isLoadingUsers && !self.isLoadingFollowingIds else {
            self.refreshControl?.endRefreshing()
            return
        }
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
            self.isLoadingUsers = true
            self.queryLikes(postId, startFromBeginning: true)
        case .followers:
            guard let followingId = self.userId else {
                self.refreshControl?.endRefreshing()
                return
            }
            self.isLoadingUsers = true
            self.queryFollowers(followingId, startFromBeginning: true)
        case .following:
            guard let userId = self.userId else {
                self.refreshControl?.endRefreshing()
                return
            }
            self.isLoadingUsers = true
            self.queryFollowing(userId, startFromBeginning: true)
        }
        // Refresh ids as well.
        if let currentUserId = AWSIdentityManager.defaultIdentityManager().identityId {
            self.isLoadingFollowingIds = true
            self.queryFollowingIds(currentUserId)
        }
    }
    
    // MARK: AWS
    
    fileprivate func queryLikes(_ postId: String, startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryLikesDynamoDB(postId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryLikes error: \(error!)")
                    self.isLoadingUsers = false
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
                    self.users = []
                }
                var numberOfNewUsers = 0
                if let awsLikes = response?.items as? [AWSLike] {
                    for awsLike in awsLikes {
                        let user = User(userId: awsLike._userId, firstName: awsLike._firstName, lastName: awsLike._lastName, preferredUsername: awsLike._preferredUsername, professionName: awsLike._professionName, profilePicUrl: awsLike._profilePicUrl)
                        self.users.append(user)
                        numberOfNewUsers += 1
                    }
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingUsers = false
                self.refreshControl?.endRefreshing()
                self.noNetworkConnection = false
                self.tableView.reloadData()
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                self.tableView.tableFooterView = UIView()
                
                // Reload tableView with downloaded users.
                if startFromBeginning || numberOfNewUsers > 0 {
                    self.tableView.reloadData()
                }
                
                // Load profilePics.
                if let awsLikes = response?.items as? [AWSLike] {
                    for awsLike in awsLikes {
                        if let profilePicUrl = awsLike._profilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func queryFollowers(_ followingId: String, startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryFollowersDynamoDB(followingId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryFollowers error: \(error!)")
                    self.isLoadingUsers = false
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
                    self.users = []
                }
                var numberOfNewUsers = 0
                if let awsRelationships = response?.items as? [AWSRelationship] {
                    for awsRelationship in awsRelationships {
                        let user = User(userId: awsRelationship._userId, firstName: awsRelationship._firstName, lastName: awsRelationship._lastName, preferredUsername: awsRelationship._preferredUsername, professionName: awsRelationship._professionName, profilePicUrl: awsRelationship._profilePicUrl)
                        self.users.append(user)
                        numberOfNewUsers += 1
                    }
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingUsers = false
                self.refreshControl?.endRefreshing()
                self.noNetworkConnection = false
                self.tableView.reloadData()
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                self.tableView.tableFooterView = UIView()
                
                // Reload tableView with downloaded users.
                if startFromBeginning || numberOfNewUsers > 0 {
                    self.tableView.reloadData()
                }
                
                // Load profilePics.
                if let awsRelationships = response?.items as? [AWSRelationship] {
                    for awsRelationship in awsRelationships {
                        if let profilePicUrl = awsRelationship._profilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                        }
                    }
                }
            })
        })
        
    }
    
    fileprivate func queryFollowing(_ userId: String, startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryFollowingDynamoDB(userId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryFollowing error: \(error!)")
                    self.isLoadingUsers = false
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
                    self.users = []
                }
                var numberOfNewUsers = 0
                if let awsRelationships = response?.items as? [AWSRelationship] {
                    for awsRelationship in awsRelationships {
                        let user = User(userId: awsRelationship._followingId, firstName: awsRelationship._followingFirstName, lastName: awsRelationship._followingLastName, preferredUsername: awsRelationship._followingPreferredUsername, professionName: awsRelationship._followingProfessionName, profilePicUrl: awsRelationship._followingProfilePicUrl)
                        self.users.append(user)
                        numberOfNewUsers += 1
                    }
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingUsers = false
                self.refreshControl?.endRefreshing()
                self.noNetworkConnection = false
                self.tableView.reloadData()
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                self.tableView.tableFooterView = UIView()
                
                // Reload tableView with downloaded users.
                if startFromBeginning || numberOfNewUsers > 0 {
                    self.tableView.reloadData()
                }
                
                // Load profilePics.
                if let awsRelationships = response?.items as? [AWSRelationship] {
                    for awsRelationship in awsRelationships {
                        if let profilePicUrl = awsRelationship._followingProfilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
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
}

extension UsersTableViewController {
    
    // MARK: NotificationCenterActions
    
    func followUserNotification(_ notification: NSNotification) {
        guard let followingId = notification.userInfo?["followingId"] as? String else {
            return
        }
        guard !self.followingIds.contains(followingId) else {
            return
        }
        guard let userIndex = self.users.index(where: { $0.userId == followingId }) else {
            return
        }
        self.followingIds.append(followingId)
        (self.tableView.cellForRow(at: IndexPath(row: userIndex, section: 0)) as? UserTableViewCell)?.setFollowingButton()
    }
    
    func unfollowUserNotification(_ notification: NSNotification) {
        guard let followingId = notification.userInfo?["followingId"] as? String else {
            return
        }
        guard let followingIdIndex = self.followingIds.index(of: followingId) else {
            return
        }
        guard let userIndex = self.users.index(where: { $0.userId == followingId }) else {
            return
        }
        self.followingIds.remove(at: followingIdIndex)
        (self.tableView.cellForRow(at: IndexPath(row: userIndex, section: 0)) as? UserTableViewCell)?.setFollowButton()
    }
    
    func downloadImageNotification(_ notification: NSNotification) {
        guard let imageKey = notification.userInfo?["imageKey"] as? String, let imageType = notification.userInfo?["imageType"] as? ImageType, let imageData = notification.userInfo?["imageData"] as? Data else {
            return
        }
        guard imageType == .userProfilePic else {
            return
        }
        for user in self.users.filter( { $0.profilePicUrl == imageKey } ) {
            if let userIndex = self.users.index(of: user) {
                self.users[userIndex].profilePic = UIImage(data: imageData)
                (self.tableView.cellForRow(at: IndexPath(row: userIndex, section: 0)) as? UserTableViewCell)?.profilePicImageView.image = self.users[userIndex].profilePic
            }
        }
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
