//
//  UsersTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {
    
    var users: [User]?
    var isLikers: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.tableView.estimatedRowHeight = 56.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        if self.isLikers {
            self.navigationItem.title = "Likers"
        } else {
            self.navigationItem.title = "Followers"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellUser", forIndexPath: indexPath) as! UserTableViewCell
        cell.profilePicImageView.image = UIImage(named: "pic_antonio")
        cell.fullNameLabel.text = "Antonio Zdelican"
        cell.professionsLabel.text = "Computer Engineer"
        if indexPath.row % 2 == 0 {
            cell.setFollowButton()
        } else {
            cell.setFollowingButton()
        }
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }

}
