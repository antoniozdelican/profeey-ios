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
    fileprivate var isLoadingNotifications: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.isLoadingNotifications = true
        self.queryUserNotificationsDateSorted()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let cell = sender as? NotificationTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.user = self.notifications[indexPath.row].user
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
        cell.profilePicImageView.image = notification.user?.profilePic
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
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingNotifications = false
                self.refreshControl?.endRefreshing()
                if let error = error {
                    print("queryUserNotificationsDateSorted error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsNotifications = response?.items as? [AWSNotification], awsNotifications.count > 0 else {
                        self.tableView.reloadData()
                        return
                    }
                    self.notifications = []
                    for awsNotification in awsNotifications {
                        let user = User(userId: awsNotification._notifierUserId, firstName: awsNotification._firstName, lastName: awsNotification._lastName, preferredUsername: awsNotification._preferredUsername, professionName: awsNotification._professionName, profilePicUrl: awsNotification._profilePicUrl)
                        let notification = PRFYNotification(userId: awsNotification._userId, notificationId: awsNotification._notificationId, creationDate: awsNotification._creationDate, notificationType: awsNotification._notificationType, postId: awsNotification._postId, user: user)
                        self.notifications.append(notification)
                    }
                    self.tableView.reloadData()
                    
                    for (index, notification) in self.notifications.enumerated() {
                        if let profilePicUrl = notification.user?.profilePicUrl {
                            let indexPath = IndexPath(row: index, section: 0)
                            self.downloadImage(profilePicUrl, imageType: .userProfilePic, indexPath: indexPath)
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func downloadImage(_ imageKey: String, imageType: ImageType, indexPath: IndexPath) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let content = AWSUserFileManager.defaultUserFileManager().content(withKey: imageKey)
        // TODO check if content.isImage()
        if content.isCached {
            print("Content cached:")
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            switch imageType {
            case .userProfilePic:
                self.notifications[indexPath.row].user?.profilePic = image
                UIView.performWithoutAnimation {
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
            default:
                return
            }
        } else {
            print("Download content:")
            content.download(with: AWSContentDownloadType.ifNewerExists, pinOnCompletion: false,
                progressBlock: {
                    (content: AWSContent?, progress: Progress?) -> Void in
                    // TODO
            },
                completionHandler: {
                    (content: AWSContent?, data: Data?, error: Error?) in
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if let error = error {
                            print("downloadImage error: \(error)")
                        } else {
                            guard let imageData = data else {
                                return
                            }
                            let image = UIImage(data: imageData)
                            switch imageType {
                            case .userProfilePic:
                                self.notifications[indexPath.row].user?.profilePic = image
                                UIView.performWithoutAnimation {
                                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                                }
                            default:
                                return
                            }
                        }
                    })
            })
        }
    }
}
