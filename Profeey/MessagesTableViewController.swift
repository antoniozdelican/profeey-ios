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

protocol MessagesTableViewControllerDelegate {
    func scrollViewWillBeginDragging()
    func initialMessagesLoaded(_ numberOfInitialMessages: Int)
}

class MessagesTableViewController: UITableViewController {
    
    @IBOutlet var loadingTableFooterView: UIView!
    
    var conversationId: String?
    var participant: User?
    var messagesTableViewControllerDelegate: MessagesTableViewControllerDelegate?
    
    fileprivate var allMessagesSections: [[Message]] = []
    fileprivate var isLoadingMessages: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    fileprivate var noNetworkConnection: Bool = false
    
    fileprivate var hasLoadedInitialMessages: Bool = false
    fileprivate var currentCalendar: Calendar = Calendar.current

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "OwnMessagesTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "ownMessagesTableSectionHeader")
        self.tableView.register(UINib(nibName: "OtherMessagesTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "otherMessagesTableSectionHeader")
        // Reverse tableView so it starts from the bottom. Do this for every cell as well.
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        if let conversationId = self.conversationId {
            // Query.
            self.tableView.tableFooterView = self.loadingTableFooterView
            self.isLoadingMessages = true
            self.queryConversationMessagesDateSorted(conversationId)
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.createMessageNotification(_:)), name: NSNotification.Name(CreateMessageNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteMessageNotification(_:)), name: NSNotification.Name(DeleteMessageNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !self.isLoadingMessages && self.allMessagesSections.count == 0 {
            return 1
        }
        return self.allMessagesSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.isLoadingMessages && self.allMessagesSections.count == 0 {
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
        let messageSection = self.allMessagesSections[indexPath.section]
        let message = messageSection[indexPath.row]
        if message.senderId == AWSIdentityManager.defaultIdentityManager().identityId {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMessageOwn", for: indexPath) as! OwnMessageTableViewCell
            cell.messageTextLabel.text = message.messageText
            cell.timeLabel.text = message.createdDate?.messageDate
            // Show timeLabel only if first message in section.
            if message == messageSection.first {
                cell.showTimeLabel()
            } else {
                cell.hideTimeLabel()
            }
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMessageOther", for: indexPath) as! OtherMessageTableViewCell
            cell.messageTextLabel.text = message.messageText
            cell.timeLabel.text = message.createdDate?.messageDate
            // Show timeLabel and profilePicImageView only if first message in section.
            if message == messageSection.first {
               cell.profilePicImageView.image = self.participant?.profilePicUrl != nil ? self.participant?.profilePic : UIImage(named: "ic_no_profile_pic_feed")
                cell.showProfilePicAndTimeLabel()
            } else {
                cell.hideProfilePicAndTimeLabel()
            }
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
        self.queryConversationMessagesDateSorted(conversationId)
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
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if self.allMessagesSections.count == 0 {
//            return UIView()
//        }
//        let firstMessageInSection = self.allMessagesSections[section].first
//        if firstMessageInSection?.senderId == AWSIdentityManager.defaultIdentityManager().identityId {
//            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "ownMessagesTableSectionHeader") as? OwnMessagesTableSectionHeader
//            header?.timeLabel.text = firstMessageInSection?.createdDate?.messageDate
//            header?.transform = CGAffineTransform(scaleX: 1, y: -1)
//            return header
//        } else {
//            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "otherMessagesTableSectionHeader") as? OtherMessagesTableSectionHeader
//            header?.timeLabel.text = firstMessageInSection?.createdDate?.messageDate
//            header?.transform = CGAffineTransform(scaleX: 1, y: -1)
//            return header
//        }
//    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.messagesTableViewControllerDelegate?.scrollViewWillBeginDragging()
    }
    
    // MARK: AWS
    
    // No refresh so never startFromBeginning.
    fileprivate func queryConversationMessagesDateSorted(_ conversationId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryConversationMessagesDateSortedDynamoDB(conversationId, lastEvaluatedKey: self.lastEvaluatedKey, completionHandler: {
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
                    self.messagesTableViewControllerDelegate?.initialMessagesLoaded(self.allMessagesSections.count)
                }
                
                // Reload tableView with downloaded messages.
                self.tableView.reloadData()
            })
        })
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
    
    fileprivate func putNewMessageInOwnMessageSection(_ message: Message) {
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
        self.putNewMessageInOwnMessageSection(message)
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
        self.tableView.reloadData()
    }
}
