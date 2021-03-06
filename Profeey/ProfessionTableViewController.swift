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
    var isSchoolActive: Bool = false
    var school: School?
    
    fileprivate var users: [User] = []
    fileprivate var isSearchingUsers: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = self.profession?.professionName?.replacingOccurrences(of: "_", with: " ")
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        
        if let professionName = self.profession?.professionName {
            self.isSearchingUsers = true
            self.queryProfessionUsers(professionName, schoolId: self.school?.schoolId)
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.createPostNotification(_:)), name: NSNotification.Name(CreatePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deletePostNotification(_:)), name: NSNotification.Name(DeletePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let indexPath = sender as? IndexPath {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchUser", for: indexPath) as! SearchUserTableViewCell
        let user = self.users[indexPath.row]
        cell.profilePicImageView.image = user.profilePicUrl != nil ? user.profilePic : UIImage(named: "ic_no_profile_pic_feed")
        cell.fullNameLabel.text = user.fullName
        cell.preferredUsernameLabel.text = user.preferredUsername
        cell.professionNameLabel.text = user.professionNameWhitespace
        cell.schoolNameLabel.text = user.schoolName
        cell.schoolStackView.isHidden = user.schoolName != nil ? false : true
        cell.numberOfPostsLabel.text = user.numberOfPostsInt.numberToString()
        cell.numberOfPostsStackView.isHidden = user.numberOfPostsInt > 0 ? false : true
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if cell is NoResultsTableViewCell {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
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
        if self.isSchoolActive, let schoolName = self.school?.schoolName {
            titleText = titleText + " at \(schoolName)"
        }
        header?.titleLabel.text = titleText
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: Helpers
    
    fileprivate func sortUsers() {
        self.users = self.users.sorted(by: {
            (user1, user2) in
            return user1.numberOfPostsInt > user2.numberOfPostsInt
        })
        self.tableView.reloadData()
    }
    
    // MARK: AWS
    
    fileprivate func queryProfessionUsers(_ professionName: String, schoolId: String?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryProfessionUsers(professionName, schoolId: schoolId, completionHandler: {
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
                        let user = SchoolUser(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, schoolId: awsUser._schoolId, schoolName: awsUser._schoolName, numberOfPosts: awsUser._numberOfPosts)
                        if user.profilePicUrl == nil {
                            user.profilePic = UIImage(named: "ic_no_profile_pic_feed")
                        }
                        self.users.append(user)
                    }
                    self.sortUsers()
                    
                    for user in self.users {
                        if let profilePicUrl = user.profilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                        }
                    }
                }
            })
        })
    }
    
}

extension ProfessionTableViewController {
    
    // MARK: NSNotifications
    
    func createPostNotification(_ notification: NSNotification) {
        guard let post = notification.userInfo?["post"] as? Post else {
            return
        }
        guard let user = self.users.first(where: { $0.userId == post.userId }) else {
            return
        }
        if let numberOfPosts = user.numberOfPosts {
            user.numberOfPosts = NSNumber(value: numberOfPosts.intValue + 1)
        } else {
            user.numberOfPosts = NSNumber(value: 1)
        }
        self.sortUsers()
    }
    
    func deletePostNotification(_ notification: NSNotification) {
        guard let post = notification.userInfo?["post"] as? Post else {
            return
        }
        guard let user = self.users.first(where: { $0.userId == post.userId }) else {
            return
        }
        if let numberOfPosts = user.numberOfPosts, numberOfPosts.intValue > 0 {
            user.numberOfPosts = NSNumber(value: numberOfPosts.intValue - 1)
        } else {
            user.numberOfPosts = NSNumber(value: 0)
        }
        self.sortUsers()
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
                (self.tableView.cellForRow(at: IndexPath(row: userIndex, section: 0)) as? SearchUserTableViewCell)?.profilePicImageView.image = self.users[userIndex].profilePic
            }
        }
    }
}
