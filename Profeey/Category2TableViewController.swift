//
//  Category2TableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 27/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class Category2TableViewController: UITableViewController {
    
    var category: Category?
    fileprivate var users: [User] = []
    fileprivate var showTopUsers: Bool = true
    fileprivate var isSearchingUsers: Bool = false
    
    fileprivate var isLocationOn: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.category?.categoryName
        self.scanUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if self.isSearchingUsers {
            return 1
        }
        if !self.showTopUsers && self.users.count == 0 {
            return 1
        }
        return self.users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellAddLocation", for: indexPath) as! AddLocationTableViewCell
            cell.clearButton.isHidden = !self.isLocationOn
            return cell
        }
        if self.isSearchingUsers {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        if !self.showTopUsers && self.users.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
            return cell
        }
        let user = self.users[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchUser", for: indexPath) as! SearchUserTableViewCell
        cell.profilePicImageView.image = user.profilePic
        cell.fullNameLabel.text = user.fullName
        cell.preferredUsernameLabel.text = user.fullUsername
        cell.professionNameLabel.text = user.professionName
//        cell.locationNameLabel.text = user.locationName
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = self.showTopUsers ? "TOP PROFEEYS" : "BEST MATCHES"
        cell.contentView.backgroundColor = UIColor.white
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).section == 0 {
            self.performSegue(withIdentifier: "segueToLocationsVc", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 62.0
        }
        return 84.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 62.0
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        return 32.0
    }
    
    // MARK: AWS
    
    fileprivate func scanUsers() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("scanUsers error: \(error)")
                } else {
                    guard let awsUsers = response?.items as? [AWSUser] , awsUsers.count > 0  else {
                        return
                    }
                    for awsUser in awsUsers {
                        let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationName: awsUser._locationName)
                        self.users.append(user)
                    }
                    self.tableView.reloadData()
                    for (index, awsUser) in awsUsers.enumerated() {
                        if let profilePicUrl = awsUser._profilePicUrl {
                            let indexPath = IndexPath(row: index, section: 0)
                            self.downloadImage(profilePicUrl, imageType: ImageType.userProfilePic, indexPath: indexPath)
                        }
                    }
                }
            })
        })
    }
    
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
