//
//  SearchUsersTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol SearchUsersTableViewControllerDelegate {
    func usersTableViewWillBeginDragging()
}

class SearchUsersTableViewController: UITableViewController {
    
    var searchUsersTableViewControllerDelegate: SearchUsersTableViewControllerDelegate?
    
    fileprivate var users: [User] = []
    fileprivate var isSearchingUsers: Bool {
        return self.isSearchingPopularUsers
    }
    
    fileprivate var popularUsers: [User] = []
    fileprivate var isSearchingPopularUsers: Bool = false
    fileprivate var isShowingPopularUsers: Bool = true
    
    fileprivate var isLocationActive: Bool = false
    fileprivate var location: Location?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        
        self.isShowingPopularUsers = true
        self.isSearchingPopularUsers = true
        self.scanUsers()
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.recommendUserNotification(_:)), name: NSNotification.Name(RecommendUserNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.unrecommendUserNotification(_:)), name: NSNotification.Name(UnrecommendUserNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let cell = sender as? SearchUserTableViewCell,
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
            // TODO update text.
            return cell
        }
        if self.users.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchUser", for: indexPath) as! SearchUserTableViewCell
        let user = self.users[indexPath.row]
        cell.profilePicImageView.image = user.profilePicUrl != nil ? user.profilePic : UIImage(named: "ic_no_profile_pic_feed")
        cell.fullNameLabel.text = user.fullName
        cell.preferredUsernameLabel.text = user.preferredUsername
        cell.professionNameLabel.text = user.professionName
        cell.locationNameLabel.text = user.locationName
        cell.locationStackView.isHidden = user.locationName != nil ? false : true
        cell.numberOfRecommendationsLabel.text = user.numberOfRecommendationsInt.numberToString()
        cell.numberOfRecommendationsStackView.isHidden = user.numberOfRecommendationsInt > 0 ? false : true
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
        if cell is SearchUserTableViewCell {
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchTableSectionHeader") as? SearchTableSectionHeader
        var titleText = self.isShowingPopularUsers ? "POPULAR" : "BEST MATCHES"
        if self.isLocationActive, let locationName = self.location?.locationName {
            titleText = titleText + " in \(locationName)"
        }
        header?.titleLabel.text = titleText
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchUsersTableViewControllerDelegate?.usersTableViewWillBeginDragging()
    }
    
    // MARK: Helpers
    
    fileprivate func filterUsers(_ namePrefix: String) {
        let regularUsers = self.popularUsers.filter({
            (user: User) in
            if let searchFirstName = user.firstName?.lowercased(), searchFirstName.hasPrefix(namePrefix.lowercased()) {
                return true
            } else if let searchLastName = user.lastName?.lowercased(), searchLastName.hasPrefix(namePrefix.lowercased()) {
                return true
            } else if let searchPreferredUsername = user.preferredUsername?.lowercased(), searchPreferredUsername.hasPrefix(namePrefix.lowercased()) {
                return true
            } else {
                return false
            }
        })
        self.users = self.sortUsers(regularUsers)
        self.tableView.reloadData()
    }
    
    fileprivate func sortUsers(_ users: [User]) -> [User] {
        return users.sorted(by: {
            (user1, user2) in
            return user1.numberOfRecommendationsInt > user2.numberOfRecommendationsInt
        })
    }
    
    // MARK: AWS
    
    fileprivate func scanUsers() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingPopularUsers = false
                if let error = error {
                    print("scanUsers error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsUsers = response?.items as? [AWSUser] else {
                        self.tableView.reloadData()
                        return
                    }
                    self.popularUsers = []
                    for awsUser in awsUsers {
                        let user = LocationUser(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationId: awsUser._locationId, locationName: awsUser._locationName, numberOfRecommendations: awsUser._numberOfRecommendations)
                        self.popularUsers.append(user)
                    }
                    self.popularUsers = self.sortUsers(self.popularUsers)
                    self.users = self.popularUsers
                    self.tableView.reloadData()
                    
                    for user in self.popularUsers {
                        if let profilePicUrl = user.profilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func queryLocationUsers(_ locationId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryLocationUsers(locationId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingPopularUsers = false
                if let error = error {
                    print("queryLocationUsers error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsUsers = response?.items as? [AWSUser] else {
                        self.tableView.reloadData()
                        return
                    }
                    self.popularUsers = []
                    for awsUser in awsUsers {
                        let user = LocationUser(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationId: awsUser._locationId, locationName: awsUser._locationName, numberOfRecommendations: awsUser._numberOfRecommendations)
                        self.popularUsers.append(user)
                    }
                    self.popularUsers = self.sortUsers(self.popularUsers)
                    self.users = self.popularUsers
                    self.tableView.reloadData()
                    
                    for user in self.popularUsers {
                        if let profilePicUrl = user.profilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                        }
                    }
                }
            })
        })
    }
}

