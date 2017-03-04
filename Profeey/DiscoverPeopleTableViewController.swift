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
    
    @IBOutlet weak var nextButton: UIButton?
    
    var isOnboardingFlow: Bool = false
    
    fileprivate var users: [User] = []
    fileprivate var isSearchingUsers: Bool = false
    fileprivate var currentUserId: String?
    
    fileprivate var isLoadingFollowingIds: Bool = false
    fileprivate var followingIds: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isOnboardingFlow {
            self.navigationItem.hidesBackButton = true
            self.nextButton?.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        } else {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            // Remove Next button.
            self.navigationItem.rightBarButtonItem = nil
        }
        
        if let currentUserId = AWSIdentityManager.defaultIdentityManager().identityId {
            self.currentUserId = currentUserId
            self.isSearchingUsers = true
            self.scanUsers()
            self.isLoadingFollowingIds = true
            self.queryFollowingIds(currentUserId)
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
            let cell = sender as? DiscoverUserTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.user = self.users[indexPath.row].copyUser()
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
        cell.profilePicImageView.image = user.profilePicUrl != nil ? user.profilePic : UIImage(named: "ic_no_profile_pic_feed")
        cell.fullNameLabel.text = user.fullName
        cell.preferredUsernameLabel.text = user.preferredUsername
        cell.professionNameLabel.text = user.professionName
        cell.schoolNameLabel.text = user.schoolName
        cell.schoolStackView.isHidden = user.schoolName != nil ? false : true
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
        if cell is DiscoverUserTableViewCell {
            self.performSegue(withIdentifier: "segueToProfileVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isSearchingUsers {
            return 60.0
        }
        if self.users.count == 0 {
            return 60.0
        }
        return 104.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isSearchingUsers {
            return 60.0
        }
        if self.users.count == 0 {
            return 60.0
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: Helpers
    
    fileprivate func redirectToMain() {
        guard let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    // MARK: IBActions
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard self.isOnboardingFlow else {
            return
        }
        self.redirectToMain()
    }
    
    // MARK: AWS
    
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
                        let user = SchoolUser(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, schoolId: awsUser._schoolId, schoolName: awsUser._schoolName, numberOfRecommendations: awsUser._numberOfRecommendations)
                        if awsUser._userId != self.currentUserId! {
                            self.users.append(user)
                        }
                    }
                    self.tableView.reloadData()
                    for user in self.users {
                        if let profilePicUrl = user.profilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                        }
                    }
                }
            })
        })
    }
    
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
                        print("queryFollowingIds no relationship objects")
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
    
    // Followings are done in background.
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
    
    // MARK: NSNotifications
    
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
        (self.tableView.cellForRow(at: IndexPath(row: userIndex, section: 0)) as? DiscoverUserTableViewCell)?.setFollowingButton()
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
        (self.tableView.cellForRow(at: IndexPath(row: userIndex, section: 0)) as? DiscoverUserTableViewCell)?.setFollowButton()
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
                // Update data source and cells.
                self.users[userIndex].profilePic = UIImage(data: imageData)
                (self.tableView.cellForRow(at: IndexPath(row: userIndex, section: 0)) as? DiscoverUserTableViewCell)?.profilePicImageView.image = self.users[userIndex].profilePic
            }
        }
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
