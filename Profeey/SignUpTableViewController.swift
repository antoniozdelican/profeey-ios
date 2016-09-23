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
        self.signUpButton.enabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureLegalLabel() {
        let legalMutableAttributedString = NSMutableAttributedString(string: "By signing up, you agree to our ")
        let termsOfServiceAttributedString = NSAttributedString(string: "Terms of service", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
        let privacyPolicyAttributedString = NSAttributedString(string: "Privacy Policy", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
        legalMutableAttributedString.appendAttributedString(termsOfServiceAttributedString)
        legalMutableAttributedString.appendAttributedString(NSAttributedString(string: " and "))
        legalMutableAttributedString.appendAttributedString(privacyPolicyAttributedString)
        legalMutableAttributedString.appendAttributedString(NSAttributedString(string: "."))
        self.legalLabel.attributedText = legalMutableAttributedString
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func textFieldChanged(sender: AnyObject) {
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
                self.signUpButton.enabled = false
                return
        }
        self.signUpButton.enabled = true
    }
    
    
    @IBAction func signUpButtonTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.prepareForSignUp()
    }
    
    // MARK: Helpers
    
    private func prepareForSignUp() {
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
        let username = NSUUID().UUIDString.lowercaseString
        let firstName = firstNameText.trimm()
        let lastName = lastNameText.trimm()
        let email = emailText.trimm()
        let password = passwordText.trimm()
        // Basic validation, stringer is on server side.
        guard email.isEmail() else {
            let alertController = UIAlertController(title: "Invalid Email ", message: "The email you entered is not valid. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        guard password.isPassword() else {
            let alertController = UIAlertController(title: "Invalid Password", message: "For your security, password should be at least 8 characters, uppercase, lowercase and numeric.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        FullScreenIndicator.show()
        self.signUpUserPool(username, password: password, email: email, firstName: firstName, lastName: lastName)
    }
    
    private func redirectToWelcome() {
        guard let window = UIApplication.sharedApplication().keyWindow,
            let initialViewController = UIStoryboard(name: "Welcome", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    
    // MARK: AWS
    
    private func signUpUserPool(username: String, password: String, email: String, firstName: String, lastName: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYUserPoolManager.defaultUserPoolManager().signUpUserPool(username, password: password, email: email, firstName: firstName, lastName: lastName, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("signUpUserPool error: \(error)")
                    let alertController = UIAlertController(title: "Uups", message: error.userInfo["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.logInUserPool(username, password: password, email: email, firstName: firstName, lastName: lastName)
                }
            })
            return nil
        })
        
    }
    
    private func logInUserPool(username: String, password: String, email: String, firstName: String, lastName: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYUserPoolManager.defaultUserPoolManager().logInUserPool(username, password: password, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("signUpUserPool error: \(error)")
                    let alertController = UIAlertController(title: "Uups", message: error.userInfo["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.createUser(email, firstName: firstName, lastName: lastName)
                }
            })
            return nil
        })
    }
    
    private func createUser(email: String, firstName: String, lastName: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createUserDynamoDB(email, firstName: firstName, lastName: lastName, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("signUpUserPool error: \(error)")
                    let alertController = UIAlertController(title: "Uups", message: "\(error.userInfo["message"])", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
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
