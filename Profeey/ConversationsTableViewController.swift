//
//  ConversationsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class ConversationsTableViewController: UITableViewController {
    
    @IBOutlet var loadingTableFooterView: UIView!
    
    fileprivate var conversations: [Conversation] = []
    fileprivate var isLoadingConversations: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    fileprivate var noNetworkConnection: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Query.
        self.tableView.tableFooterView = self.loadingTableFooterView
        self.isLoadingConversations = true
        self.queryConversationsDateSorted(true)
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.createMessageNotification(_:)), name: NSNotification.Name(CreateMessageNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteMessageNotification(_:)), name: NSNotification.Name(DeleteMessageNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createConversationNotification(_:)), name: NSNotification.Name(CreateConversationNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
        // Special observer to simulate instant messaging.
        NotificationCenter.default.addObserver(self, selector: #selector(self.apnsNewMessageNotificationKey(_:)), name: NSNotification.Name(APNsNewMessageNotificationKey), object: nil)
        // Special observer for refreshing notifications.
        NotificationCenter.default.addObserver(self, selector: #selector(self.uiApplicationDidBecomeActiveNotification(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // For unseenConversation bug.
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? MessagesViewController,
            let cell = sender as? ConversationTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.participant = self.conversations[indexPath.row].participant?.copyUser()
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if self.noNetworkConnection {
            return 1
        }
        if !self.isLoadingConversations && self.conversations.count == 0 {
            return 1
        }
        return self.conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellAdd", for: indexPath) as! AddTableViewCell
            cell.titleLabel.text = "New Message"
            return cell
        }
        if self.noNetworkConnection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoNetwork", for: indexPath) as! NoNetworkTableViewCell
            return cell
        }
        if !self.isLoadingConversations && self.conversations.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
            cell.emptyMessageLabel.text = "No conversations yet."
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellConversation", for: indexPath) as! ConversationTableViewCell
        let conversation = self.conversations[indexPath.row]
        cell.profilePicImageView.image = conversation.participant?.profilePicUrl != nil ? conversation.participant?.profilePic : UIImage(named: "ic_no_profile_pic_feed")
        cell.preferredUsernameLabel.text = conversation.participant?.preferredUsername
        cell.lastMessageLabel.text = conversation.lastMessageText
        cell.createdLabel.text = conversation.lastMessagerCeatedString
        
        // TODO: fix this
        
        if let conversationId = conversation.conversationId, let unseenConversationsIds = (self.tabBarController as? MainTabBarController)?.unseenConversationsIds, unseenConversationsIds.contains(conversationId) {
            cell.createdLabel.textColor = Colors.red
            cell.unseenConversationView.isHidden = false
        } else {
            cell.createdLabel.textColor = Colors.grey
            cell.unseenConversationView.isHidden = true
        }
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is NoNetworkTableViewCell {
            // Query.
            self.isLoadingConversations = true
            self.tableView.tableFooterView = self.loadingTableFooterView
            self.queryConversationsDateSorted(true)
        }
        if cell is ConversationTableViewCell {
            self.performSegue(withIdentifier: "segueToMessagesVc", sender: cell)
        }
        if cell is AddTableViewCell {
            self.performSegue(withIdentifier: "segueToNewMessageVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        // Skip section 0.
        guard indexPath.section != 0 else {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            return
        }
        if !(cell is ConversationTableViewCell) {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
        // Query next conversations and reset tableFooterView.
        guard indexPath.row == self.conversations.count - 1 && !self.isLoadingConversations && self.lastEvaluatedKey != nil else {
            return
        }
        guard !self.noNetworkConnection else {
            return
        }
        self.tableView.tableFooterView = self.loadingTableFooterView
        self.isLoadingConversations = true
        self.queryConversationsDateSorted(false)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44.0
        }
        if self.noNetworkConnection {
            return 112.0
        }
        if self.conversations.count == 0 {
            return 60.0
        }
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44.0
        }
        if self.noNetworkConnection {
            return 112.0
        }
        if self.conversations.count == 0 {
            return 60.0
        }
        return 60.0
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard !self.isLoadingConversations else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.isLoadingConversations = true
        self.queryConversationsDateSorted(true)
    }
    
    // MARK: AWS
    
    fileprivate func queryConversationsDateSorted(_ startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryConversationsDateSortedDynamoDB(lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryUserConversationsDateSorted error: \(error!)")
                    self.isLoadingConversations = false
                    self.refreshControl?.endRefreshing()
                    self.tableView.tableFooterView = UIView()
                    if (error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    self.tableView.reloadData()
                    return
                }
                if startFromBeginning {
                    self.conversations = []
                }
                var numberOfNewConversations = 0
                if let awsConversations = response?.items as? [AWSConversation] {
                    for awsConversation in awsConversations {
                        let participant = User(userId: awsConversation._participantId, firstName: awsConversation._participantFirstName, lastName: awsConversation._participantLastName, preferredUsername: awsConversation._participantPreferredUsername, professionName: awsConversation._participantProfessionName, profilePicUrl: awsConversation._participantProfilePicUrl)
                        let conversation = Conversation(userId: awsConversation._userId, conversationId: awsConversation._conversationId, lastMessageText: awsConversation._lastMessageText, lastMessageCreated: awsConversation._lastMessageCreated, lastMessageSeen: awsConversation._lastMessageSeen, participant: participant)
                        self.conversations.append(conversation)
                        numberOfNewConversations += 1
                    }
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingConversations = false
                self.refreshControl?.endRefreshing()
                self.noNetworkConnection = false
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                self.tableView.tableFooterView = UIView()
                
                // Reload tableView.
                if startFromBeginning || numberOfNewConversations > 0 {
                    self.tableView.reloadData()
                }
                
                // Load profilePics.
                if let awsConversations = response?.items as? [AWSConversation] {
                    for awsConversation in awsConversations {
                        if let profilePicUrl = awsConversation._participantProfilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                        }
                    }
                }
            })
        })
    }
    
    // Called only if apnsNewMessage arrives and conversation doesn't yet exists.
    fileprivate func getConversation(_ conversationId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getConversationDynamoDB(conversationId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    print("getConversation error: \(task.error!)")
                    return
                }
                guard let awsConversation = task.result as? AWSConversation else {
                    print("getConversation error: Not AWSConversation. This should not happen.")
                    return
                }
                let participant = User(userId: awsConversation._participantId, firstName: awsConversation._participantFirstName, lastName: awsConversation._participantLastName, preferredUsername: awsConversation._participantPreferredUsername, professionName: awsConversation._participantProfessionName, profilePicUrl: awsConversation._participantProfilePicUrl)
                let conversation = Conversation(userId: awsConversation._userId, conversationId: awsConversation._conversationId, lastMessageText: awsConversation._lastMessageText, lastMessageCreated: awsConversation._lastMessageCreated, lastMessageSeen: awsConversation._lastMessageSeen, participant: participant)
                self.conversations.insert(conversation, at: 0)
                
                // Reload tableView.
                self.tableView.reloadData()
                
                // Load profilePic.
                if let profilePicUrl = awsConversation._participantProfilePicUrl {
                    PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                }
            })
            return nil
        })
    }
    
    // MARK: Helper
    
    fileprivate func updateConversationWithLastMessage(_ conversationId: String, message: Message) {
        guard let conversationIndex = self.conversations.index(where: { $0.conversationId == conversationId }) else {
            return
        }
        // Update conversation.
        let conversation = self.conversations[conversationIndex]
        conversation.lastMessageCreated = message.created
        conversation.lastMessageText = message.messageText
        self.conversations.remove(at: conversationIndex)
        self.conversations.insert(conversation, at: 0)
        self.tableView.reloadData()
    }

}

