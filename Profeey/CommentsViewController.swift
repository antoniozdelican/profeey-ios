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

//protocol CommentsViewControllerDelegate {
//    func commentPosted(_ comment: Comment)
//}

class CommentsViewController: UIViewController {

    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentFakePlaceholderLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentBarHeightConstraint: NSLayoutConstraint!
    
    var postId: String?
    var postUserId: String?
    var isCommentButton: Bool = false
    //fileprivate var commentsViewControllerDelegate: CommentsViewControllerDelegate?
    
    fileprivate var COMMENT_BAR_BOTTOM_CONSTRAINT_CONSTANT: CGFloat = 0.0
    fileprivate var COMMENT_BAR_HEIGHT: CGFloat = 49.0
    fileprivate var TAB_BAR_HEIGHT: CGFloat = 49.0
    // Top + Bottom padding between textView and comment bar view.
    fileprivate let COMMENT_BAR_TOP_BOTTOM_PADDING: CGFloat = 13.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.configureConstants()
        self.registerForKeyboardNotifications()
        self.commentTextView.delegate = self
        self.sendButton.isEnabled = false
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
        self.COMMENT_BAR_BOTTOM_CONSTRAINT_CONSTANT = self.commentBarBottomConstraint.constant
        self.COMMENT_BAR_HEIGHT = self.commentBarHeightConstraint.constant
        if let height = self.tabBarController?.tabBar.frame.height {
            self.TAB_BAR_HEIGHT = height
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? CommentsTableViewController {
            destinationViewController.postId = self.postId
//            destinationViewController.commentsTableViewControllerDelegate = self
            //self.commentsViewControllerDelegate = destinationViewController
        }
    }
    
    // MARK: IBActions
    
    @IBAction func sendButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.sendButton.isEnabled = false
        self.createComment(self.commentTextView.text)
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
        self.commentBarBottomConstraint.constant = keyboardSize.height - self.TAB_BAR_HEIGHT
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        let userInfo: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let duration = userInfo.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
        self.commentBarBottomConstraint.constant = COMMENT_BAR_BOTTOM_CONSTRAINT_CONSTANT
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: AWS
    
    fileprivate func createComment(_ commentText: String) {
        guard let postId = self.postId, let postUserId = self.postUserId else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createCommentDynamoDB(postId, postUserId: postUserId, commentText: commentText, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("createComment error: \(error)")
                    self.sendButton.isEnabled = true
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    guard let awsComment = task.result as? AWSComment else {
                        return
                    }
                    let comment = Comment(userId: awsComment._userId, commentId: awsComment._commentId, created: awsComment._created, commentText: awsComment._commentText, postId: awsComment._postId, postUserId: awsComment._postUserId, user: PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB)
                    // Notify observers.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreateCommentNotificationKey), object: self, userInfo: ["comment": comment.copyComment()])
                    self.resetCommentBox()
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
        self.commentBarHeightConstraint.constant = self.COMMENT_BAR_HEIGHT
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
        let newHeight = ceil(newFrame.height + self.COMMENT_BAR_TOP_BOTTOM_PADDING)
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
