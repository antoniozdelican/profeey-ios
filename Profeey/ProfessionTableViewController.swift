//
//  ProfessionTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class ProfessionTableViewController: UITableViewController {
    
    var profession: Profession?
    var isLocationActive: Bool = false
    var location: Location?
    
    fileprivate var users: [User] = []
    fileprivate var allUsers: [User] = []
    fileprivate var locationUsers: [User] = []
    fileprivate var isSearchingUsers: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = self.profession?.professionName
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        
        if let professionName = self.profession?.professionName {
            self.isSearchingUsers = true
//            self.getAllUsersWithProfession(professionName, locationId: self.location?.locationId)
            self.queryProfessionUsers(professionName, locationId: self.location?.locationId)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let indexPath = sender as? IndexPath {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchUser", for: indexPath) as! SearchUserTableViewCell
        let user = self.users[indexPath.row]
        cell.profilePicImageView.image = user.profilePic
        cell.fullNameLabel.text = user.fullName
        cell.preferredUsernameLabel.text = user.preferredUsername
        cell.professionNameLabel.text = user.professionName
        cell.locationNameLabel.text = user.locationName
        cell.locationStackView.isHidden = user.locationName != nil ? false : true
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
            self.performSegue(withIdentifier: "segueToProfileVc", sender: indexPath)
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
        var titleText = "TOP"
        if self.isLocationActive, let locationName = self.location?.locationName {
            titleText = titleText + " in \(locationName)"
        }
        header?.titleLabel.text = titleText
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: Helpers
    
    fileprivate func sortUsers(_ users: [User]) -> [User] {
        return users.sorted(by: {
            (user1, user2) in
            return user1.numberOfRecommendationsInt > user2.numberOfRecommendationsInt
        })
    }
    
    // MARK: AWS
    
    fileprivate func queryProfessionUsers(_ professionName: String, locationId: String?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryProfessionUsers(professionName, locationId: locationId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingUsers = false
                if let error = error {
                    print("queryProfessionUsers error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsUsers = response?.items as? [AWSUser] else {
                        self.tableView.reloadData()
                        return
                    }
                    for awsUser in awsUsers {
                        let user = LocationUser(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationId: awsUser._locationId, locationName: awsUser._locationName, numberOfRecommendations: awsUser._numberOfRecommendations)
                        if user.profilePicUrl == nil {
                            user.profilePic = UIImage(named: "ic_no_profile_pic_feed")
                        }
                        self.users.append(user)
                    }
                    self.users = self.sortUsers(self.users)
                    self.tableView.reloadData()
                    
                    for user in self.users {
                        if let profilePicUrl = user.profilePicUrl {
                            self.downloadProfilePic(profilePicUrl)
                        }
                    }
                }
            })
        })
    }
    
//    fileprivate func getAllUsersWithProfession(_ professionName: String, locationId: String?) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        PRFYCloudSearchProxyClient.defaultClient().getAllUsersWithProfession(professionName: professionName, locationId: locationId).continue({
//            (task: AWSTask) in
//            DispatchQueue.main.async(execute: {
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                self.isSearchingUsers = false
//                if let error = task.error {
//                    print("getUsersWithProfession error: \(error)")
//                    self.tableView.reloadData()
//                } else {
//                    guard let cloudSearchUsersResult = task.result as? PRFYCloudSearchUsersResult, let cloudSearchUsers = cloudSearchUsersResult.users else {
//                        self.tableView.reloadData()
//                        return
//                    }
//                    // Clear old.
//                    self.users = []
//                    for cloudSearchUser in cloudSearchUsers {
//                        let user = User(userId: cloudSearchUser.userId, firstName: cloudSearchUser.firstName, lastName: cloudSearchUser.lastName, preferredUsername: cloudSearchUser.preferredUsername, professionName: cloudSearchUser.professionName, profilePicUrl: cloudSearchUser.profilePicUrl, locationName: cloudSearchUser.locationName)
//                        self.users.append(user)
//                    }
//                    self.tableView.reloadData()
//                    
//                    for user in self.users {
//                        if let profilePicUrl = user.profilePicUrl {
//                            self.downloadProfilePic(profilePicUrl)
//                        }
//                    }
//                }
//            })
//            return nil
//        })
//    }
    
    fileprivate func downloadProfilePic(_ profilePicUrl: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let content = AWSUserFileManager.defaultUserFileManager().content(withKey: profilePicUrl)
        // TODO check if content.isImage()
        if content.isCached {
            print("Content cached:")
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            guard let userIndex = self.users.index(where: { $0.profilePicUrl == profilePicUrl }) else {
                return
            }
            self.users[userIndex].profilePic = image
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [IndexPath(row: userIndex, section: 0)], with: UITableViewRowAnimation.none)
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
                            guard let userIndex = self.users.index(where: { $0.profilePicUrl == profilePicUrl }) else {
                                return
                            }
                            self.users[userIndex].profilePic = image
                            UIView.performWithoutAnimation {
                                self.tableView.reloadRows(at: [IndexPath(row: userIndex, section: 0)], with: UITableViewRowAnimation.none)
                            }
                        }
                    })
            })
        }
    }
}
