//
//  NotificationsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController {
    
    fileprivate var notifications: [PRFYNotification] = []
    fileprivate var isLoadingNotifications: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let testUser = CurrentUser(userId: nil, firstName: nil, lastName: nil, preferredUsername: "Testonja", professionName: nil, profilePicUrl: nil, locationName: nil)
        
        let notificationLike = PRFYNotification(userId: nil, notificationId: nil, creationDate: 1476269401.008167, notificationType: 0, postId: nil, user: testUser)
        let notificationComment = PRFYNotification(userId: nil, notificationId: nil, creationDate: 1476269401.008167, notificationType: 1, postId: nil, user: testUser)
        let notificationFollowing = PRFYNotification(userId: nil, notificationId: nil, creationDate: 1476269401.008167, notificationType: 2, postId: nil, user: testUser)
        let notificationRecommendation = PRFYNotification(userId: nil, notificationId: nil, creationDate: 1476269401.008167, notificationType: 3, postId: nil, user: testUser)
        self.notifications.append(notificationLike)
        self.notifications.append(notificationComment)
        self.notifications.append(notificationFollowing)
        self.notifications.append(notificationRecommendation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingNotifications {
            return 1
        }
        if self.notifications.count == 0 {
            return 1
        }
        return self.notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoadingNotifications {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellLoading", for: indexPath) as! LoadingTableViewCell
            return cell
        }
        if self.notifications.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
            cell.emptyMessageLabel.text = "You don't have any recent notifications."
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNotification", for: indexPath) as! NotificationTableViewCell
        let notification = self.notifications[indexPath.row]
        
        if let preferredUsername = notification.user?.preferredUsername, let notificationMessage = notification.notificationMessage, let creationDateString = notification.creationDateString {
            cell.messageLabel.attributedText = self.constructNotificationMessage(preferredUsername, notificationMessage: notificationMessage, creationDateString: creationDateString)
        }
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if !(cell is NotificationTableViewCell) {
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingNotifications {
            return 112.0
        }
        if self.notifications.count == 0 {
            return 112.0
        }
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingNotifications {
            return 112.0
        }
        if self.notifications.count == 0 {
            return 112.0
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        self.refreshControl?.endRefreshing()
        self.notifications = []
    }
    
    // MARK: Helpers
    
    fileprivate func constructNotificationMessage(_ preferredUsername: String, notificationMessage: String, creationDateString: String) -> NSAttributedString {
        let messageAttributedString = NSMutableAttributedString()
        // preferredUsername
        let preferredUsernameAttributedString = NSAttributedString(string: preferredUsername, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightMedium)])
        // message
        let notificationMessageAttributedString = NSAttributedString(string: notificationMessage)
        // creationDateString
        let creationDateAttributedString = NSAttributedString(string: creationDateString, attributes: [NSForegroundColorAttributeName: Colors.grey])
        messageAttributedString.append(preferredUsernameAttributedString)
        messageAttributedString.append(notificationMessageAttributedString)
        messageAttributedString.append(creationDateAttributedString)
        return messageAttributedString
    }
}
