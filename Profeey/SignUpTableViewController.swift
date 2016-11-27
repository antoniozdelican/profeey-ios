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
    
    // NEW
    fileprivate var userPool: AWSCognitoIdentityUserPool?
    fileprivate var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    fileprivate var username: String?
    fileprivate var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userPool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.configureLegalLabel()
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.signUpButton.isEnabled = false
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
        guard let firstName = self.firstNameTextField.text, !firstName.trimm().isEmpty,
            let lastName = self.lastNameTextField.text, !lastName.trimm().isEmpty,
            let email = self.emailTextField.text, !email.trimm().isEmpty,
            let password = self.passwordTextField.text, !password.trimm().isEmpty else {
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
        guard let firstNameText = self.firstNameTextField.text, !firstNameText.trimm().isEmpty,
            let lastNameText = self.lastNameTextField.text, !lastNameText.trimm().isEmpty,
            let emailText = self.emailTextField.text, !emailText.trimm().isEmpty,
            let passwordText = self.passwordTextField.text, !passwordText.trimm().isEmpty else {
                return
        }
        let username = NSUUID().uuidString.lowercased()
        let firstName = firstNameText.trimm()
        let lastName = lastNameText.trimm()
        let email = emailText.trimm()
        let password = passwordText.trimm()
        var userAttributes: [AWSCognitoIdentityUserAttributeType] = []
        userAttributes.append(AWSCognitoIdentityUserAttributeType(name: "given_name", value: firstName))
        userAttributes.append(AWSCognitoIdentityUserAttributeType(name: "family_name", value: lastName))
        userAttributes.append(AWSCognitoIdentityUserAttributeType(name: "email", value: email))
        
        print("userPoolSignUp")
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
    
//    fileprivate func signUp(_ username: String, password: String, email: String, firstName: String, lastName: String) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        AWSClientManager.defaultClientManager().signUp(username, password: password, email: email, firstName: firstName, lastName: lastName, completionHandler: {
//            (task: AWSTask) in
//            DispatchQueue.main.async(execute: {
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                if let error = task.error {
//                    FullScreenIndicator.hide()
//                    print("signUpUserPool error: \(error)")
//                    let alertController = UIAlertController(title: "Uups", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
//                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
//                    alertController.addAction(okAction)
//                    self.present(alertController, animated: true, completion: nil)
//                } else {
//                    self.logIn(username, password: password, email: email, firstName: firstName, lastName: lastName)
//                }
//            })
//            return nil
//        })
//        
//    }
    
//    fileprivate func logIn(_ username: String, password: String, email: String, firstName: String, lastName: String) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        AWSClientManager.defaultClientManager().logIn(username, password: password, completionHandler: {
//            (task: AWSTask) in
//            DispatchQueue.main.async(execute: {
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                if let error = task.error {
//                    FullScreenIndicator.hide()
//                    print("signUpUserPool error: \(error)")
//                    let alertController = UIAlertController(title: "Uups", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
//                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
//                    alertController.addAction(okAction)
//                    self.present(alertController, animated: true, completion: nil)
//                } else {
//                    self.createUser(email, firstName: firstName, lastName: lastName)
//                }
//            })
//            return nil
//        })
//    }
    
    fileprivate func createUser() {
        guard let firstNameText = self.firstNameTextField.text, !firstNameText.trimm().isEmpty,
            let lastNameText = self.lastNameTextField.text, !lastNameText.trimm().isEmpty,
            let emailText = self.emailTextField.text, !emailText.trimm().isEmpty else {
                return
        }
        let firstName = firstNameText.trimm()
        let lastName = lastNameText.trimm()
        let email = emailText.trimm()
        
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
        guard let username = self.username, !username.trimm().isEmpty, let password = self.password, !password.trimm().isEmpty else {
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
