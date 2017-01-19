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
    fileprivate var isSearchingUsers: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = self.profession?.professionName
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        
        if let professionName = self.profession?.professionName {
            self.isSearchingUsers = true
            self.queryProfessionUsers(professionName, locationId: self.location?.locationId)
        }
        
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
    
    fileprivate func sortUsers() {
        self.users = self.users.sorted(by: {
            (user1, user2) in
            return user1.numberOfRecommendationsInt > user2.numberOfRecommendationsInt
        })
        self.tableView.reloadData()
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
    
    func recommendUserNotification(_ notification: NSNotification) {
        guard let recommendingId = notification.userInfo?["recommendingId"] as? String else {
            return
        }
        guard let user = self.users.first(where: { $0.userId == recommendingId }) else {
            return
        }
        if let numberOfRecommendations = user.numberOfRecommendations {
            user.numberOfRecommendations = NSNumber(value: numberOfRecommendations.intValue + 1)
        } else {
            user.numberOfRecommendations = NSNumber(value: 1)
        }
        self.sortUsers()
    }
    
    func unrecommendUserNotification(_ notification: NSNotification) {
        guard let recommendingId = notification.userInfo?["recommendingId"] as? String else {
            return
        }
        guard let user = self.users.first(where: { $0.userId == recommendingId }) else {
            return
        }
        if let numberOfRecommendations = user.numberOfRecommendations, numberOfRecommendations.intValue > 0 {
            user.numberOfRecommendations = NSNumber(value: numberOfRecommendations.intValue - 1)
        } else {
            user.numberOfRecommendations = NSNumber(value: 0)
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
