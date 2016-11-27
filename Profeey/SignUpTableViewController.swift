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
    @IBOutlet weak var legalLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    fileprivate var userPool: AWSCognitoIdentityUserPool?
    fileprivate var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    fileprivate var username: String?
    fileprivate var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLegalLabel()
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.signUpButton.isEnabled = false
        
        self.userPool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureLegalLabel() {
        let legalMutableAttributedString = NSMutableAttributedString(string: "By signing up, you agree to our ")
        let termsOfServiceAttributedString = NSAttributedString(string: "Terms of service", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        let privacyPolicyAttributedString = NSAttributedString(string: "Privacy Policy", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        legalMutableAttributedString.append(termsOfServiceAttributedString)
        legalMutableAttributedString.append(NSAttributedString(string: " and "))
        legalMutableAttributedString.append(privacyPolicyAttributedString)
        legalMutableAttributedString.append(NSAttributedString(string: "."))
        self.legalLabel.attributedText = legalMutableAttributedString
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        self.view.endEditing(true)
        self.userPoolSignUp()
    }
    
    // MARK: Helpers
    
    fileprivate func redirectToWelcome() {
        guard let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Welcome", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
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
                    // 4. Redirect.
                    self.redirectToWelcome()
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
            self.passwordTextField.resignFirstResponder()
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
