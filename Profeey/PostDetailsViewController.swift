//
//  PostDetailsViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 05/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol PostDetailsViewControllerDelegate: class {
    func toggleTableViewContentOffsetY(_ offsetY: CGFloat)
}

class PostDetailsViewController: UIViewController {
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentFakePlaceholderLabel: UILabel!
    @IBOutlet weak var commentContainerView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentBarHeightConstraint: NSLayoutConstraint!
    
    // If comming from NotificationVc, we have to download the post, otherwise it's already set.
    var shouldDownloadPost: Bool = false
    // If comming from NotificationVc.
    var notificationPostId: String?
    // If comming from ProfileVc or UserCategoriesVc (copied).
    var post: Post?
    // If commentButton was tapped, activate commentTextView.
    var isCommentButton: Bool = false
    
    fileprivate var commentBarBottomConstraintConstant: CGFloat = 0.0
    fileprivate var commentBarHeightConstraintConstant: CGFloat = 49.0
    // Top + Bottom padding between textView and comment bar view.
    fileprivate var commentBarTopBottomPadding: CGFloat = 13.0
    fileprivate weak var postDetailsViewControllerDelegate: PostDetailsViewControllerDelegate?

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
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Awesome! Hides and shows bottomBar only for this Vc.
    
    override var hidesBottomBarWhenPushed: Bool {
        get {
            return navigationController?.topViewController == self
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }
    
    // MARK: Configuration
    
    fileprivate func configureConstants() {
        self.commentBarBottomConstraintConstant = self.commentBarBottomConstraint.constant
        self.commentBarHeightConstraintConstant = self.commentBarHeightConstraint.constant
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PostDetailsTableViewController {
            destinationViewController.shouldDownloadPost = self.shouldDownloadPost
            destinationViewController.notificationPostId = self.notificationPostId
            destinationViewController.post = self.post
            destinationViewController.postDetailsTableViewControllerDelegate = self
            self.postDetailsViewControllerDelegate = destinationViewController
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
        self.commentBarBottomConstraint.constant = keyboardSize.height
        self.postDetailsViewControllerDelegate?.toggleTableViewContentOffsetY(keyboardSize.height)
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        let userInfo: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let duration = userInfo.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
        self.commentBarBottomConstraint.constant = self.commentBarBottomConstraintConstant
        self.postDetailsViewControllerDelegate?.toggleTableViewContentOffsetY(self.commentBarBottomConstraintConstant)
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Helpers
    
    fileprivate func preCreateComment(_ commentText: String) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            return
        }
        var postId: String?
        var postUserId: String?
        // Own post for sure.
        if self.shouldDownloadPost {
            postId = self.notificationPostId
            postUserId = identityId
        } else {
            postId = self.post?.postId
            postUserId = self.post?.userId
        }
        guard postId != nil && postUserId != nil else {
            return
        }
        self.resetCommentBox()
        
        // Real-time creation.
        let commentId = NSUUID().uuidString.lowercased()
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let comment = Comment(userId: identityId, commentId: commentId, created: created, commentText: commentText, postId: postId!, postUserId: postUserId!, user: PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB)
        
        // Notify observers.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreateCommentNotificationKey), object: self, userInfo: ["comment": comment.copyComment()])
        
        // Actual creation.
        self.createComment(commentId, created: created, commentText: commentText, postId: postId!, postUserId: postUserId!)
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

extension PostDetailsViewController: UITextViewDelegate {
    
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

extension PostDetailsViewController: PostDetailsTableViewControllerDelegate {
    
    func scrollViewWillBeginDecelerating() {
        self.view.endEditing(true)
    }
    
    func commentButtonTapped() {
        self.commentTextView.becomeFirstResponder()
    }
}