extension ConversationsTableViewController {
    
    // MARK: NotificationCenterActions
    
    func createMessageNotification(_ notification: NSNotification) {
        guard let message = notification.userInfo?["message"] as? Message, let conversationId = message.conversationId else {
            return
        }
        guard let _ = self.conversations.index(where: { $0.conversationId == conversationId }) else {
            return
        }
        self.updateConversationWithLastMessage(conversationId, message: message)
    }
    
    // Only updates if necessary aka if lastMessage is sent.
    func deleteMessageNotification(_ notification: NSNotification) {
        guard let lastMessage = notification.userInfo?["lastMessage"] as? Message, let conversationId = lastMessage.conversationId else {
            return
        }
        guard let _ = self.conversations.index(where: { $0.conversationId == conversationId }) else {
            return
        }
        self.updateConversationWithLastMessage(conversationId, message: lastMessage)
    }
    
    func createConversationNotification(_ notification: NSNotification) {
        guard let conversation = notification.userInfo?["conversation"] as? Conversation else {
            return
        }
        // Ensure conversation doesn't exist yet so we don't make duplicates.
        guard self.conversations.index(where: { $0.conversationId == conversation.conversationId }) == nil else {
            return
        }
        self.conversations.insert(conversation, at: 0)
        self.tableView.reloadData()
        if let profilePicUrl = conversation.participant?.profilePicUrl {
            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
        }
    }
    
    func downloadImageNotification(_ notification: NSNotification) {
        guard let imageKey = notification.userInfo?["imageKey"] as? String, let imageType = notification.userInfo?["imageType"] as? ImageType, let imageData = notification.userInfo?["imageData"] as? Data else {
            return
        }
        guard imageType == .userProfilePic else {
            return
        }
        for conversation in self.conversations.filter( { $0.participant?.profilePicUrl == imageKey } ) {
            if let conversationIndex = self.conversations.index(of: conversation) {
                // Update data source and cells.
                self.conversations[conversationIndex].participant?.profilePic = UIImage(data: imageData)
                (self.tableView.cellForRow(at: IndexPath(row: conversationIndex, section: 1)) as? ConversationTableViewCell)?.profilePicImageView.image = self.conversations[conversationIndex].participant?.profilePic
            }
        }
    }
    
    func apnsNewMessageNotificationKey(_ notification: NSNotification) {
        guard let message = notification.userInfo?["message"] as? Message, let conversationId = message.conversationId else {
            return
        }
        guard self.isLoadingConversations == false else {
            return
        }
        // If conversation already exists, only update with new message, otherwise get entire conversation.
        if let _ = self.conversations.index(where: { $0.conversationId == conversationId }) {
            self.updateConversationWithLastMessage(conversationId, message: message)
        } else {
            self.getConversation(conversationId)
        }
    }
    
    func uiApplicationDidBecomeActiveNotification(_ notification: NSNotification) {
        guard self.isLoadingConversations == false else {
            return
        }
        self.isLoadingConversations = true
        self.queryConversationsDateSorted(true)
    }
}

extension ConversationsTableViewController: ConversationsTableViewControllerDelegate {
    
    func scrollToTop() {
        if self.conversations.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
    }
}
