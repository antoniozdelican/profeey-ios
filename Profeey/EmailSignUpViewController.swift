//
//  EmailSignUpViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 13/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSLambda

class EmailSignUpViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintConstant: CGFloat = 0.0
    var newUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.continueButton.enabled = false
        self.toolbarBottomConstraintConstant = self.toolbarBottomConstraint.constant
        self.registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? EmailSignUpTableViewController {
            destinationViewController.emailSignUpDelegate = self
        }
        if let destinationViewController = segue.destinationViewController as? PasswordSignUpViewController {
            destinationViewController.newUser = self.newUser
        }
    }
    
    // MARK: IBActions
    
    @IBAction func continueButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("segueToPasswordVc", sender: self)
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
        self.toolbarBottomConstraint.constant = keyboardSize.height
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let duration = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! Double
        self.toolbarBottomConstraint.constant = toolbarBottomConstraintConstant
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension EmailSignUpViewController: EmailSignUpDelegate {
    
    func toggleContinueButton(enabled: Bool) {
        self.continueButton.enabled = enabled
    }
    
    func updateEmail(email: String?) {
        self.newUser?.email = email
    }
}
