//
//  MessagesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol MessagesTableViewControllerDelegate: class {
    func scrollViewWillBeginDragging()
    func initialMessagesLoaded(_ numberOfInitialMessages: Int)
    func blockedConversation()
}

protocol RemoveMessageDelegate: class {
    func removeMessage(_ messageId: String)
}

class MessagesTableViewController: UITableViewController {
    
    @IBOutlet var loadingTableFooterView: UIView!
    
    var conversationId: String?
    var participant: User?
    weak var messagesTableViewControllerDelegate: MessagesTableViewControllerDelegate?
    weak var removeMessageDelegate: RemoveMessageDelegate?
    
    fileprivate var allMessagesSections: [[Message]] = []
    fileprivate var isLoadingMessages: Bool = true
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    fileprivate var noNetworkConnection: Bool = false
    
    fileprivate var hasLoadedInitialMessages: Bool = false
    fileprivate var currentCalendar: Calendar = Calendar.current
    
    fileprivate var seenConversation: Bool = false
    fileprivate var isVisible: Bool = false
    
    fileprivate var isLoadingBlock = true
    fileprivate var isBlocking: Bool = false
    fileprivate var isLoadingAmIBlocked = true
    fileprivate var amIBlocked: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "OwnMessagesTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "ownMessagesTableSectionHeader")
        self.tableView.register(UINib(nibName: "OtherMessagesTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "otherMessagesTableSectionHeader")
        // Reverse tableView so it starts from the bottom. Do this for every cell as well.
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        if let conversationId = self.conversationId, let userId = self.participant?.userId {
            // Query.
            self.tableView.tableFooterView = self.loadingTableFooterView
            self.getAmIBlocked(userId, conversationId: conversationId)
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.createMessageNotification(_:)), name: NSNotification.Name(CreateMessageNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteMessageNotification(_:)), name: NSNotification.Name(DeleteMessageNotificationKey), object: nil)
        // Special observer to simulate instant messaging.
        NotificationCenter.default.addObserver(self, selector: #selector(self.apnsNewMessageNotificationKey(_:)), name: NSNotification.Name(APNsNewMessageNotificationKey), object: nil)
        // Special observer for refreshing notifications.
        NotificationCenter.default.addObserver(self, selector: #selector(self.uiApplicationDidBecomeActiveNotification(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isVisible = true
        (self.tabBarController as? MainTabBarController)?.updateUnseenConversationsBadge()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.isVisible = false
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController {
            destinationViewController.user = self.participant?.copyUser()
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController =  navigationController.childViewControllers[0] as? ReportTableViewController,
            let cell = sender as? OtherMessageTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            let messageSection = self.allMessagesSections[indexPath.section]
            let message = messageSection[indexPath.row]
            childViewController.userId = message.senderId
            childViewController.reportType = ReportType.user
            childViewController.messageId = message.messageId
            childViewController.removeMessageDelegate = self.removeMessageDelegate
        }
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !self.isLoadingMessages && self.allMessagesSections.count == 0 {
            return 1
        }
        if !self.isLoadingBlock && self.isBlocking || !self.isLoadingAmIBlocked && self.amIBlocked {
            return 1
        }
        return self.allMessagesSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.isLoadingMessages && self.allMessagesSections.count == 0 {
            return 1
        }
        if !self.isLoadingBlock && self.isBlocking || !self.isLoadingAmIBlocked && self.amIBlocked {
            return 1
        }
        return self.allMessagesSections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !self.isLoadingMessages && self.allMessagesSections.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
            cell.emptyMessageLabel.text = "No messages yet"
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
        if !self.isLoadingBlock && self.isBlocking || !self.isLoadingAmIBlocked && self.amIBlocked {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
            if self.isBlocking {
                cell.emptyMessageLabel.text = "You have blocked this user"
            }
            if self.amIBlocked {
                cell.emptyMessageLabel.text = "You are blocked from this user"
            }
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
        let messageSection = self.allMessagesSections[indexPath.section]
        let message = messageSection[indexPath.row]
        if message.senderId == AWSIdentityManager.defaultIdentityManager().identityId {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMessageOwn", for: indexPath) as! OwnMessageTableViewCell
            cell.messageTextLabel.text = message.messageText
            cell.createdLabel.text = message.createdString
            // Show createdLabel only if first message in section.
            if message == messageSection.first && message.createdString != nil {
                cell.showCreatedLabel()
            } else {
                cell.hideCreatedLabel()
            }
            cell.ownMessageTableViewCellDelegate = self
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMessageOther", for: indexPath) as! OtherMessageTableViewCell
            cell.messageTextLabel.text = message.messageText
            cell.createdLabel.text = message.createdString
            // Show createdLabel and profilePicImageView only if first message in section.
            if message == messageSection.first && message.createdString != nil {
                cell.showCreatedLabel()
            } else {
                cell.hideCreatedLabel()
            }
            if message == messageSection.first {
                cell.profilePicImageView.image = self.participant?.profilePicUrl != nil ? self.participant?.profilePic : UIImage(named: "ic_no_profile_pic_feed")
                cell.showProfilePicImageView()
            } else {
                cell.hideProfilePicImageView()
            }
            cell.otherMessageTableViewCellDelegate = self
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        // Load next messages and reset tableFooterView.
        guard indexPath.section == self.allMessagesSections.count - 1 && !self.isLoadingMessages && self.lastEvaluatedKey != nil else {
            return
        }
        guard let conversationId = self.conversationId else {
            return
        }
        guard !self.noNetworkConnection else {
            return
        }
        self.tableView.tableFooterView = self.loadingTableFooterView
        self.isLoadingMessages = true
        self.queryMessagesDateSorted(conversationId, startFromBeginning: false)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.allMessagesSections.count == 0 {
            return 64.0
        }
        return 38.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.allMessagesSections.count == 0 {
            return 64.0
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.messagesTableViewControllerDelegate?.scrollViewWillBeginDragging()
    }
    
    // MARK: Helpers
    
    fileprivate func putMessageInMessageSection(_ message: Message) {
        let sectionsCount = self.allMessagesSections.count
        guard sectionsCount > 0 else {
            // Create section for the first message.
            self.allMessagesSections.append([message])
            return
        }
        guard let createdDate = message.createdDate, let lastCreatedDate = self.allMessagesSections[sectionsCount - 1][0].createdDate else {
            print("No creation dates. This should not happen!")
            return
        }
        guard self.currentCalendar.isDate(createdDate, equalTo: lastCreatedDate, toGranularity: .minute) else {
            // Create section for next minute messages.
            self.allMessagesSections.append([message])
            return
        }
        guard message.senderId == self.allMessagesSections[sectionsCount - 1][0].senderId else {
            // In case different sender, create new section.
            self.allMessagesSections.append([message])
            return
        }
        self.allMessagesSections[sectionsCount - 1].append(message)
    }
    
    fileprivate func putNewMessageInMessageSection(_ message: Message) {
        let sectionsCount = self.allMessagesSections.count
        guard sectionsCount > 0 else {
            // Create section for the first message.
            self.allMessagesSections.append([message])
            return
        }
        guard let createdDate = message.createdDate, let lastCreatedDate = self.allMessagesSections[0][0].createdDate else {
            print("No creation dates. This should not happen!")
            return
        }
        guard self.currentCalendar.isDate(createdDate, equalTo: lastCreatedDate, toGranularity: .minute) else {
            // Create section at the beginning for first message.
            self.allMessagesSections.insert([message], at: 0)
            return
        }
        guard message.senderId == self.allMessagesSections[0][0].senderId else {
            // In case different sender, create new section.
            self.allMessagesSections.insert([message], at: 0)
            return
        }
        self.allMessagesSections[0].insert(message, at: 0)
    }
    
    // MARK: AWS
    
    // Check blockings first.
    fileprivate func getAmIBlocked(_ userId: String, conversationId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getAmIBlockedDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("getAmIBlocked error: \(error)")
                } else {
                    self.isLoadingAmIBlocked = false
                    if let awsBlocks = response?.items as? [AWSBlock], awsBlocks.count != 0 {
                        self.amIBlocked = true
                        self.messagesTableViewControllerDelegate?.blockedConversation()
                        self.tableView.tableFooterView = UIView()
                        self.tableView.reloadData()
                    } else {
                        self.amIBlocked = false
                        // Get if I blocked.
                        self.getBlock(userId, conversationId: conversationId)
                    }
                }
            })
        })
    }
    
