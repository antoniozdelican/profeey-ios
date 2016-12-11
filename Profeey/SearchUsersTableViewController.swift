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
    // Popular users are 10 (20) most popular that are loaded immidiately.
    // Regular users are the searched ones depending on searchBar text.
    fileprivate var popularUsers: [User] = []
    fileprivate var regularUsers: [User] = []
    fileprivate var isSearchingPopularUsers: Bool = false
    fileprivate var isSearchingRegularUsers: Bool = false
    fileprivate var isShowingPopularUsers: Bool = true
    
    fileprivate var isLocationActive: Bool = false
    fileprivate var locationName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        
        self.isShowingPopularUsers = true
        self.isSearchingPopularUsers = true
        self.getAllUsers(self.locationName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.user = self.isShowingPopularUsers ? self.popularUsers[indexPath.row] : self.regularUsers[indexPath.row]
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            guard self.isShowingPopularUsers else {
                return 0
            }
            if self.isSearchingPopularUsers {
                return 1
            }
            if self.popularUsers.count == 0 {
                return 1
            }
            return self.popularUsers.count
        case 1:
            guard !self.isShowingPopularUsers else {
                return 0
            }
            if self.isSearchingRegularUsers {
                return 1
            }
            if self.regularUsers.count == 0 {
                return 1
            }
            return self.regularUsers.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if self.isSearchingPopularUsers {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                // TODO update text.
                return cell
            }
            if self.popularUsers.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchUser", for: indexPath) as! SearchUserTableViewCell
            let user = self.popularUsers[indexPath.row]
            cell.profilePicImageView.image = user.profilePic
            cell.fullNameLabel.text = user.fullName
            cell.preferredUsernameLabel.text = user.preferredUsername
            cell.professionNameLabel.text = user.professionName
            cell.locationNameLabel.text = user.locationName
            cell.locationStackView.isHidden = user.locationName != nil ? false : true
            return cell
        case 1:
            if self.isSearchingRegularUsers {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                // TODO update text.
                return cell
            }
            if self.regularUsers.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchUser", for: indexPath) as! SearchUserTableViewCell
            let user = self.regularUsers[indexPath.row]
            cell.profilePicImageView.image = user.profilePic
            cell.fullNameLabel.text = user.fullName
            cell.preferredUsernameLabel.text = user.preferredUsername
            cell.professionNameLabel.text = user.professionName
            cell.locationNameLabel.text = user.locationName
            cell.locationStackView.isHidden = user.locationName != nil ? false : true
            return cell
        default:
            return UITableViewCell()
        }
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
            self.performSegue(withIdentifier: "segueToProfileVc", sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if self.isSearchingPopularUsers {
                return 64.0
            }
            if self.popularUsers.count == 0 {
                return 64.0
            }
            return 104.0
        case 1:
            if self.isSearchingRegularUsers {
                return 64.0
            }
            if self.regularUsers.count == 0 {
                return 64.0
            }
            return 104.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if self.isSearchingPopularUsers {
                return 64.0
            }
            if self.popularUsers.count == 0 {
                return 64.0
            }
            return UITableViewAutomaticDimension
        case 1:
            if self.isSearchingRegularUsers {
                return 64.0
            }
            if self.regularUsers.count == 0 {
                return 64.0
            }
            return UITableViewAutomaticDimension
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchTableSectionHeader") as? SearchTableSectionHeader
            var titleText = "POPULAR"
            if self.isLocationActive, let locationName = self.locationName {
                titleText = titleText + " in \(locationName)"
            }
            header?.titleLabel.text = titleText
            return header
        case 1:
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchTableSectionHeader") as? SearchTableSectionHeader
            var titleText = "BEST MATCHES"
            if self.isLocationActive, let locationName = self.locationName {
                titleText = titleText + " in \(locationName)"
            }
            header?.titleLabel.text = titleText
            return header
        default:
            return UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            guard self.isShowingPopularUsers else {
                return 0.0
            }
            return 32.0
        case 1:
            guard !self.isShowingPopularUsers else {
                return 0.0
            }
            return 32.0
        default:
            return 0.0
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchUsersTableViewControllerDelegate?.usersTableViewWillBeginDragging()
    }
    
    // MARK: AWS
    
    fileprivate func getAllUsers(_ locationName: String?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYCloudSearchProxyClient.defaultClient().getAllUsers(locationName: locationName).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingPopularUsers = false
                if let error = task.error {
                    print("getAllUsers error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let cloudSearchUsersResult = task.result as? PRFYCloudSearchUsersResult, let cloudSearchUsers = cloudSearchUsersResult.users else {
                        self.tableView.reloadData()
                        return
                    }
                    for cloudSearchUser in cloudSearchUsers {
                        let user = User(userId: cloudSearchUser.userId, firstName: cloudSearchUser.firstName, lastName: cloudSearchUser.lastName, preferredUsername: cloudSearchUser.preferredUsername, professionName: cloudSearchUser.professionName, profilePicUrl: cloudSearchUser.profilePicUrl, locationName: cloudSearchUser.locationName)
                        self.popularUsers.append(user)
                    }
                    self.tableView.reloadData()
                    
                    for user in self.popularUsers {
                        if let profilePicUrl = user.profilePicUrl {
                            self.downloadProfilePic(profilePicUrl, isPopularUser: true)
                        }
                    }
                }
            })
            return nil
        })
    }
    
    fileprivate func getUsers(_ namePrefix: String, locationName: String?) {
        // DANGER to cancel getAllUsers()
        //PRFYCloudSearchProxyClient.defaultClient().session.invalidateAndCancel()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYCloudSearchProxyClient.defaultClient().getUsers(namePrefix: namePrefix, locationName: locationName).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingRegularUsers = false
                if let error = task.error {
                    print("getUsers error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let cloudSearchUsersResult = task.result as? PRFYCloudSearchUsersResult, let cloudSearchUsers = cloudSearchUsersResult.users else {
                        self.tableView.reloadData()
                        return
                    }
                    // Clear old.
                    self.regularUsers = []
                    for cloudSearchUser in cloudSearchUsers {
                        let user = User(userId: cloudSearchUser.userId, firstName: cloudSearchUser.firstName, lastName: cloudSearchUser.lastName, preferredUsername: cloudSearchUser.preferredUsername, professionName: cloudSearchUser.professionName, profilePicUrl: cloudSearchUser.profilePicUrl, locationName: cloudSearchUser.locationName)
                        self.regularUsers.append(user)
                    }
                    self.tableView.reloadData()
                    
                    for user in self.regularUsers {
                        if let profilePicUrl = user.profilePicUrl {
                            self.downloadProfilePic(profilePicUrl, isPopularUser: false)
                        }
                    }
                }
            })
            return nil
        })
    }
    
    fileprivate func downloadProfilePic(_ profilePicUrl: String, isPopularUser: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let content = AWSUserFileManager.defaultUserFileManager().content(withKey: profilePicUrl)
        // TODO check if content.isImage()
        if content.isCached {
            print("Content cached:")
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            if isPopularUser {
                // Need to check if user exists because of autocomplete search.
                guard let userIndex = self.popularUsers.index(where: { $0.profilePicUrl == profilePicUrl }) else {
                    return
                }
                self.popularUsers[userIndex].profilePic = image
                if self.isShowingPopularUsers {
                    UIView.performWithoutAnimation {
                        self.tableView.reloadRows(at: [IndexPath(row: userIndex, section: 0)], with: UITableViewRowAnimation.none)
                    }
                }
            } else {
                guard let userIndex = self.regularUsers.index(where: { $0.profilePicUrl == profilePicUrl }) else {
                    return
                }
                self.regularUsers[userIndex].profilePic = image
                if !self.isShowingPopularUsers {
                    UIView.performWithoutAnimation {
                        self.tableView.reloadRows(at: [IndexPath(row: userIndex, section: 1)], with: UITableViewRowAnimation.none)
                    }
                }
            }
        } else {
            print("Download content:")
            content.download(
                with: AWSContentDownloadType.ifNewerExists,
                pinOnCompletion: false,
                progressBlock: {
                    (content: AWSContent?, progress: Progress?) -> Void in
                    // Do nothing.
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
                            if isPopularUser {
                                guard let userIndex = self.popularUsers.index(where: { $0.profilePicUrl == profilePicUrl }) else {
                                    return
                                }
                                self.popularUsers[userIndex].profilePic = image
                                if self.isShowingPopularUsers {
                                    UIView.performWithoutAnimation {
                                        self.tableView.reloadRows(at: [IndexPath(row: userIndex, section: 0)], with: UITableViewRowAnimation.none)
                                    }
                                }
                            } else {
                                guard let userIndex = self.regularUsers.index(where: { $0.profilePicUrl == profilePicUrl }) else {
                                    return
                                }
                                self.regularUsers[userIndex].profilePic = image
                                if !self.isShowingPopularUsers {
                                    UIView.performWithoutAnimation {
                                        self.tableView.reloadRows(at: [IndexPath(row: userIndex, section: 1)], with: UITableViewRowAnimation.none)
                                    }
                                }
                            }
                        }
                    })
            })
        }
    }
}

extension SearchUsersTableViewController: SearchUsersDelegate {
    
    func addLocation(_ locationName: String) {
        self.locationName = locationName
        self.isLocationActive = true
        // Clear old.
        self.popularUsers = []
        self.isSearchingPopularUsers = true
        self.tableView.reloadData()
        self.getAllUsers(self.locationName)
    }
    
    func removeLocation() {
        self.locationName = nil
        self.isLocationActive = false
        // Clear old.
        self.popularUsers = []
        self.isSearchingPopularUsers = true
        self.tableView.reloadData()
        self.getAllUsers(self.locationName)
    }
    
    func searchBarTextChanged(_ searchText: String) {
        if searchText.trimm().isEmpty {
            self.isShowingPopularUsers = true
            // Clear old.
            self.regularUsers = []
            self.isSearchingRegularUsers = false
            self.tableView.reloadData()
        } else {
            self.isShowingPopularUsers = false
            // Clear old.
            self.regularUsers = []
            self.isSearchingRegularUsers = true
            self.tableView.reloadData()
            // Start search.
            self.getUsers(searchText.trimm(), locationName: self.locationName)
        }
    }
    
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
}
