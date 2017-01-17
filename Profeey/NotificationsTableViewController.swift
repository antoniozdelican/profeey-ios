//
//  NotificationsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class NotificationsTableViewController: UITableViewController {
    
    // Removed weak so it doesn't go to nil.
    @IBOutlet var loadingTableFooterView: UIView!
    
    fileprivate var notifications: [PRFYNotification] = []
    fileprivate var isLoadingNotifications: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    fileprivate var noNetworkConnection: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Query.
        self.isLoadingNotifications = true
        self.tableView.tableFooterView = self.loadingTableFooterView
        self.queryNotificationsDateSorted(true)
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.uiApplicationDidBecomeActiveNotification(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let cell = sender as? NotificationTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.user = self.notifications[indexPath.row].user?.copyUser()
        }
        if let destinationViewController = segue.destination as? PostDetailsTableViewController,
            let cell = sender as? NotificationTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.shouldDownloadPost = true
            destinationViewController.notificationPostId = self.notifications[indexPath.row].postId
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.isLoadingNotifications && self.notifications.count == 0 {
            return 1
        }
        return self.notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !self.isLoadingNotifications && self.notifications.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
            cell.emptyMessageLabel.text = "No notifications yet."
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNotification", for: indexPath) as! NotificationTableViewCell
        let notification = self.notifications[indexPath.row]
        cell.profilePicImageView.image = notification.user?.profilePicUrl != nil ? notification.user?.profilePic : UIImage(named: "ic_no_profile_pic_feed")
        cell.messageLabel.attributedText = self.constructNotificationMessage(notification.user?.preferredUsername, notificationMessage: notification.notificationMessage)
        cell.timeLabel.text = notification.createdString
        
        // Check for new notifications.
        if let notificationCreated = notification.created?.intValue, let lastSeenDate = (self.tabBarController as? MainTabBarController)?.lastSeenDate?.intValue {
            cell.contentView.backgroundColor = (notificationCreated > lastSeenDate) ? Colors.greyLight : UIColor.white
        }
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        guard cell is NotificationTableViewCell, let notificationType = self.notifications[indexPath.row].notificationType else {
            return
        }
        if notificationType.intValue == NotificationType.like.rawValue || notificationType.intValue == NotificationType.comment.rawValue {
            self.performSegue(withIdentifier: "segueToPostDetailsVc", sender: cell)
        } else if notificationType.intValue == NotificationType.following.rawValue || notificationType.intValue == NotificationType.recommendation.rawValue {
            self.performSegue(withIdentifier: "segueToProfileVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if !(cell is NotificationTableViewCell) {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
        // Load next notifications and reset tableFooterView.
        guard indexPath.row == self.notifications.count - 1 && !self.isLoadingNotifications && self.lastEvaluatedKey != nil else {
            return
        }
        guard !self.noNetworkConnection else {
            return
        }
        self.tableView.tableFooterView = self.loadingTableFooterView
        self.isLoadingNotifications = true
        self.queryNotificationsDateSorted(false)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.notifications.count == 0 {
            return 64.0
        }
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.notifications.count == 0 {
            return 64.0
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard !self.isLoadingNotifications else {
            self.refreshControl?.endRefreshing()
            return
        }
        // Reset lastSeenDate.
        (self.tabBarController as? MainTabBarController)?.lastSeenDate = NSNumber(value: Date().timeIntervalSince1970)
        self.isLoadingNotifications = true
        self.queryNotificationsDateSorted(true)
    }
    
    // MARK: Helpers
    
    fileprivate func constructNotificationMessage(_ preferredUsername: String?, notificationMessage: String?) -> NSAttributedString? {
        guard let preferredUsername = preferredUsername, let notificationMessage = notificationMessage else {
            return nil
        }
        let messageAttributedString = NSMutableAttributedString()
        // preferredUsername
        let preferredUsernameAttributedString = NSAttributedString(string: preferredUsername, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightMedium)])
        // message
        let notificationMessageAttributedString = NSAttributedString(string: notificationMessage)
        messageAttributedString.append(preferredUsernameAttributedString)
        messageAttributedString.append(notificationMessageAttributedString)
        return messageAttributedString
    }
    
    // MARK: AWS
    
    fileprivate func queryNotificationsDateSorted(_ startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryNotificationsDateSortedDynamoDB(self.lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryNotificationsDateSorted error: \(error!)")
                    self.isLoadingNotifications = false
                    self.refreshControl?.endRefreshing()
                    self.tableView.tableFooterView = UIView()
                    self.tableView.reloadData()
                    let nsError = error as! NSError
                    if nsError.code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    return
                }
                if startFromBeginning {
                    self.notifications = []
                }
                var numberOfNewNotifications = 0
                if let awsNotifications = response?.items as? [AWSNotification] {
                    for awsNotification in awsNotifications {
                        let user = User(userId: awsNotification._notifierUserId, firstName: awsNotification._firstName, lastName: awsNotification._lastName, preferredUsername: awsNotification._preferredUsername, professionName: awsNotification._professionName, profilePicUrl: awsNotification._profilePicUrl)
                        let notification = PRFYNotification(userId: awsNotification._userId, notificationId: awsNotification._notificationId, created: awsNotification._created, notificationType: awsNotification._notificationType, postId: awsNotification._postId, user: user)
                        self.notifications.append(notification)
                        numberOfNewNotifications += 1
                    }
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingNotifications = false
                self.refreshControl?.endRefreshing()
                self.noNetworkConnection = false
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                self.tableView.tableFooterView = UIView()
                
                // Reload tableView.
                if startFromBeginning || numberOfNewNotifications > 0 {
                    self.tableView.reloadData()
                }
                
                // Load profilePics.
                if let awsNotifications = response?.items as? [AWSNotification] {
                    for awsNotification in awsNotifications {
                        if let profilePicUrl = awsNotification._profilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                        }
                    }
                }
            })
        })
    }
}

extension NotificationsTableViewController {
    
    // MARK: NotificationCenterActions
    
    func downloadImageNotification(_ notification: NSNotification) {
        guard let imageKey = notification.userInfo?["imageKey"] as? String, let imageType = notification.userInfo?["imageType"] as? ImageType, let imageData = notification.userInfo?["imageData"] as? Data else {
            return
        }
        guard imageType == .userProfilePic else {
            return
        }
        for notification in self.notifications.filter( { $0.user?.profilePicUrl == imageKey } ) {
            guard let notificationIndex = self.notifications.index(of: notification) else {
                continue
            }
            self.notifications[notificationIndex].user?.profilePic = UIImage(data: imageData)
            self.tableView.reloadVisibleRow(IndexPath(row: notificationIndex, section: 0))
        }
    }
    
    func uiApplicationDidBecomeActiveNotification(_ notification: NSNotification) {
        guard self.isLoadingNotifications == false else {
            return
        }
        self.queryNotificationsDateSorted(true)
    }
}

extension NotificationsTableViewController: NotificationsTableViewControllerDelegate {
    
    func scrollToTop() {
        if self.notifications.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
    }
}