extension SearchUsersTableViewController {
    
    // MARK: NSNotifications
    
    func recommendUserNotification(_ notification: NSNotification) {
        guard let recommendingId = notification.userInfo?["recommendingId"] as? String else {
            return
        }
        guard let user = self.popularUsers.first(where: { $0.userId == recommendingId }) else {
            return
        }
        if let numberOfRecommendations = user.numberOfRecommendations {
            user.numberOfRecommendations = NSNumber(value: numberOfRecommendations.intValue + 1)
        } else {
            user.numberOfRecommendations = NSNumber(value: 1)
        }
        self.popularUsers = self.sortUsers(self.popularUsers)
        // Sort visible.
        self.users = self.sortUsers(self.users)
        self.tableView.reloadData()
    }
    
    func unrecommendUserNotification(_ notification: NSNotification) {
        guard let recommendingId = notification.userInfo?["recommendingId"] as? String else {
            return
        }
        guard let user = self.popularUsers.first(where: { $0.userId == recommendingId }) else {
            return
        }
        if let numberOfRecommendations = user.numberOfRecommendations, numberOfRecommendations.intValue > 0 {
            user.numberOfRecommendations = NSNumber(value: numberOfRecommendations.intValue - 1)
        } else {
            user.numberOfRecommendations = NSNumber(value: 0)
        }
        self.popularUsers = self.sortUsers(self.popularUsers)
        // Sort visible.
        self.users = self.sortUsers(self.users)
        self.tableView.reloadData()
    }
    
    func downloadImageNotification(_ notification: NSNotification) {
        guard let imageKey = notification.userInfo?["imageKey"] as? String, let imageType = notification.userInfo?["imageType"] as? ImageType, let imageData = notification.userInfo?["imageData"] as? Data else {
            return
        }
        guard imageType == .userProfilePic else {
            return
        }
        guard let user = self.popularUsers.first(where: { $0.profilePicUrl == imageKey }) else {
            return
        }
        user.profilePic = UIImage(data: imageData)
        
        // Update only visible (users).
        guard let userIndex = self.users.index(where: { $0.profilePicUrl == imageKey }) else {
            return
        }
        guard let indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows, indexPathsForVisibleRows.contains(where: { $0.row == userIndex }) else {
            return
        }
        UIView.performWithoutAnimation {
            self.tableView.reloadRows(at: [IndexPath(row: userIndex, section: 0)], with: UITableViewRowAnimation.none)
        }
    }
}

extension SearchUsersTableViewController: SearchUsersDelegate {
    
    func addLocation(_ location: Location) {
        guard let locationId = location.locationId else {
            return
        }
        self.location = location
        self.isLocationActive = true
        // Clear old.
        self.users = []
        self.isSearchingPopularUsers = true
        self.tableView.reloadData()
        self.queryLocationUsers(locationId)
    }
    
    func removeLocation() {
        self.location = nil
        self.isLocationActive = false
        // Clear old.
        self.users = []
        self.isSearchingPopularUsers = true
        self.tableView.reloadData()
        self.scanUsers()
    }
    
    func searchBarTextChanged(_ searchText: String) {
        let name = searchText.trimm()
        if name.isEmpty {
            self.isShowingPopularUsers = true
            self.users = self.popularUsers
            self.tableView.reloadData()
        } else {
            self.isShowingPopularUsers = false
            self.filterUsers(name)
        }
    }
    
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
}
