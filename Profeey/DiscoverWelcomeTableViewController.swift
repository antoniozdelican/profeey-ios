//
//  DiscoverWelcomeTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class DiscoverWelcomeTableViewController: UITableViewController {
    
    var users: [User] = []
    
    var tempIndices: [NSIndexPath] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.tableView.estimatedRowHeight = 65.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.delaysContentTouches = false
        
//        let user0 = User(fullName: "Antonio Zdelican", professions: ["Computer Engineer", "Entrepreneur"], profilePicUrl: "pic_antonio")
//        let user1 = User(fullName: "Ivan Zdelican", professions: ["IT Engineer", "Student"], profilePicUrl: "pic_ivan")
//        let user2 = User(fullName: "Filip Vargovic", professions: ["Yacht Skipper"], profilePicUrl: "pic_filip")
//        let user3 = User(fullName: "Ivana Flisar", professions: ["Doctor of Medicine"], profilePicUrl: "pic_ivana")
//        let user4 = User(fullName: "Vlatko Terlecky", professions: ["Civil Engineer"], profilePicUrl: "")
//        self.users.append(user0)
//        self.users.append(user1)
//        self.users.append(user2)
//        self.users.append(user3)
//        self.users.append(user4)
//        self.users.append(user0)
//        self.users.append(user1)
//        self.users.append(user2)
//        self.users.append(user3)
//        self.users.append(user4)
//        self.users.append(user0)
//        self.users.append(user1)
//        self.users.append(user2)
//        self.users.append(user3)
//        self.users.append(user4)
//        self.users.append(user0)
//        self.users.append(user1)
//        self.users.append(user2)
//        self.users.append(user3)
//        self.users.append(user4)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellUser", forIndexPath: indexPath) as! UserWelcomeTableViewCell
        let user = users[indexPath.row]
//        cell.fullNameLabel.text = user.fullName
//        cell.professionsLabel.text = user.professions.joinWithSeparator(" · ")
//        cell.profilePicImageView.image = user.profilePic
        if tempIndices.contains(indexPath) {
            cell.setFollowingButton()
        } else {
            cell.setFollowButton()
        }
        cell.followButton.addTarget(self, action: #selector(DiscoverWelcomeTableViewController.followButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    func followButtonTapped(sender: UIButton) {
        let point = sender.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(point) else {
            return
        }
        // If is following, unfollow, else follow
        if let tempIndex = self.tempIndices.indexOf(indexPath) {
            self.tempIndices.removeAtIndex(tempIndex)
        } else {
            self.tempIndices.append(indexPath)
        }
        // Toggle row.
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    // MARK: IBActions

    @IBAction func doneButtonTapped(sender: AnyObject) {
        // Change root
        guard let keyWindow = UIApplication.sharedApplication().keyWindow,
            let mainInitialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
                return
        }
        keyWindow.rootViewController = mainInitialViewController
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
