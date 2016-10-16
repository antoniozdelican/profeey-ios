//
//  SignUpTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class SignUpTableViewController: UITableViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var legalLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func textFieldChanged(_ sender: AnyObject) {
        guard let firstNameText = self.firstNameTextField.text,
            let lastNameText = self.lastNameTextField.text,
            let emailText = self.emailTextField.text,
            let passwordText = self.passwordTextField.text else {
                return
        }
        guard !firstNameText.trimm().isEmpty &&
            !lastNameText.trimm().isEmpty &&
            !emailText.trimm().isEmpty &&
            !passwordText.trimm().isEmpty else {
                self.signUpButton.isEnabled = false
                return
        }
        self.signUpButton.isEnabled = true
    }
    
    
    @IBAction func signUpButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.prepareForSignUp()
    }
    
    // MARK: Helpers
    
    fileprivate func prepareForSignUp() {
        guard let firstNameText = self.firstNameTextField.text,
            let lastNameText = self.lastNameTextField.text,
            let emailText = self.emailTextField.text,
            let passwordText = self.passwordTextField.text else {
                return
        }
        guard !firstNameText.trimm().isEmpty &&
            !lastNameText.trimm().isEmpty &&
            !emailText.trimm().isEmpty &&
            !passwordText.trimm().isEmpty else {
                return
        }
        let username = NSUUID().uuidString.lowercased()
        let firstName = firstNameText.trimm()
        let lastName = lastNameText.trimm()
        let email = emailText.trimm()
        let password = passwordText.trimm()
        // Basic validation, stringer is on server side.
        guard email.isEmail() else {
            let alertController = UIAlertController(title: "Invalid Email ", message: "The email you entered is not valid. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        guard password.isPassword() else {
            let alertController = UIAlertController(title: "Invalid Password", message: "For your security, password should be at least 8 characters, uppercase, lowercase and numeric.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        FullScreenIndicator.show()
        self.signUp(username, password: password, email: email, firstName: firstName, lastName: lastName)
    }
    
    fileprivate func redirectToWelcome() {
        guard let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Welcome", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    
    // MARK: AWS
    
    fileprivate func signUp(_ username: String, password: String, email: String, firstName: String, lastName: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().signUp(username, password: password, email: email, firstName: firstName, lastName: lastName, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("signUpUserPool error: \(error)")
                    let alertController = UIAlertController(title: "Uups", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.logIn(username, password: password, email: email, firstName: firstName, lastName: lastName)
                }
            })
            return nil
        })
        
    }
    
    fileprivate func logIn(_ username: String, password: String, email: String, firstName: String, lastName: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().logIn(username, password: password, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("signUpUserPool error: \(error)")
                    let alertController = UIAlertController(title: "Uups", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.createUser(email, firstName: firstName, lastName: lastName)
                }
            })
            return nil
        })
    }
    
    fileprivate func createUser(_ email: String, firstName: String, lastName: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createUserDynamoDB(email, firstName: firstName, lastName: lastName, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("signUpUserPool error: \(error)")
                    let alertController = UIAlertController(title: "Uups", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    FullScreenIndicator.hide()
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
