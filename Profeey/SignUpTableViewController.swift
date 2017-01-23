//
//  SignUpTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

class SignUpTableViewController: UITableViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameBoxView: UIView!
    @IBOutlet weak var lastNameBoxView: UIView!
    @IBOutlet weak var emailBoxView: UIView!
    @IBOutlet weak var passwordBoxView: UIView!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    fileprivate var userPool: AWSCognitoIdentityUserPool?
    fileprivate var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    fileprivate var username: String?
    fileprivate var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.firstNameBoxView.layer.cornerRadius = 4.0
        self.lastNameBoxView.layer.cornerRadius = 4.0
        self.emailBoxView.layer.cornerRadius = 4.0
        self.passwordBoxView.layer.cornerRadius = 4.0
        
        self.signUpButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.normal)
        self.signUpButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.highlighted)
        self.signUpButton.setBackgroundImage(UIImage(named: "btn_white_not_active_resizable"), for: UIControlState.disabled)
        self.signUpButton.setTitleColor(Colors.turquoise, for: UIControlState.normal)
        self.signUpButton.setTitleColor(Colors.turquoise.withAlphaComponent(0.2), for: UIControlState.highlighted)
        self.signUpButton.setTitleColor(UIColor.white, for: UIControlState.disabled)
        self.signUpButton.isEnabled = false
        
        self.userPool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.firstNameTextField.becomeFirstResponder()
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
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? WelcomeVerificationTableViewController {
            destinationViewController.firstName = self.firstNameTextField.text
            destinationViewController.email = self.emailTextField.text
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func textFieldChanged(_ sender: AnyObject) {
        guard let firstName = self.firstNameTextField.text?.trimm(), !firstName.isEmpty,
            let lastName = self.lastNameTextField.text?.trimm(), !lastName.isEmpty,
            let email = self.emailTextField.text?.trimm(), !email.isEmpty,
            let password = self.passwordTextField.text?.trimm(), !password.isEmpty else {
                self.signUpButton.isEnabled = false
                return
        }
        self.signUpButton.isEnabled = true
    }
    
    
    @IBAction func signUpButtonTapped(_ sender: AnyObject) {
        UIView.transition(
            with: self.signUpButton,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: {
                self.signUpButton.isHighlighted = true
        },
            completion: nil)
        self.view.endEditing(true)
        self.userPoolSignUp()
    }
    
    
    // MARK: AWS
    
    fileprivate func userPoolSignUp() {
        guard let firstName = self.firstNameTextField.text?.trimm(), !firstName.isEmpty,
            let lastName = self.lastNameTextField.text?.trimm(), !lastName.isEmpty,
            let email = self.emailTextField.text?.trimm(), !email.isEmpty,
            let password = self.passwordTextField.text?.trimm(), !password.isEmpty else {
                return
        }
        let username = NSUUID().uuidString.lowercased()
        var userAttributes: [AWSCognitoIdentityUserAttributeType] = []
        userAttributes.append(AWSCognitoIdentityUserAttributeType(name: "given_name", value: firstName))
        userAttributes.append(AWSCognitoIdentityUserAttributeType(name: "family_name", value: lastName))
        userAttributes.append(AWSCognitoIdentityUserAttributeType(name: "email", value: email))
        
        print("userPoolSignUp:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        self.userPool?.signUp(username, password: password, userAttributes: userAttributes, validationData: nil).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error as? NSError {
                    FullScreenIndicator.hide()
                    print("userPoolSignUp error: \(error)")
                    // Error handling.
                    var title: String = "Something went wrong"
                    var message: String? = "Please try again."
                    if let type = error.userInfo["__type"] as? String {
                        switch type {
                        case "InvalidParameterException":
                            if let userInfoMessage = error.userInfo["message"] as? String, userInfoMessage.contains("email") {
                                title = "Invalid Email"
                                message = "The email you entered is not in valid format. Please try again."
                            } else {
                                title = "Invalid Password"
                                message = "The password you entered should be at least 8 characters long with numbers, uppercase and lowercase letters."
                            }
                        case "InvalidPasswordException":
                            title = "Invalid Password"
                            message = "The password you entered should be at least 8 characters long with numbers, uppercase and lowercase letters."
                        default:
                            title = type
                            message = error.userInfo["message"] as? String
                        }
                    }
                    let alertController = self.getSimpleAlertWithTitle(title, message: message, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // 2. logIn user.
                    self.username = username
                    self.password = password
                    self.userPoolLogIn()
                }
            })
            return nil
        })
    }
    
    fileprivate func userPoolLogIn() {
        print("userPoolLogIn")
        AWSCognitoUserPoolsSignInProvider.sharedInstance().setInteractiveAuthDelegate(self)
        self.logInWithSignInProvider(AWSCognitoUserPoolsSignInProvider.sharedInstance())
    }
    
    fileprivate func logInWithSignInProvider(_ signInProvider: AWSSignInProvider) {
        print("logInWithSignInProvider")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        AWSIdentityManager.defaultIdentityManager().loginWithSign(signInProvider, completionHandler: {
            (result: Any?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error as? NSError {
                    FullScreenIndicator.hide()
                    print("logInWithSignInProvider error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // 3. Create user in DynamoDB.
                    self.createUser()
                }
            })
        })
    }
    
    fileprivate func createUser() {
        guard let firstName = self.firstNameTextField.text?.trimm(), !firstName.isEmpty,
            let lastName = self.lastNameTextField.text?.trimm(), !lastName.isEmpty,
            let email = self.emailTextField.text?.trimm(), !email.isEmpty else {
                return
        }
        print("createUserDynamoDB")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createUserDynamoDB(email, firstName: firstName, lastName: lastName, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error as? NSError {
                    print("createUserDynamoDB error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // 4. getEmailVerificationCode in background.
                    self.getEmailVerificationCode()
                    // 5. Segue to Verification.
                    self.performSegue(withIdentifier: "segueToWelcomeVerificationVc", sender: self)
                }
            })
            return nil
        })
    }
    
    /*
     User is confirmed via Lambda but in order to verify email/phone, it has to be done manually by entering the code.
     To request verification code, user has to be authenticated (logged in) already - currentUser.
     This function is executed in background.
     */
    fileprivate func getEmailVerificationCode() {
        print("getEmailVerificationCode:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.userPool?.currentUser()?.getAttributeVerificationCode("email").continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error as? NSError {
                    print("getEmailVerificationCode error: \(error)")
                }
            })
            return nil
        })
    }
    
}

