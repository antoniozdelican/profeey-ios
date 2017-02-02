//
//  LogInTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

class LogInTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameBoxView: UIView!
    @IBOutlet weak var passwordBoxView: UIView!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    // NEW
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.usernameBoxView.layer.cornerRadius = 4.0
        self.passwordBoxView.layer.cornerRadius = 4.0
        
        self.logInButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.normal)
        self.logInButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.highlighted)
        self.logInButton.setBackgroundImage(UIImage(named: "btn_white_not_active_resizable"), for: UIControlState.disabled)
        self.logInButton.setTitleColor(Colors.turquoise, for: UIControlState.normal)
        self.logInButton.setTitleColor(Colors.turquoise.withAlphaComponent(0.2), for: UIControlState.highlighted)
        self.logInButton.setTitleColor(UIColor.white, for: UIControlState.disabled)
        self.logInButton.isEnabled = false
        self.facebookButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.facebookButton.setTitleColor(UIColor.white.withAlphaComponent(0.2), for: UIControlState.highlighted)
        self.facebookButton.adjustsImageWhenHighlighted = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func textFieldChanged(_ sender: AnyObject) {
        guard let username = self.usernameTextField.text?.trimm(), !username.isEmpty, let password = self.passwordTextField.text?.trimm(), !password.isEmpty else {
            self.logInButton.isEnabled = false
            return
        }
        self.logInButton.isEnabled = true
    }
    
    
    @IBAction func logInButtonTapped(_ sender: AnyObject) {
        UIView.transition(
            with: self.logInButton,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: {
                self.logInButton.isHighlighted = true
        },
            completion: nil)
        self.view.endEditing(true)
        self.userPoolLogIn()
    }
    
    @IBAction func facebookButtonTapped(_ sender: AnyObject) {
        UIView.transition(
            with: self.facebookButton,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: {
                self.facebookButton.isHighlighted = true
        },
            completion: nil)
        let alertController = self.getSimpleAlertWithTitle("Profeey Beta is not on Facebook yet", message: "We're not on Facebook yet, but will be soon! Please use our normal Log In.", cancelButtonTitle: "Got it!")
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func forgotPasswordButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToForgotPasswordVc", sender: self)
    }
    
    // When coming back from NewPasswordVc.
    @IBAction func unwindToLogInTableViewController(_ segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? NewPasswordTableViewController {
            self.usernameTextField.text = sourceViewController.username
            self.passwordTextField.becomeFirstResponder()
        }
    }
    
    
    // MARK: Helpers
    
    fileprivate func redirectToMain() {
        guard let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    // MARK: AWS
    
    fileprivate func userPoolLogIn() {
        print("userPoolLogIn")
        AWSCognitoUserPoolsSignInProvider.sharedInstance().setInteractiveAuthDelegate(self)
        self.logInWithSignInProvider(AWSCognitoUserPoolsSignInProvider.sharedInstance())
    }

    fileprivate func logInWithSignInProvider(_ signInProvider: AWSSignInProvider) {
        print("logInWithSignInProvider")
        FullScreenIndicator.show()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        AWSIdentityManager.defaultIdentityManager().loginWithSign(signInProvider, completionHandler: {
            (result: Any?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error as? NSError {
                    FullScreenIndicator.hide()
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // Set endpointARN to point to this user.
                    self.createEndpointUser()
                }
            })
        })
    }
    
    /*
     Each time a user Logs in, create/update an EnpointUser in DynamoDB.
     On User Sign up, it will be done in didRegisterForRemoteNotificationsWithDeviceToken after user confirms
     remote notifications.
     */
    fileprivate func createEndpointUser() {
        if let endpointARN = AWSPushManager.defaultPushManager().endpointARN {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            PRFYDynamoDBManager.defaultDynamoDBManager().createEndpointUserDynamoDB(endpointARN, completionHandler: {
                (task: AWSTask) in
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let error = task.error {
                        print("createEndpointUser error :\(error)")
                    }
                    FullScreenIndicator.hide()
                    self.redirectToMain()
                })
                return nil
            })
        } else {
            FullScreenIndicator.hide()
            self.redirectToMain()
        }
    }
}

extension LogInTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.usernameTextField:
            self.usernameTextField.resignFirstResponder()
            self.passwordTextField.becomeFirstResponder()
            return true
        case self.passwordTextField:
            guard let username = self.usernameTextField.text?.trimm(), !username.isEmpty,
                let password = self.passwordTextField.text?.trimm(), !password.isEmpty else {
                    return true
            }
            self.passwordTextField.resignFirstResponder()
            self.userPoolLogIn()
            return true
        default:
            return false
        }
    }
}

extension LogInTableViewController: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    // Handles the UI setup for initial login screen.
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        print("startPasswordAuthentication")
        return self
    }
}

extension LogInTableViewController: AWSCognitoIdentityPasswordAuthentication {
    
    func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        print("getDetails")
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        print("didCompleteStepWithError")
        if let error = error as? NSError {
            var title: String = "Something went wrong"
            var message: String? = "Please try again."
            if let type = error.userInfo["__type"] as? String {
                switch type {
                case "UserNotFoundException":
                    title = "Incorrect Username"
                    message = "The username you entered does not belong to an account. Please try again."
                case "NotAuthorizedException":
                    title = "Incorrect Password"
                    message = "The password you entered does not match with the username. Please try again."
                default:
                    title = type
                    message = error.userInfo["message"] as? String
                }
            }
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                let alertController = self.getSimpleAlertWithTitle(title, message: message, cancelButtonTitle: "Try Again")
                self.present(alertController, animated: true, completion: nil)
            })
        }
    }
}

extension LogInTableViewController: AWSCognitoUserPoolsSignInHandler {
    
    func handleUserPoolSignInFlowStart() {
        print("handleUserPoolSignInFlowStart")
        guard let username = self.usernameTextField.text?.trimm(), !username.isEmpty,
            let password = self.passwordTextField.text?.trimm(), !password.isEmpty else {
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                let alertController = self.getSimpleAlertWithTitle("Missing username / password", message: "Please try again.", cancelButtonTitle: "Try Again")
                self.present(alertController, animated: true, completion: nil)
            })
            return
        }
        // Set the task completion result as an object of AWSCognitoIdentityPasswordAuthenticationDetails with username and password.
        self.passwordAuthenticationCompletion?.setResult(AWSCognitoIdentityPasswordAuthenticationDetails(username: username, password: password))
    }
}
