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

class PasswordSignUpViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var invalidPasswordView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var legalLabel: UILabel!
    
    var toolbarBottomConstraintConstant: CGFloat = 0.0
    
    var fullName: String?
    var email: String?
    
    private var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        self.passwordTextField.addTarget(self, action: #selector(PasswordSignUpViewController.passwordTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.invalidPasswordView.layer.borderColor = Colors.red.CGColor
        self.invalidPasswordView.layer.borderWidth = 1.0
        self.invalidPasswordView.hidden = true
        self.signUpButton.addTarget(self, action: #selector(PasswordSignUpViewController.signUpButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.signUpButton.enabled = false
        self.toolbarBottomConstraintConstant = self.toolbarBottomConstraint.constant
        self.registerForKeyboardNotifications()
        
        // Legal label
        let legalMutableAttributedString = NSMutableAttributedString(string: "By signing up, you agree to our ")
        let termsOfServiceAttributedString = NSAttributedString(string: "Terms of service", attributes: [NSForegroundColorAttributeName: Colors.blue])
        let privacyPolicyAttributedString = NSAttributedString(string: "Privacy Policy", attributes: [NSForegroundColorAttributeName: Colors.blue])
        legalMutableAttributedString.appendAttributedString(termsOfServiceAttributedString)
        legalMutableAttributedString.appendAttributedString(NSAttributedString(string: " and "))
        legalMutableAttributedString.appendAttributedString(privacyPolicyAttributedString)
        legalMutableAttributedString.appendAttributedString(NSAttributedString(string: "."))
        self.legalLabel.attributedText = legalMutableAttributedString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.passwordTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    func passwordTextFieldDidChange(sender: UITextField) {
        guard let password = self.passwordTextField.text else {
            return
        }
        if password.isEmpty {
            self.signUpButton.enabled = false
        } else {
            self.signUpButton.enabled = true
        }
    }
    
    func signUpButtonTapped(sender: UIButton) {
        guard let password = self.passwordTextField.text else {
            return
        }
        if self.isPasswordValid(password) {
            self.signUp()
        } else {
            // Show error box if it isn't already shown.
            if self.invalidPasswordView.hidden {
                self.invalidPasswordView.hidden = false
                self.invalidPasswordView.alpha = 1.0
                UIView.animateWithDuration(
                    0.4,
                    delay: 2.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {
                        self.invalidPasswordView.alpha = 0.0
                    },
                    completion: {
                        (finished) in
                        self.invalidPasswordView.hidden = true
                })
            }
        }
    }
    
    // MARK: Helpers
    
    func isPasswordValid(password: String) -> Bool {
        let trimmedPassword = password.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return (trimmedPassword.characters.count >= 8) ? true : false
    }
    
    private func redirectToWelcome() {
        guard let window = UIApplication.sharedApplication().keyWindow,
            let initialViewController = UIStoryboard(name: "Welcome", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    // MARK: AWS
    
    private func signUp() {
        guard let fullName = self.fullName, let email = self.email, password = self.passwordTextField.text else {
            return
        }
        FullScreenIndicator.show()
        
        // Generate UUID username
        self.username = NSUUID().UUIDString
        AWSRemoteService.defaultRemoteService().signUp(username, password: password, email: email, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                FullScreenIndicator.hide()
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    if self.presentedViewController == nil {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                } else {
                    self.redirectToWelcome()
                }
            })
            // NOT SURE IF THIS CAN GO PARALLEL
            self.setFullName(fullName)
            return nil
        })
    }
    
    private func setFullName(fullName: String) {
        AWSRemoteService.defaultRemoteService().setFullName(fullName, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                var errorMessage = "Error Occurred: \(error.localizedDescription)"
                if (error.domain == AWSServiceErrorDomain && error.code == AWSServiceErrorType.AccessDeniedException.rawValue) {
                    errorMessage = "Access denied. You are not allowed to update this item."
                }
                print("Error: \(errorMessage)")
            } else {
                print("New user updated with fullName.")
                // Cache locally.
                LocalService.setFullNameLocal(fullName)
            }
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
