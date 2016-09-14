//
//  NotificationsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController {
    
    private var notifications: [String] = []
    private var isLoadingNotifications: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingNotifications {
            return 1
        }
        if !self.isLoadingNotifications && self.notifications.count == 0 {
            return 1
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.isLoadingNotifications {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellLoading", forIndexPath: indexPath) as! LoadingTableViewCell
            return cell
        }
        if !self.isLoadingNotifications && self.notifications.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellEmpty", forIndexPath: indexPath) as! EmptyTableViewCell
            cell.emptyMessageLabel.text = "You don't have any recent notifications."
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.isLoadingNotifications {
            return 120.0
        }
        if !self.isLoadingNotifications && self.notifications.count == 0 {
            return 120.0
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.isLoadingNotifications {
            return 120.0
        }
        if !self.isLoadingNotifications && self.notifications.count == 0 {
            return 120.0
        }
        return 0
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(sender: AnyObject) {
        self.refreshControl?.endRefreshing()
        self.notifications = []
    }
}
