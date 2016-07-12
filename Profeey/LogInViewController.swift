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

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintConstant: CGFloat = 0.0
    var isEmailEmpty: Bool = true
    var isPasswordEmpty: Bool = true
    
    var passwordAuthenticationCompletion: AWSCognitoIdentityPasswordAuthenticationDetails!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        self.emailTextField.addTarget(self, action: #selector(LogInViewController.emailTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.emailTextField.delegate = self
        self.passwordTextField.addTarget(self, action: #selector(LogInViewController.passwordTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.passwordTextField.delegate = self
        self.logInButton.addTarget(self, action: #selector(LogInViewController.logInButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.logInButton.enabled = false
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
        self.passwordTextField.resignFirstResponder()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Tappers
    
    func emailTextFieldDidChange(sender: UITextField) {
        guard let email = self.emailTextField.text else {
            return
        }
        self.isEmailEmpty = email.isEmpty
        self.logInButton.enabled = (!self.isEmailEmpty && !self.isPasswordEmpty)
    }
    
    func passwordTextFieldDidChange(sender: UITextField) {
        guard let password = self.passwordTextField.text else {
            return
        }
        self.isPasswordEmpty = password.isEmpty
        self.logInButton.enabled = (!self.isEmailEmpty && !self.isPasswordEmpty)
    }
    
    func logInButtonTapped(sender: UIButton) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.logIn()
    }
    
    // MARK: AWS
    
    private func logIn() {
        guard let username = self.emailTextField.text, password = self.passwordTextField.text else {
            return
        }
        FullScreenIndicator.show()
        AWSRemoteService.defaultRemoteService().logIn(username, password: password, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                FullScreenIndicator.hide()
                if let error = task.error {
                    let alertController = UIAlertController(title: "Something went wrong", message: error.userInfo["message"] as? String, preferredStyle: .Alert)
                    let alertAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alertController.addAction(alertAction)
                    if self.presentedViewController == nil {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                } else {
                    print("Signed in")
                    self.redirectToMain()
                }
            })
            return nil
        })
    }
    
    private func redirectToMain() {
        guard let window = UIApplication.sharedApplication().keyWindow,
        let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
            return
        }
        window.rootViewController = initialViewController
    }
    
    // MARK: IBActions
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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

extension LogInViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        // For jumping bug
        self.emailTextField.layoutIfNeeded()
        self.passwordTextField.layoutIfNeeded()
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
