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
    
    fileprivate var notifications: [PRFYNotification] = []
    fileprivate var isLoadingInitialNotifications: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.isLoadingInitialNotifications = true
        self.queryUserNotificationsDateSorted()
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
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
        if self.isLoadingInitialNotifications {
            return 1
        }
        if self.notifications.count == 0 {
            return 1
        }
        return self.notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoadingInitialNotifications {
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
        cell.profilePicImageView.image = notification.user?.profilePicUrl != nil ? notification.user?.profilePic : UIImage(named: "ic_no_profile_pic_feed")
        cell.messageLabel.attributedText = self.constructNotificationMessage(notification.user?.preferredUsername, notificationMessage: notification.notificationMessage)
        cell.timeLabel.text = notification.creationDateString
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        guard cell is NotificationTableViewCell, let notificationType = self.notifications[indexPath.row].notificationType else {
            return
        }
        if notificationType.intValue == 0 || notificationType.intValue == 1 {
            self.performSegue(withIdentifier: "segueToPostDetailsVc", sender: cell)
        } else if notificationType.intValue == 2 || notificationType.intValue == 3 {
            self.performSegue(withIdentifier: "segueToProfileVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if !(cell is NotificationTableViewCell) {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingInitialNotifications {
            return 112.0
        }
        if self.notifications.count == 0 {
            return 112.0
        }
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingInitialNotifications {
            return 112.0
        }
        if self.notifications.count == 0 {
            return 112.0
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        self.notifications = []
        self.queryUserNotificationsDateSorted()
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
    
    fileprivate func queryUserNotificationsDateSorted() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserNotificationsDateSortedDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                guard error == nil else {
                    print("queryUserNotificationsDateSorted error: \(error!)")
                    // Reset flags and animations that were initiated.
                    self.isLoadingInitialNotifications = false
                    self.refreshControl?.endRefreshing()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    // Reload tableView.
                    self.tableView.reloadData()
                    // Handle error and show banner.
                    let nsError = error as! NSError
                    let errorMessage = nsError.code == -1009 ? "No Internet Connection" : nsError.localizedDescription
                    if nsError.code == -1009 {
                        // TODO No internet connection tableBackgroundView.
                    }
                    (self.navigationController as? PRFYNavigationController)?.showBanner(errorMessage)
                    return
                }
                
                // TODO: check if next.
                self.notifications = []
                if let awsNotifications = response?.items as? [AWSNotification] {
                    for awsNotification in awsNotifications {
                        let user = User(userId: awsNotification._notifierUserId, firstName: awsNotification._firstName, lastName: awsNotification._lastName, preferredUsername: awsNotification._preferredUsername, professionName: awsNotification._professionName, profilePicUrl: awsNotification._profilePicUrl)
                        let notification = PRFYNotification(userId: awsNotification._userId, notificationId: awsNotification._notificationId, creationDate: awsNotification._creationDate, notificationType: awsNotification._notificationType, postId: awsNotification._postId, user: user)
                        self.notifications.append(notification)
                    }
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingInitialNotifications = false
                self.refreshControl?.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // Reload tableView.
                self.tableView.reloadData()
                
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
            self.tableView.reloadRows(at: [IndexPath(row: notificationIndex, section: 0)], with: UITableViewRowAnimation.none)
        }
    }
    
    // MARK: Public
    
    func notificationsTabBarButtonTapped() {
        guard self.notifications.count > 0 else {
            return
        }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
}