extension SignUpTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.firstNameTextField:
            self.firstNameTextField.resignFirstResponder()
            self.lastNameTextField.becomeFirstResponder()
            return true
        case self.lastNameTextField:
            self.lastNameTextField.resignFirstResponder()
            self.emailTextField.becomeFirstResponder()
            return true
        case self.emailTextField:
            self.emailTextField.resignFirstResponder()
            self.passwordTextField.becomeFirstResponder()
            return true
        case self.passwordTextField:
            guard let firstName = self.firstNameTextField.text?.trimm(), !firstName.isEmpty,
                let lastName = self.lastNameTextField.text?.trimm(), !lastName.isEmpty,
                let email = self.emailTextField.text?.trimm(), !email.isEmpty,
                let password = self.passwordTextField.text?.trimm(), !password.isEmpty else {
                    return true
            }
            self.passwordTextField.resignFirstResponder()
            self.userPoolSignUp()
            return true
        default:
            return false
        }
    }
}

extension SignUpTableViewController: AWSCognitoIdentityInteractiveAuthenticationDelegate {

    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        print("startPasswordAuthentication")
        return self
    }
}

extension SignUpTableViewController: AWSCognitoIdentityPasswordAuthentication {
    
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
                    message = "The username you entered doesn't belong to an account. Please try again."
                case "NotAuthorizedException":
                    title = "Incorrect Password"
                    message = "The password you entered doesn't match with the username. Please try again."
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

extension SignUpTableViewController: AWSCognitoUserPoolsSignInHandler {
    
    func handleUserPoolSignInFlowStart() {
        print("handleUserPoolSignInFlowStart")
        guard let username = self.username?.trimm(), !username.isEmpty, let password = self.password?.trimm(), !password.isEmpty else {
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
