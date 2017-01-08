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
}

class MessagesTableViewController: UITableViewController {
    
    var conversationId: String?
    var messagesTableViewControllerDelegate: MessagesTableViewControllerDelegate?
    
    fileprivate var messages: [Message] = []
    fileprivate var isLoadingMessages: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Reverse tableView so it starts from the bottom. Do this for every cell as well.
        self.tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI))
        
        print("HERE")
        print(self.conversationId)
        
        if let conversationId = self.conversationId {
            self.isLoadingMessages = true
            self.queryConversationMessagesDateSorted(conversationId)
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.createMessageNotification(_:)), name: NSNotification.Name(CreateMessageNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingMessages {
            return 1
        }
        if self.messages.count == 0 {
            return 1
        }
        return self.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoadingMessages {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellLoading", for: indexPath) as! LoadingTableViewCell
            cell.activityIndicator?.startAnimating()
            cell.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI))
            return cell
        }
        if self.messages.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
            cell.emptyMessageLabel.text = "No messages yet"
            cell.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI))
            return cell
        }
        let message = self.messages[indexPath.row]
        if message.senderId == AWSIdentityManager.defaultIdentityManager().identityId {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMessageOwn", for: indexPath) as! MessageOwnTableViewCell
            cell.messageTextLabel.text = message.messageText
            cell.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMessageOther", for: indexPath) as! MessageOtherTableViewCell
            cell.messageTextLabel.text = message.messageText
            cell.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI))
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingMessages || self.messages.count == 0 {
            return 64.0
        }
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingMessages || self.messages.count == 0 {
            return 64.0
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.messagesTableViewControllerDelegate?.scrollViewWillBeginDragging()
    }
    
    // MARK: AWS
    
    fileprivate func queryConversationMessagesDateSorted(_ conversationId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryConversationMessagesDateSortedDynamoDB(conversationId, lastEvaluatedKey: self.lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryConversationMessagesDateSorted error: \(error!)")
                    self.isLoadingMessages = false
                    self.tableView.reloadData()
                    return
                }
                var numberOfOldMessages = 0
                if let awsMessages = response?.items as? [AWSMessage] {
                    for awsMessage in awsMessages {
                        let message = Message(conversationId: awsMessage._conversationId, messageId: awsMessage._messageId, created: awsMessage._created, messageText: awsMessage._messageText, senderId: awsMessage._senderId, recipientId: awsMessage._recipientId)
                        self.messages.append(message)
                        numberOfOldMessages += 1
                    }
                }
                // Reset flags and animations that were initiated.
                if self.isLoadingMessages {
                    self.isLoadingMessages = false
                }
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                
                // Reload tableView with downloaded messages.
                if numberOfOldMessages > 0 {
                    self.tableView.reloadData()
                }
            })
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
        self.messages.insert(message, at: 0)
        
        // TODO check if can go without this.
        if self.messages.count == 1 {
            self.tableView.reloadData()
        } else {
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.fade)
        }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
    }
}
