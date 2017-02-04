//
//  CommentsViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB


class CommentsViewController: UIViewController {

    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentFakePlaceholderLabel: UILabel!
    @IBOutlet weak var commentContainerView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentBarHeightConstraint: NSLayoutConstraint!
    
    var postId: String?
    var postUserId: String?
    var isCommentButton: Bool = false
    
    fileprivate var commentBarBottomConstraintConstant: CGFloat = 0.0
    fileprivate var commentBarHeightConstraintConstant: CGFloat = 49.0
    fileprivate var tabBarHeight: CGFloat = 49.0
    // Top + Bottom padding between textView and comment bar view.
    fileprivate var commentBarTopBottomPadding: CGFloat = 13.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.configureConstants()
        self.registerForKeyboardNotifications()
        self.commentTextView.delegate = self
        self.sendButton.isEnabled = false
        
        self.commentContainerView.layer.cornerRadius = 4.0
        self.commentContainerView.layer.borderWidth = 0.5
        self.commentContainerView.layer.borderColor = Colors.greyLight.cgColor
        self.commentContainerView.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isCommentButton {
            self.commentTextView.becomeFirstResponder()
        }
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
        self.commentBarBottomConstraintConstant = self.commentBarBottomConstraint.constant
        self.commentBarHeightConstraintConstant = self.commentBarHeightConstraint.constant
        if let height = self.tabBarController?.tabBar.frame.height {
            self.tabBarHeight = height
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? CommentsTableViewController {
            destinationViewController.postId = self.postId
            destinationViewController.commentsTableViewControllerDelegate = self
        }
    }
    
    // MARK: IBActions
    
    @IBAction func sendButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.sendButton.isEnabled = false
        self.preCreateComment(self.commentTextView.text)
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
        self.commentBarBottomConstraint.constant = keyboardSize.height - self.tabBarHeight
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        let userInfo: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let duration = userInfo.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
        self.commentBarBottomConstraint.constant = self.commentBarBottomConstraintConstant
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Helpers
    
    fileprivate func preCreateComment(_ commentText: String) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId, let postId = self.postId, let postUserId = self.postUserId else {
            return
        }
        self.resetCommentBox()
        
        // Real-time creation.
        let commentId = NSUUID().uuidString.lowercased()
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let comment = Comment(userId: identityId, commentId: commentId, created: created, commentText: commentText, postId: postId, postUserId: postUserId, user: PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB)
        
        // Notify observers.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreateCommentNotificationKey), object: self, userInfo: ["comment": comment.copyComment()])
        
        // Actual creation.
        self.createComment(commentId, created: created, commentText: commentText, postId: postId, postUserId: postUserId)
    }
    
    // MARK: AWS
    
    // In background.
    fileprivate func createComment(_ commentId: String, created: NSNumber, commentText: String, postId: String, postUserId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createCommentDynamoDB(commentId, created: created, commentText: commentText, postId: postId, postUserId: postUserId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("createComment error: \(error)")
                    // Undo UI.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: DeleteCommentNotificationKey), object: self, userInfo: ["commentId": commentId, "postId": postId])
                }
            })
            return nil
        })
    }
    
    // MARK: Helpers
    
    fileprivate func resetCommentBox() {
        self.commentTextView.text = ""
        self.commentFakePlaceholderLabel.isHidden = false
        self.sendButton.isEnabled = false
        self.commentBarHeightConstraint.constant = self.commentBarHeightConstraintConstant
    }
}

extension CommentsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.commentFakePlaceholderLabel.isHidden = !textView.text.isEmpty
        self.sendButton.isEnabled = !textView.text.trimm().isEmpty
        
        // Adjust textView frame.
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        
        // Adjust comment bar.
        let newHeight = ceil(newFrame.height + self.commentBarTopBottomPadding)
        if newHeight != self.commentBarHeightConstraint.constant {
            self.commentBarHeightConstraint.constant = newHeight
        }
    }
}

extension CommentsViewController: CommentsTableViewControllerDelegate {
    
    func scrollViewWillBeginDragging() {
        self.view.endEditing(true)
    }
}
