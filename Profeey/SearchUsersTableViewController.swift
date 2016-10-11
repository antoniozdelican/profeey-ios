//
//  SearchUsersTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol SelectUserDelegate {
    func didSelectUser(_ indexPath: IndexPath)
}

class SearchUsersTableViewController: UITableViewController {
    
    var scrollViewDelegate: ScrollViewDelegate?
    var selectUserDelegate: SelectUserDelegate?
    fileprivate var users: [User] = []
    fileprivate var showRecentUsers: Bool = true
    fileprivate var isSearchingUsers: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchingUsers {
            return 1
        }
        if !self.showRecentUsers && self.users.count == 0 {
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
        if !self.showRecentUsers && self.users.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
            return cell
        }
        let user = self.users[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchUser", for: indexPath) as! SearchUserTableViewCell
        cell.profilePicImageView.image = user.profilePic
        cell.fullNameLabel.text = user.fullName
        cell.preferredUsernameLabel.text = user.fullUsername
        cell.professionNameLabel.text = user.professionName
        cell.locationNameLabel.text = user.locationName
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = self.showRecentUsers ? "POPULAR" : "BEST MATCHES"
        cell.contentView.backgroundColor = Colors.greyLight
        cell.contentView.alpha = 0.95
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectUserDelegate?.didSelectUser(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollViewDelegate?.didScroll()
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
                self.users[indexPath.row].profilePic = image
                self.tableView.reloadData()
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
                                self.tableView.reloadData()
                            default:
                                return
                            }
                        }
                    })
            })
        }
    }
}

extension SearchUsersTableViewController: SearchUsersDelegate {
    
    func searchingUsers(_ isSearchingUsers: Bool) {
        self.isSearchingUsers = isSearchingUsers
        self.tableView.reloadData()
    }
    
    func showUsers(_ users: [User], showRecentUsers: Bool) {
        self.users = users
        self.showRecentUsers = showRecentUsers
        self.tableView.reloadData()
        
        for (index, user) in users.enumerated() {
            if let profilePicUrl = user.profilePicUrl {
                let indexPath = IndexPath(row: index, section: 0)
                self.downloadImage(profilePicUrl, imageType: ImageType.userProfilePic, indexPath: indexPath)
            }
        }
    }
}
