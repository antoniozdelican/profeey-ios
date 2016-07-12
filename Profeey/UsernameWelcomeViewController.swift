//
//  UsernameWelcomeViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 13/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSMobileHubHelper

class UsernameWelcomeViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintConstant: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.addTarget(self, action: #selector(UsernameWelcomeViewController.usernameTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.nextButton.addTarget(self, action: #selector(UsernameWelcomeViewController.nextButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.nextButton.enabled = false
        self.toolbarBottomConstraintConstant = self.toolbarBottomConstraint.constant
        self.registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.usernameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.usernameTextField.resignFirstResponder()
    }
    
    // MARK: Tappers
    
    func usernameTextFieldDidChange(sender: UITextField) {
        guard let username = self.usernameTextField.text else {
            return
        }
        let trimmedUsername = username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.nextButton.enabled = !trimmedUsername.isEmpty
    }
    
    func nextButtonTapped(sender: UIButton) {
        self.saveUserPreferredUsername()
    }
    
    // MARK: AWS
    
    private func saveUserPreferredUsername() {
        guard let preferredUsername = self.usernameTextField.text else {
            return
        }
        FullScreenIndicator.show()
        AWSRemoteService.defaultRemoteService().setPreferredUsername(preferredUsername, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                FullScreenIndicator.hide()
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    if self.presentedViewController == nil {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                } else {
                    // Cache locally.
                    LocalService.setPreferredUsernameLocal(preferredUsername)
                    self.performSegueWithIdentifier("segueToProfessionsVc", sender: self)
                }
            })
            return nil
        })
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
