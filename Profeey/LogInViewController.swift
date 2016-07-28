//
//  LogInViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 13/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSMobileHubHelper

class LogInViewController: UIViewController {

    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintConstant: CGFloat = 0.0
    var passwordAuthenticationCompletion: AWSCognitoIdentityPasswordAuthenticationDetails?
    
    var username: String?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.logInButton.enabled = false
        self.toolbarBottomConstraintConstant = self.toolbarBottomConstraint.constant
        self.registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? LogInTableViewController {
            destinationViewController.logInDelegate = self
        }
    }
    
    // MARK: AWS
    
//    private func logIn() {
//        guard let username = self.emailTextField.text, password = self.passwordTextField.text else {
//            return
//        }
//        FullScreenIndicator.show()
//        AWSClientManager.defaultClientManager().logIn(username, password: password, completionHandler: {
//            (task: AWSTask) in
//            dispatch_async(dispatch_get_main_queue(), {
//                FullScreenIndicator.hide()
//                if let error = task.error {
//                    let alertController = UIAlertController(title: "Something went wrong", message: error.userInfo["message"] as? String, preferredStyle: .Alert)
//                    let alertAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
//                    alertController.addAction(alertAction)
//                    if self.presentedViewController == nil {
//                        self.presentViewController(alertController, animated: true, completion: nil)
//                    }
//                } else {
//                    print("Signed in")
//                    self.redirectToMain()
//                }
//            })
//            return nil
//        })
//    }
    
    // MARK: IBActions
    
    @IBAction func logInButtonTapped(sender: AnyObject) {
        self.logIn()
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: AWS
    
    private func logIn() {
        guard let username = self.username, let password = self.password else {
            return
        }
        FullScreenIndicator.show()
        AWSClientManager.defaultClientManager().logIn(username, password: password, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                FullScreenIndicator.hide()
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                else {
                    self.redirectToMain()
                }
            })
            return nil
        })
    }
    
    // MARK: Helpers
    
    private func redirectToMain() {
        guard let window = UIApplication.sharedApplication().keyWindow,
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
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
        self.toolbarBottomConstraint.constant = toolbarBottomConstraintConstant
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension LogInViewController: LogInDelegate {
    
    func toggleLogInButton(enabled: Bool) {
        self.logInButton.enabled = enabled
    }
    
    func updateUsernamePassword(username: String?, password: String?) {
        self.username = username
        self.password = password
    }
}

extension LogInViewController: AWSCognitoIdentityPasswordAuthentication {
    
    func getPasswordAuthenticationDetails(authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource) {
        // Do nothing.
    }
    
    func didCompletePasswordAuthenticationStepWithError(error: NSError) {
        // Do nothing.
    }
}
