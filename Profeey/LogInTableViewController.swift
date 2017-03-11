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
import FBSDKCoreKit
import FBSDKLoginKit


class LogInTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameBoxView: UIView!
    @IBOutlet weak var passwordBoxView: UIView!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // NEW
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.configureButtonsAndTextFields()
        self.activityIndicatorView.isHidden = true
        // Set Facebook permissions.
        AWSFacebookSignInProvider.sharedInstance().setPermissions(["public_profile", "email"])
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
    
    // MARK: Configuration
    
    fileprivate func configureButtonsAndTextFields() {
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
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? UsernameTableViewController {
            // It's coming from Facebook logIn.
            destinationViewController.isUserPoolUser = false
        }
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
        self.view.endEditing(true)
        // Check again because it can be tapped before detecting.
        if !AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            self.facebookLogIn()
        }
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
        if let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
                window.rootViewController = initialViewController
        }
    }
    
    // For disabledUser.
    fileprivate func redirectToOnboarding() {
        if let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController() {
                window.rootViewController = initialViewController
        }
    }
    
    fileprivate func showDisabledMessage() {
        let alertController = self.getSimpleAlertWithTitle("Disabled account", message: "Your account has been disabled for violating our terms. Go to www.profeey.com/terms and learn more.", cancelButtonTitle: "Ok")
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func enableButtons() {
        // Enable all buttons and textFields.
        self.usernameTextField.isEnabled = true
        self.passwordTextField.isEnabled = true
        self.logInButton.isEnabled = true
        self.forgotPasswordButton.isEnabled = true
        self.facebookButton.isEnabled = true
        // Remove activity.
        self.activityIndicatorView.isHidden = true
        self.activityIndicatorView.stopAnimating()
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
    
    fileprivate func facebookLogIn() {
        print("facebookLogIn:")
        // 1. logIn user with Facebook.
        self.logInWithFacebookSignInProvider(AWSFacebookSignInProvider.sharedInstance())
    }
    
    fileprivate func logInWithFacebookSignInProvider(_ signInProvider: AWSSignInProvider) {
        print("logInWithFacebookSignInProvider:")
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        AWSIdentityManager.defaultIdentityManager().loginWithSign(signInProvider, completionHandler: {
            (result: Any?, error: Error?) in
            DispatchQueue.main.async(execute: {
                //UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("logInWithFacebookSignInProvider error: \(error!)")
                    return
                }
                // Disable all buttons and textFields.
                self.usernameTextField.isEnabled = false
                self.passwordTextField.isEnabled = false
                self.logInButton.isEnabled = false
                self.forgotPasswordButton.isEnabled = false
                UIView.transition(
                    with: self.facebookButton,
                    duration: 0.2,
                    options: .transitionCrossDissolve,
                    animations: {
                        self.facebookButton.isEnabled = false
                },
                    completion: {
                        (finished: Bool) in
                        // Add activity
                        self.activityIndicatorView.isHidden = false
                        self.activityIndicatorView.startAnimating()
                })
                /*
                 2. Check if user already exists in DynamoDB.
                 If not, get email, firstName, lastName from Facenook Graph API and create user in DynamoDB.
                 If yes, just redirect to MainVc.
                 */
                self.getCurrentUser()
            })
        })
    }
    
    fileprivate func getCurrentUser() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getCurrentUserDynamoDB({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    // Handle error.
                    print("getCurrentUser error: \(task.error!)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: task.error?.localizedDescription, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                    self.enableButtons()
                    return
                }
                if let user = task.result as? AWSUser {
                    // User already exists in DynamoDB, so this is logIn.
                    
                    // Check if disabled. If yes, logOut.
                    if let isDisabled = user._isDisabled, isDisabled.intValue == 1 {
                        self.logOut()
                    } else {
                        self.redirectToMain()
                    }
                } else {
                    // User doesn't exists in DynamoDB, so this is signUp.
                    self.getFacebookGraphData()
                }
            })
            return nil
        })
    }
    
    fileprivate func getFacebookGraphData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id, first_name, last_name, email"]).start(completionHandler: {
            (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("getFacebookGraphData error: \(error!)")
                    self.enableButtons()
                    return
                }
                guard let result = result as? [AnyHashable: Any?] else {
                    print("No result!")
                    self.enableButtons()
                    return
                }
                let email = result["email"] as? String
                let firstName = result["first_name"] as? String
                let lastName = result["last_name"] as? String
                // 3. Create user in DynamoDB.
                self.createFacebookUser(email, firstName: firstName, lastName: lastName)
            })
        })
    }
    
    fileprivate func createFacebookUser(_ email: String?, firstName: String?, lastName: String?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createFacebookUserDynamoDB(email, firstName: firstName, lastName: lastName, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    print("createFacebookUser error: \(task.error!)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: task.error?.localizedDescription, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                    self.enableButtons()
                    return
                }
                // 4. Segue to UsernameVc.
                self.performSegue(withIdentifier: "segueToUsernameVc", sender: self)
            })
            return nil
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
    
    // Just in case it's a disabled user.
    fileprivate func logOut() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        AWSIdentityManager.defaultIdentityManager().logout(completionHandler: {
            (result: Any?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                // Don't put error because it will be shown before redirection!
                
                // Credentials provider cleanUp.
                //AWSIdentityManager.defaultIdentityManager().credentialsProvider.clearKeychain()
                // User file manager cleanUp.
                AWSUserFileManager.defaultUserFileManager().clearCache()
                // Current user cleanUp.
                PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB = nil
                // Clean NSUserDefaults also.
                LocalUser.clearAllLocal()
                
                // Present disabled message.
                self.showDisabledMessage()
                
                // Redirect.
                self.redirectToOnboarding()
            })
        })
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
