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
        self.queryUserConversationsDateSorted(true)
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.isLoadingConversations && self.conversations.count == 0 {
            return 1
        }
        return self.conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        cell.timeLabel.text = conversation.lastMessagereatedString
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is ConversationTableViewCell {
            self.performSegue(withIdentifier: "segueToMessagesVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
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
        self.queryUserConversationsDateSorted(false)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.conversations.count == 0 {
            return 64.0
        }
        return 82.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.conversations.count == 0 {
            return 64.0
        }
        return 82.0
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard !self.isLoadingConversations else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.isLoadingConversations = true
        self.queryUserConversationsDateSorted(true)
    }
    
    // MARK: AWS
    
    fileprivate func queryUserConversationsDateSorted(_ startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserConversationsDateSortedDynamoDB(lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryUserConversationsDateSorted error: \(error!)")
                    self.isLoadingConversations = false
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
                    self.conversations = []
                }
                var numberOfNewConversations = 0
                if let awsConversations = response?.items as? [AWSConversation] {
                    for awsConversation in awsConversations {
                        let participant = User(userId: awsConversation._participantId, firstName: awsConversation._participantFirstName, lastName: awsConversation._participantLastName, preferredUsername: awsConversation._participantPreferredUsername, professionName: awsConversation._participantProfessionName, profilePicUrl: awsConversation._participantProfilePicUrl)
                        let conversation = Conversation(userId: awsConversation._userId, conversationId: awsConversation._conversationId, lastMessageText: awsConversation._lastMessageText, lastMessageCreated: awsConversation._lastMessageCreated, participant: participant)
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

}

extension ConversationsTableViewController {
    
    // MARK: NotificationCenterActions
    
    func downloadImageNotification(_ notification: NSNotification) {
        guard let imageKey = notification.userInfo?["imageKey"] as? String, let imageType = notification.userInfo?["imageType"] as? ImageType, let imageData = notification.userInfo?["imageData"] as? Data else {
            return
        }
        guard imageType == .userProfilePic else {
            return
        }
        for conversation in self.conversations.filter( { $0.participant?.profilePicUrl == imageKey } ) {
            guard let conversationIndex = self.conversations.index(of: conversation) else {
                continue
            }
            self.conversations[conversationIndex].participant?.profilePic = UIImage(data: imageData)
            self.tableView.reloadVisibleRow(IndexPath(row: conversationIndex, section: 0))
        }
    }
}

extension ConversationsTableViewController: ConversationsTableViewControllerDelegate {
    
    func scrollToTop() {
        if self.conversations.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
    }
}
