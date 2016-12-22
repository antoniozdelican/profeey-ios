//
//  DiscoverPeopleTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class DiscoverPeopleTableViewController: UITableViewController {
    
    var isWelcomeFlow: Bool = false
    
    fileprivate var users: [User] = []
    fileprivate var isSearchingUsers: Bool = false
    fileprivate var currentUserId: String?
    
    fileprivate var isLoadingFollowingIds: Bool = false
    fileprivate var followingIds: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if let currentUserId = AWSIdentityManager.defaultIdentityManager().identityId {
            self.currentUserId = currentUserId
            self.isSearchingUsers = true
            self.scanUsers()
            self.isLoadingFollowingIds = true
            self.queryFollowing(currentUserId)
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.followingUserNotification(_:)), name: NSNotification.Name(FollowingUserNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let cell = sender as? DiscoverUserTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.user = self.users[indexPath.row]
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchingUsers {
            return 1
        }
        if self.users.count == 0 {
            return 1
        }
        return self.users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isSearchingUsers {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        if self.users.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellDiscoverUser", for: indexPath) as! DiscoverUserTableViewCell
        let user = self.users[indexPath.row]
        cell.profilePicImageView.image = user.profilePic
        cell.fullNameLabel.text = user.fullName
        cell.preferredUsernameLabel.text = user.preferredUsername
        cell.professionNameLabel.text = user.professionName
        cell.locationNameLabel.text = user.locationName
        cell.locationStackView.isHidden = user.locationName != nil ? false : true
        cell.discoverUserTableViewCellDelegate = self
        if !self.isLoadingFollowingIds, let userId = user.userId {
            self.followingIds.contains(userId) ? cell.setFollowingButton() : cell.setFollowButton()
        }
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if cell is NoResultsTableViewCell {
            cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is DiscoverUserTableViewCell && !self.isWelcomeFlow {
            self.performSegue(withIdentifier: "segueToProfileVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isSearchingUsers {
            return 64.0
        }
        if self.users.count == 0 {
            return 64.0
        }
        return 104.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isSearchingUsers {
            return 64.0
        }
        if self.users.count == 0 {
            return 64.0
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: AWS
    
//    fileprivate func scanUsers() {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersDynamoDB({
//            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
//            DispatchQueue.main.async(execute: {
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                self.isSearchingPopularUsers = false
//                if let error = error {
//                    print("scanUsers error: \(error)")
//                    self.tableView.reloadData()
//                } else {
//                    guard let awsUsers = response?.items as? [AWSUser] else {
//                        self.tableView.reloadData()
//                        return
//                    }
//                    for awsUser in awsUsers {
//                        let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationName: awsUser._locationName, numberOfRecommendations: awsUser._numberOfRecommendations)
//                        if user.profilePicUrl == nil {
//                            user.profilePic = UIImage(named: "ic_no_profile_pic_feed")
//                        }
//                        self.popularUsers.append(user)
//                    }
//                    self.popularUsers = self.sortUsers(self.popularUsers)
//                    self.tableView.reloadData()
//                    
//                    for user in self.popularUsers {
//                        if let profilePicUrl = user.profilePicUrl {
//                            self.downloadProfilePic(profilePicUrl, isPopularUser: true)
//                        }
//                    }
//                }
//            })
//        })
//    }
    
    fileprivate func scanUsers() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingUsers = false
                if let error = error {
                    print("scanUsers error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsUsers = response?.items as? [AWSUser] else {
                        self.tableView.reloadData()
                        return
                    }
                    for awsUser in awsUsers {
                        let user = LocationUser(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationId: awsUser._locationId, locationName: awsUser._locationName, numberOfRecommendations: awsUser._numberOfRecommendations)
                        if awsUser._userId != self.currentUserId! {
                            self.users.append(user)
                        }
                    }
                    self.tableView.reloadData()
                    for (index, user) in self.users.enumerated() {
                        if let profilePicUrl = user.profilePicUrl {
                            let indexPath = IndexPath(row: index, section: 0)
                            self.downloadImage(profilePicUrl, imageType: ImageType.userProfilePic, indexPath: indexPath)
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
                self.isLoadingFollowingIds = false
                if let error = error {
                    print("queryFollowing error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsRelationships = response?.items as? [AWSRelationship] else {
                        print("queryFollowing no relationship objects")
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
                                self.users[indexPath.row].profilePic = image
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
    
    // Followings are done in background.
    fileprivate func followUser(_ followingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createRelationshipDynamoDB(followingId, completionHandler: {
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

extension DiscoverPeopleTableViewController {
    
    // MARK: NotificationCenterActions
    
    func followingUserNotification(_ notification: NSNotification) {
        guard let followingId = notification.userInfo?["followingId"] as? String else {
            return
        }
        guard let userIndex = self.users.index(where: { $0.userId == followingId }) else {
            return
        }
        if let followingIdIndex = self.followingIds.index(of: followingId) {
            self.followingIds.remove(at: followingIdIndex)
        } else {
            self.followingIds.append(followingId)
        }
        self.tableView.reloadRows(at: [IndexPath(row: userIndex, section: 0)], with: UITableViewRowAnimation.none)
    }
}

extension DiscoverPeopleTableViewController: DiscoverUserTableViewCellDelegate {
    
    func followButtonTapped(_ cell: DiscoverUserTableViewCell) {
        guard !self.isLoadingFollowingIds, let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        guard let userId = self.users[indexPath.row].userId else {
            return
        }
        if self.followingIds.contains(userId) {
            self.unfollowUser(userId)
        } else {
            self.followUser(userId)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FollowingUserNotificationKey), object: self, userInfo: ["followingId": userId])
    }
}