    fileprivate func getBlock(_ userId: String, conversationId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getBlockDynamoDB(userId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getBlock error: \(error)")
                } else {
                    self.isLoadingBlock = false
                    if task.result != nil {
                        self.isBlocking = true
                        self.messagesTableViewControllerDelegate?.blockedConversation()
                        self.tableView.tableFooterView = UIView()
                        self.tableView.reloadData()
                    } else {
                        self.isBlocking = false
                        // Load messages if there's no blocking between users.
                        self.isLoadingMessages = true
                        self.queryMessagesDateSorted(conversationId, startFromBeginning: true)
                    }
                }
            })
            return nil
        })
    }
    
    // No refresh so never startFromBeginning.
    fileprivate func queryMessagesDateSorted(_ conversationId: String, startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryMessagesDateSortedDynamoDB(conversationId, lastEvaluatedKey: self.lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryConversationMessagesDateSorted error: \(error!)")
                    self.isLoadingMessages = false
                    self.tableView.tableFooterView = UIView()
                    self.tableView.reloadData()
                    if (error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    return
                }
                if startFromBeginning {
                    self.allMessagesSections = []
                }
                if let awsMessages = response?.items as? [AWSMessage] {
                    for awsMessage in awsMessages {
                        let message = Message(conversationId: awsMessage._conversationId, messageId: awsMessage._messageId, created: awsMessage._created, messageText: awsMessage._messageText, senderId: awsMessage._senderId, recipientId: awsMessage._recipientId)
                        self.putMessageInMessageSection(message)
                    }
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingMessages = false
                self.noNetworkConnection = false
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                self.tableView.tableFooterView = UIView()
                
                // Special case goes only once.
                if !self.hasLoadedInitialMessages {
                    self.hasLoadedInitialMessages = true
                    // Notify parent it can post.
                    self.messagesTableViewControllerDelegate?.initialMessagesLoaded(self.allMessagesSections.count)
                }
                
                // Update seen but only if it's not a fresh conversation and not yet seen.
                if self.allMessagesSections.count > 0 && self.seenConversation == false {
                    self.updateSeenConversation(conversationId)
                }
                
                // Reload tableView.
                self.tableView.reloadData()
            })
        })
    }
    
    // In background.
    fileprivate func updateSeenConversation(_ conversationId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().updateSeenConversationDynamoDB(conversationId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    print("updateSeenConversation error: \(task.error!)")
                    return
                }
                // Update badge.
                (self.tabBarController as? MainTabBarController)?.updateUnseenConversationsIds(conversationId, shouldRemove: true)
                if self.isVisible {
                    (self.tabBarController as? MainTabBarController)?.updateUnseenConversationsBadge()
                }
                // Update flag.
                self.seenConversation = true
            })
            return nil
        })
    }

}

