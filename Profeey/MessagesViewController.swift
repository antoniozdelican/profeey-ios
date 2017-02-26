//
//  MessagesViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageFakePlaceholderLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageBarHeightConstraint: NSLayoutConstraint!
    
    var participant: User?
    
    fileprivate var senderId: String? {
        return AWSIdentityManager.defaultIdentityManager().identityId
    }
    fileprivate var recipientId: String? {
        return self.participant?.userId
    }
    fileprivate var conversationId: String? {
        guard let senderId = self.senderId, let recipientId = self.recipientId else {
            print("No ids. This should not happen!")
            return nil
        }
        if senderId < recipientId {
            return [senderId, recipientId].joined(separator: "+conversation+")
        } else {
            return [recipientId, senderId].joined(separator: "+conversation+")
        }
    }
    /*
     Until this gets set, can't post a message!
     This is done to create/delete conversation when first/last message is created/deleted.
    */
    fileprivate var numberOfInitialMessages: Int?
    
    fileprivate var messageBarBottomConstraintConstant: CGFloat = 0.0
    fileprivate var messageBarHeightConstraintConstant: CGFloat = 49.0
    fileprivate var tabBarHeight: CGFloat = 49.0
    // Top + Bottom padding between textView and message bar view.
    fileprivate var messageBarTopBottomPadding: CGFloat = 13.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = self.participant?.preferredUsername
        
        self.configureConstants()
        self.registerForKeyboardNotifications()
        self.messageTextView.delegate = self
        self.sendButton.isEnabled = false
        
        self.messageContainerView.layer.cornerRadius = 4.0
        self.messageContainerView.layer.borderWidth = 0.5
        self.messageContainerView.layer.borderColor = Colors.greyLight.cgColor
        self.messageContainerView.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureConstants() {
        self.messageBarBottomConstraintConstant = self.messageBarBottomConstraint.constant
        self.messageBarHeightConstraintConstant = self.messageBarHeightConstraint.constant
        if let height = self.tabBarController?.tabBar.frame.height {
            self.tabBarHeight = height
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? MessagesTableViewController {
            destinationViewController.conversationId = self.conversationId
            destinationViewController.participant = self.participant // don't need to copy here
            destinationViewController.messagesTableViewControllerDelegate = self
        }
    }
    
    // MARK: IBActions
    
    @IBAction func sendButtonTapped(_ sender: AnyObject) {
        self.sendButton.isEnabled = false
        self.preCreateMessage(self.messageTextView.text)
    }
    
    // MARK: Keyboard notifications
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillBeShown(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillBeHidden(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
    }
    
    func keyboardWillBeShown(_ notification: Notification) {
        let userInfo: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey)! as AnyObject).cgRectValue.size
        let duration = userInfo.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
        self.messageBarBottomConstraint.constant = keyboardSize.height - self.tabBarHeight
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        let userInfo: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let duration = userInfo.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
        self.messageBarBottomConstraint.constant = self.messageBarBottomConstraintConstant
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Helpers
    
    fileprivate func resetMessageBox() {
        self.messageTextView.text = ""
        self.messageFakePlaceholderLabel.isHidden = false
        self.sendButton.isEnabled = false
        self.messageBarHeightConstraint.constant = self.messageBarHeightConstraintConstant
    }
    
    fileprivate func preCreateMessage(_ messageText: String) {
        guard let conversationId = self.conversationId, let numberOfInitialMessages = self.numberOfInitialMessages else {
            return
        }
        guard let senderId = self.senderId, let recipientId = self.recipientId else {
            return
        }
        self.resetMessageBox()
        
        // Real-time creation.
        let messageId = NSUUID().uuidString.lowercased()
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let message = Message(conversationId: conversationId, messageId: messageId, created: created, messageText: messageText, senderId: senderId, recipientId: recipientId)
        
        // Notify observers.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreateMessageNotificationKey), object: self, userInfo: ["message": message.copyMessage()])
        
        // Actual creation.
        self.createMessage(messageText, conversationId: conversationId, messageId: messageId, created: created, senderId: senderId, recipientId: recipientId, numberOfInitialMessages: numberOfInitialMessages)
    }
    
    // MARK: AWS
    
    fileprivate func createMessage(_ messageText: String, conversationId: String, messageId: String, created: NSNumber, senderId: String, recipientId: String, numberOfInitialMessages: Int) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createMessageDynamoDB(conversationId, recipientId: recipientId, messageText: messageText, messageId: messageId, created: created, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    print("createMessage error: \(task.error!)")
                    if (task.error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                    }
                    // Notify of message error.
                    // TODO
                    return
                }
                
                // Notify that message has been sent.
                // TODO
                
                // Create conversation if it's a first message between users.
                if numberOfInitialMessages == 0 {
                    let participant = User(userId: self.participant?.userId, firstName: self.participant?.firstName, lastName: self.participant?.lastName, preferredUsername: self.participant?.preferredUsername, professionName: self.participant?.professionName, profilePicUrl: self.participant?.profilePicUrl)
                    let conversation = Conversation(userId: senderId, conversationId: conversationId, lastMessageText: messageText, lastMessageCreated: created, lastMessageSeen: NSNumber(value: 1), participant: participant)
                    
                    // Notify observers.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreateConversationNotificationKey), object: self, userInfo: ["conversation": conversation.copyConversation()])
                    
                    // Actual creation.
                    self.createConversation(messageText, conversationId: conversationId, participantId: recipientId)
                    
                    // Set to 1 to ensure creation is not repeated! (BUG).
                    self.numberOfInitialMessages = 1
                }
            })
            return nil
        })
    }
    
    // In background.
    fileprivate func createConversation(_ messageText: String, conversationId: String, participantId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createConversationDynamoDB(messageText, conversationId: conversationId, participantId: participantId, participantFirstName: self.participant?.firstName, participantLastName: self.participant?.lastName, participantPreferredUsername: self.participant?.preferredUsername, participantProfessionName: self.participant?.professionName, participantProfilePicUrl: self.participant?.profilePicUrl, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("createConversation error: \(error)")
                }
            })
            return nil
        })
    }
    
}

extension MessagesViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.messageFakePlaceholderLabel.isHidden = !textView.text.isEmpty
        
        // Check if numberOfInitialMessages is set.
        if self.numberOfInitialMessages != nil {
            self.sendButton.isEnabled = !textView.text.trimm().isEmpty
        }
        
        // Adjust textView frame.
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        
        // Adjust message bar.
        let newHeight = ceil(newFrame.height + self.messageBarTopBottomPadding)
        if newHeight != self.messageBarHeightConstraint.constant {
            self.messageBarHeightConstraint.constant = newHeight
        }
    }
}

extension MessagesViewController: MessagesTableViewControllerDelegate {
    
    func scrollViewWillBeginDragging() {
        self.view.endEditing(true)
    }
    
    func initialMessagesLoaded(_ numberOfInitialMessages: Int) {
        if self.numberOfInitialMessages == nil {
            self.numberOfInitialMessages = numberOfInitialMessages
        }
    }
    
    func blockedConversation() {
        self.messageTextView.isEditable = false
        self.sendButton.isEnabled = false
    }
}
