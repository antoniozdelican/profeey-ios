//
//  EmailSignUpViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 13/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class EmailSignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var invalidEmailView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintConstant: CGFloat = 0.0
    
    var fullName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        self.emailTextField.addTarget(self, action: #selector(EmailSignUpViewController.emailTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.invalidEmailView.layer.borderColor = Colors.red.CGColor
        self.invalidEmailView.layer.borderWidth = 1.0
        self.invalidEmailView.hidden = true
        self.nextButton.addTarget(self, action: #selector(EmailSignUpViewController.nextButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.nextButton.enabled = false
        self.toolbarBottomConstraintConstant = self.toolbarBottomConstraint.constant
        self.registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.emailTextField.resignFirstResponder()
    }
    

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? PasswordSignUpViewController {
            destinationViewController.fullName = self.fullName
            destinationViewController.email = self.emailTextField.text
        }
    }
    
    // MARK: Tappers
    
    func emailTextFieldDidChange(sender: UITextField) {
        guard let email = self.emailTextField.text else {
            return
        }
        if email.isEmpty {
            self.nextButton.enabled = false
        } else {
            self.nextButton.enabled = true
        }
    }
    
    func nextButtonTapped(sender: UIButton) {
        guard let email = self.emailTextField.text else {
            return
        }
        if self.isEmailValid(email) {
            self.performSegueWithIdentifier("segueToPasswordVc", sender: self)
        } else {
            // Show error box if it isn't already shown.
            if self.invalidEmailView.hidden {
                self.invalidEmailView.hidden = false
                self.invalidEmailView.alpha = 1.0
                UIView.animateWithDuration(
                    0.4,
                    delay: 2.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {
                        self.invalidEmailView.alpha = 0.0
                    },
                    completion: {
                        (finished) in
                        self.invalidEmailView.hidden = true
                })
            }
        }
    }
    
    // MARK: Helpers
    
    func isEmailValid(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
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