extension MessagesTableViewController {
    
    // MARK: NotificationCenterActions
    
    func createMessageNotification(_ notification: NSNotification) {
        guard let message = notification.userInfo?["message"] as? Message else {
            return
        }
        guard self.conversationId == message.conversationId else {
            return
        }
        self.putNewMessageInMessageSection(message)
        self.tableView.reloadData()
    }
    
    func deleteMessageNotification(_ notification: NSNotification) {
        guard let messageId = notification.userInfo?["messageId"] as? String else {
            return
        }
        var messageSectionIndex: Int?
        var messageRowIndex: Int?
        for (sectionIndex, messagesSection) in self.allMessagesSections.enumerated() {
            for (rowIndex, message) in messagesSection.enumerated() {
                if message.messageId == messageId {
                    messageSectionIndex = sectionIndex
                    messageRowIndex = rowIndex
                    break
                } else {
                    continue
                }
            }
        }
        guard messageSectionIndex != nil && messageRowIndex != nil else {
            return
        }
        self.allMessagesSections[messageSectionIndex!].remove(at: messageRowIndex!)
        if allMessagesSections[messageSectionIndex!].count == 0 {
            self.allMessagesSections.remove(at: messageSectionIndex!)
        }
        self.tableView.reloadData()
        
        // Update ConversationVc with last message.
        if self.allMessagesSections.count > 0, let lastMessage = self.allMessagesSections[0].first {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: DeleteMessageNotificationKey), object: self, userInfo: ["lastMessage": lastMessage.copyMessage()])
        }
    }
    
    func apnsNewMessageNotificationKey(_ notification: NSNotification) {
        guard let message = notification.userInfo?["message"] as? Message else {
            return
        }
        guard let conversationId = self.conversationId, conversationId == message.conversationId else {
            return
        }
        // Ensure message doesn't exist yet so we don't make duplicates.
        guard self.allMessagesSections.flatMap({ $0 }).first(where: { $0.messageId == message.messageId}) == nil else {
            return
        }
        self.putNewMessageInMessageSection(message)
        self.tableView.reloadData()
        // Update seen.
        self.updateSeenConversation(conversationId)
    }
    
    func uiApplicationDidBecomeActiveNotification(_ notification: NSNotification) {
        guard self.isLoadingMessages == false else {
            return
        }
        guard let conversationId = self.conversationId else {
            return
        }
        // Update flag.
        self.seenConversation = false
        // Query.
        self.isLoadingMessages = true
        self.queryMessagesDateSorted(conversationId, startFromBeginning: true)
    }
}

