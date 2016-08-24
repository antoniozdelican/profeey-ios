//
//  CommentsViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol CommentsViewControllerDelegate {
    func commentPosted(comment: Comment)
}

class CommentsViewController: UIViewController {

    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentFakePlaceholderLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentBarHeightConstraint: NSLayoutConstraint!
    
    private var commentBarBottomConstraintConstant: CGFloat = 0.0
    // Top + Bottom padding between textView and comment bar view.
    private let COMMENT_BAR_TOP_BOTTOM_PADDING: CGFloat = 13.0
    
    var commentsViewControllerDelegate: CommentsViewControllerDelegate?
    var isCommentButton: Bool = false
    
    // TEST
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.commentTextView.delegate = self
        self.commentBarBottomConstraintConstant = self.commentBarBottomConstraint.constant
        self.registerForKeyboardNotifications()
        self.sendButton.enabled = false
        
        // TEST
//        self.currentUser = User(firstName: "Antonio", lastName: "Zdelican", preferredUsername: "toni", profilePicData: UIImageJPEGRepresentation(UIImage(named: "pic_antonio")!, 0.6), profession: "Computer Engineer", about: "Pursuing my Master's Degree in CS. Love to code and design. Currently discovering iOS and energy management.", location: "Lisbon, Portugal", website: "antoniozdelican.com", posts: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.isCommentButton {
            self.commentTextView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.commentTextView.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? CommentsTableViewController {
            self.commentsViewControllerDelegate = destinationViewController
        }
    }
    
    // MARK: IBActions
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        let comment = Comment(user: self.currentUser, commentText: self.commentTextView.text)
        self.commentsViewControllerDelegate?.commentPosted(comment)
        self.commentTextView.text = ""
        self.sendButton.enabled = false
    }
    
    // MARK: Keyboard notifications
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillBeShown(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillBeHidden(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    func keyboardWillBeShown(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let duration = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! Double
        self.commentBarBottomConstraint.constant = keyboardSize.height
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let duration = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! Double
        self.commentBarBottomConstraint.constant = commentBarBottomConstraintConstant
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension CommentsViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        self.commentFakePlaceholderLabel.hidden = !textView.text.isEmpty
        self.sendButton.enabled = !textView.text.trimm().isEmpty
        
        // Adjust textView frame.
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
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