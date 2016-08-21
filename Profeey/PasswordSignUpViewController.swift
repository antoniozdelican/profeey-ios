//
//  PasswordSignUpViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 13/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSDynamoDB

protocol InvalidPasswordSignUpDelegate {
    func toggleWarningTableViewCell(hidden: Bool)
}

protocol PasswordSignUpViewDelegate {
    func removeKeyboard()
}

class PasswordSignUpViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintConstant: CGFloat = 0.0
    var newUser: User?
    var password: String?
    var invalidPasswordSignUpDelegate: InvalidPasswordSignUpDelegate?
    var passwordSignUpViewDelegate: PasswordSignUpViewDelegate?
    
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
        if let destinationViewController = segue.destinationViewController as? PasswordSignUpTableViewController {
            destinationViewController.passwordSignUpDelegate = self
            // Trigger warning table view cell.
            self.invalidPasswordSignUpDelegate = destinationViewController
            
            self.passwordSignUpViewDelegate = destinationViewController
        }
    }
    
    // MARK: IBActions
    
    @IBAction func continueButtonTapped(sender: AnyObject) {
        self.passwordSignUpViewDelegate?.removeKeyboard()
        guard let password = self.password else {
            return
        }
        // Always disable button.
        self.continueButton.enabled = false
        if !password.isPassword() {
            // Show warning message.
            self.invalidPasswordSignUpDelegate?.toggleWarningTableViewCell(false)
        } else {
            self.signUp()
        }
    }
    
    // MARK: AWS
    
    private func signUp() {
        guard let newUser = self.newUser else {
            return
        }
        FullScreenIndicator.show()
        // Generate UUID username.
        let generatedUsername = NSUUID().UUIDString.lowercaseString
        let password: String = self.password!
        let email: String =  newUser.email!
        let firstName: String? = newUser.firstName
        let lastName: String? = newUser.lastName
        
        AWSClientManager.defaultClientManager().signUp(generatedUsername, password: password, email: email, firstName: firstName, lastName: lastName, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                FullScreenIndicator.hide()
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.redirectToWelcome()
                }
            })
            return nil
        })
    }
    
    // MARK: Helpers
    
    private func redirectToWelcome() {
        guard let window = UIApplication.sharedApplication().keyWindow,
            let initialViewController = UIStoryboard(name: "Welcome", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
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
        self.toolbarBottomConstraint.constant = self.toolbarBottomConstraintConstant
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        })
    }

}

extension PasswordSignUpViewController: PasswordSignUpDelegate {
    
    func toggleContinueButton(enabled: Bool) {
        self.continueButton.enabled = enabled
    }
    
    func updatePassword(password: String?) {
        self.password = password
    }
}
