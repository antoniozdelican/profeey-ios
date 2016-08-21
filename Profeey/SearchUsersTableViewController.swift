//
//  SearchUsersTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol SelectUserDelegate {
    func userSelected(index: Int)
}

class SearchUsersTableViewController: UITableViewController {
    
    var scrollViewDelegate: ScrollViewDelegate?
    var selectUserDelegate: SelectUserDelegate?
    private var users: [User] = []
    private var showSearchingIndicator: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 65.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.showSearchingIndicator {
                // Searching cell.
                return 1
            } else {
                return 0
            }
        case 1:
            if !self.showSearchingIndicator {
                // No results cell.
                return self.users.count > 0 ? 0 : 1
            } else {
                return 0
            }
        default:
            if !self.showSearchingIndicator {
                // Users.
                return self.users.count
            } else {
                return 0
            }
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellSearching", forIndexPath: indexPath) as! SearchingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellNoResults", forIndexPath: indexPath) as! NoResultsTableViewCell
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellUser", forIndexPath: indexPath) as! SearchUserTableViewCell
            let user = self.users[indexPath.row]
            cell.profilePicImageView.image = user.profilePic
            cell.fullNameLabel.text = user.fullName
            cell.professionsLabel.text = user.professions?.joinWithSeparator(" · ")
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is SearchUserTableViewCell {
            self.selectUserDelegate?.userSelected(indexPath.row)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.scrollViewDelegate?.scrollViewWillBeginDragging()
    }
}

extension SearchUsersTableViewController: SearchUsersDelegate {
    
    func showUsers(users: [User]) {
        self.users = users
        self.tableView.reloadData()
    }
    
    func toggleSearchingIndicator(show: Bool) {
        self.showSearchingIndicator = show
        self.tableView.reloadData()
    }
}
