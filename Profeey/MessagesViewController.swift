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
    
    var otherUserId: String?
    
    fileprivate var conversationId: String? {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("No identityId. This should not happen!")
            return nil
        }
        guard let otherUserId = self.otherUserId else {
            print("No otherUserId. This should not happen!")
            return nil
        }
        return [identityId, otherUserId].joined(separator: "+conversation+")
    }
    
    fileprivate var messageBarBottomConstraintConstant: CGFloat = 0.0
    fileprivate var messageBarHeightConstraintConstant: CGFloat = 49.0
    fileprivate var tabBarHeight: CGFloat = 49.0
    // Top + Bottom padding between textView and message bar view.
    fileprivate var messageBarTopBottomPadding: CGFloat = 13.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
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
            print("Blaa")
            print(self.conversationId)
            
            destinationViewController.conversationId = self.conversationId
            destinationViewController.messagesTableViewControllerDelegate = self
        }
    }
    
    // MARK: IBActions
    
    @IBAction func sendButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.sendButton.isEnabled = false
        self.createMessage(self.messageTextView.text)
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
    
    fileprivate func resetMessageBox() {
        self.messageTextView.text = ""
        self.messageFakePlaceholderLabel.isHidden = false
        self.sendButton.isEnabled = false
        self.messageBarHeightConstraint.constant = self.messageBarHeightConstraintConstant
    }
    
    // MARK: AWS
    
    fileprivate func createMessage(_ messageText: String) {
        guard let conversationId = self.conversationId, let recipientId = self.otherUserId else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createMessageDynamoDB(conversationId, recipientId: recipientId, messageText: messageText, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    print("createMessage error: \(task.error!)")
                    self.sendButton.isEnabled = true
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: task.error!.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                guard let awsMessage = task.result as? AWSMessage else {
                    print("Not an awsMessage. This should not happen.")
                    return
                }
                let message = Message(conversationId: awsMessage._conversationId, messageId: awsMessage._messageId, created: awsMessage._created, messageText: awsMessage._messageText, senderId: awsMessage._senderId, recipientId: awsMessage._recipientId)
                // Notify observers.
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreateMessageNotificationKey), object: self, userInfo: ["message": message.copyMessage()])
                self.resetMessageBox()
            })
            return nil
        })
    }
    
}

extension MessagesViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.messageFakePlaceholderLabel.isHidden = !textView.text.isEmpty
        self.sendButton.isEnabled = !textView.text.trimm().isEmpty
        
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
}
