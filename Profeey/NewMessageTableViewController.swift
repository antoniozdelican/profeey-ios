//
//  NewMessageTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol NewMessageTableViewControllerDelegate: class {
    func tableViewWillBeginDragging()
}

class NewMessageTableViewController: UITableViewController {
    
    weak var newMessageTableViewControllerDelegate: NewMessageTableViewControllerDelegate?
    
    fileprivate var users: [User] = []
    fileprivate var isSearchingUsers: Bool {
        return self.isSearchingPopularUsers
    }
    
    fileprivate var popularUsers: [User] = []
    fileprivate var isSearchingPopularUsers: Bool = false
    fileprivate var isShowingPopularUsers: Bool = true
    
    fileprivate var isLocationActive: Bool = false
    fileprivate var location: Location?
    
    fileprivate var noNetworkConnection: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        
        self.isShowingPopularUsers = true
        self.isSearchingPopularUsers = true
        self.scanUsers()
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? MessagesViewController,
            let cell = sender as? NewMessageUserTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.participant = self.users[indexPath.row].copyUser()
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.noNetworkConnection {
            return 1
        }
        if self.isSearchingUsers {
            return 1
        }
        if self.users.count == 0 {
            return 1
        }
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.noNetworkConnection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoNetwork", for: indexPath) as! NoNetworkTableViewCell
            return cell
        }
        if self.isSearchingUsers {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        if self.users.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNewMessageUser", for: indexPath) as! NewMessageUserTableViewCell
        let user = self.users[indexPath.row]
        cell.profilePicImageView.image = user.profilePicUrl != nil ? user.profilePic : UIImage(named: "ic_no_profile_pic_feed")
        cell.preferredUsernameLabel.text = user.preferredUsername
        cell.professionNameLabel.text = user.professionName
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if cell is NoResultsTableViewCell {
            cell.separatorInset = UIEdgeInsetsMake(0.0, 12.0, 0.0, 0.0)
        }
        if cell is NoNetworkTableViewCell {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is NewMessageUserTableViewCell {
            self.performSegue(withIdentifier: "segueToMessagesVc", sender: cell)
        }
        if cell is NoNetworkTableViewCell {
            // Query.
            self.noNetworkConnection = false
            self.isSearchingPopularUsers = true
            self.tableView.reloadData()
            self.scanUsers()
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.noNetworkConnection {
            return 112.0
        }
        if self.isSearchingUsers {
            return 60.0
        }
        if self.users.count == 0 {
            return 60.0
        }
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.noNetworkConnection {
            return 112.0
        }
        if self.isSearchingUsers {
            return 60.0
        }
        if self.users.count == 0 {
            return 60.0
        }
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchTableSectionHeader") as? SearchTableSectionHeader
        header?.titleLabel.text = "BEST MATCHES"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.newMessageTableViewControllerDelegate?.tableViewWillBeginDragging()
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard !self.isSearchingUsers else {
            self.refreshControl?.endRefreshing()
            return
        }
        // Query.
        self.scanUsers()
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
                guard error == nil else {
                    print("scanUsers error: \(error!)")
                    self.isSearchingPopularUsers = false
                    self.refreshControl?.endRefreshing()
                    if (error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    self.tableView.reloadData()
                    return
                }
                self.popularUsers = []
                if let awsUsers = response?.items as? [AWSUser] {
                    for awsUser in awsUsers {
                        guard awsUser._userId != AWSIdentityManager.defaultIdentityManager().identityId else {
                            continue
                        }
                        let user = LocationUser(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationId: awsUser._locationId, locationName: awsUser._locationName, numberOfRecommendations: awsUser._numberOfRecommendations)
                        self.popularUsers.append(user)
                    }
                }
                // Set popular users.
                self.popularUsers = self.sortUsers(self.popularUsers)
                self.users = self.popularUsers
                
                // Reset flags and animations that were initiated.
                self.isSearchingPopularUsers = false
                self.refreshControl?.endRefreshing()
                self.noNetworkConnection = false
                
                // Reload tableView.
                self.tableView.reloadData()
                
                // Load profilePics.
                if let awsUsers = response?.items as? [AWSUser] {
                    for awsUser in awsUsers {
                        if let profilePicUrl = awsUser._profilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                        }
                    }
                }
            })
        })
    }

}

extension NewMessageTableViewController {
    
    // MARK: NSNotifications
    
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
        (self.tableView.cellForRow(at: IndexPath(row: userIndex, section: 0)) as? NewMessageUserTableViewCell)?.profilePicImageView.image = self.popularUsers[userIndex].profilePic
    }
}

extension NewMessageTableViewController: NewMessageViewControllerDelegate {
    
    func searchTextFieldChanged(_ text: String) {
        let name = text.trimm()
        if name.isEmpty {
            self.isShowingPopularUsers = true
            self.users = self.popularUsers
            self.tableView.reloadData()
        } else {
            self.isShowingPopularUsers = false
            self.filterUsers(name)
        }
    }
}