extension MessagesTableViewController: OwnMessageTableViewCellDelegate {
    
    func ownMessageTapped(_ cell: OwnMessageTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        self.parent?.view.endEditing(true)
        let messageSection = self.allMessagesSections[indexPath.section]
        let message = messageSection[indexPath.row]
        guard let messageId = message.messageId else {
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        // Copy.
        let copyAction = UIAlertAction(title: "Copy", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
            // TODO
        })
        alertController.addAction(copyAction)
        // Delete.
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {
            (alert: UIAlertAction) in
            let alertController = UIAlertController(title: "Delete Message?", message: "You and your recipient won't see this message anymore.", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(cancelAction)
            let deleteConfirmAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction) in
                self.removeMessageDelegate?.removeMessage(messageId)
            })
            alertController.addAction(deleteConfirmAction)
            self.present(alertController, animated: true, completion: nil)
        })
        alertController.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension MessagesTableViewController: OtherMessageTableViewCellDelegate {
    
    func profilePicImageViewTapped(_ cell: OtherMessageTableViewCell) {
        self.performSegue(withIdentifier: "segueToProfileVc", sender: cell)
    }
    
    func otherMessageTapped(_ cell: OtherMessageTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        self.parent?.view.endEditing(true)
        let messageSection = self.allMessagesSections[indexPath.section]
        let message = messageSection[indexPath.row]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        // Copy.
        let copyAction = UIAlertAction(title: "Copy", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
            // TODO
        })
        alertController.addAction(copyAction)
        // Report.
        let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive, handler: {
            (alert: UIAlertAction) in
            self.performSegue(withIdentifier: "segueToReportVc", sender: cell)
        })
        alertController.addAction(reportAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension MessagesTableViewController: MessagesViewControllerDelegate {
    
    func toggleTableViewContentOffsetY(_ offsetY: CGFloat) {
        // TODO
    }
}
