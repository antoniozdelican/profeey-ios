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
    func didSelectUser(indexPath: NSIndexPath)
}

class SearchUsersTableViewController: UITableViewController {
    
    var scrollViewDelegate: ScrollViewDelegate?
    var selectUserDelegate: SelectUserDelegate?
    private var users: [User] = []
    private var showRecentUsers: Bool = true
    private var isSearchingUsers: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchingUsers {
            return 1
        }
        if !self.showRecentUsers && self.users.count == 0 {
            return 1
        }
        return self.users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.isSearchingUsers {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellSearching", forIndexPath: indexPath) as! SearchingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        if !self.showRecentUsers && self.users.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellNoResults", forIndexPath: indexPath) as! NoResultsTableViewCell
            return cell
        }
        let user = self.users[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cellSearchUser", forIndexPath: indexPath) as! SearchUserTableViewCell
        cell.profilePicImageView.image = user.profilePic
        cell.fullNameLabel.text = user.fullName
        cell.professionLabel.text = user.professionName
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = self.showRecentUsers ? "RECENT" : "BEST MATCHES"
        cell.contentView.backgroundColor = UIColor.whiteColor()
        return cell.contentView
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.selectUserDelegate?.didSelectUser(indexPath)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollViewDelegate?.didScroll()
    }
    
    // MARK: AWS
    
    private func downloadImage(imageKey: String, imageType: ImageType, indexPath: NSIndexPath) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").contentWithKey(imageKey)
        // TODO check if content.isImage()
        if content.cached {
            print("Content cached:")
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            switch imageType {
            case .UserProfilePic:
                self.users[indexPath.row].profilePic = image
                self.tableView.reloadData()
            default:
                return
            }
        } else {
            print("Download content:")
            content.downloadWithDownloadType(
                AWSContentDownloadType.IfNewerExists,
                pinOnCompletion: false,
                progressBlock: {
                    (content: AWSContent?, progress: NSProgress?) -> Void in
                    // TODO
                },
                completionHandler: {
                    (content: AWSContent?, data: NSData?, error: NSError?) in
                    dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        if let error = error {
                            print("downloadImage error: \(error)")
                        } else {
                            guard let imageData = data else {
                                return
                            }
                            let image = UIImage(data: imageData)
                            switch imageType {
                            case .UserProfilePic:
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
    
    func searchingUsers(isSearchingUsers: Bool) {
        self.isSearchingUsers = isSearchingUsers
        self.tableView.reloadData()
    }
    
    func showUsers(users: [User], showRecentUsers: Bool) {
        self.users = users
        self.showRecentUsers = showRecentUsers
        self.tableView.reloadData()
        
        for (index, user) in users.enumerate() {
            if let profilePicUrl = user.profilePicUrl {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                self.downloadImage(profilePicUrl, imageType: ImageType.UserProfilePic, indexPath: indexPath)
            }
        }
    }
}
