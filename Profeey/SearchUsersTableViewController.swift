//
//  SearchUsersTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class SearchUsersTableViewController: UITableViewController {
    
    var scrollViewDelegate: ScrollViewDelegate?
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
    }
}
