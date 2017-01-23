//
//  EditEmailTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider
import AWSDynamoDB

class EditEmailTableViewController: UITableViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var newEmailTextField: UITextField!
    
    var currentEmail: String?
    var currentEmailVerified: NSNumber?
    
    fileprivate var newEmail: String?
    fileprivate var userPool: AWSCognitoIdentityUserPool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        self.tableView.register(UINib(nibName: "SettingsTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "settingsTableSectionHeader")
        self.newEmailTextField.delegate = self
        self.newEmailTextField.text = self.currentEmail
        if let currentEmailVerified = self.currentEmailVerified, currentEmailVerified.intValue == 1 {
            self.nextButton.isEnabled = false
        }
        
        self.userPool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.newEmailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? VerifyEmailTableViewController {
            destinationViewController.newEmail = self.newEmail
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "settingsTableSectionHeader") as? SettingsTableSectionHeader
        if let currentEmailVerified = self.currentEmailVerified, currentEmailVerified.intValue == 1 {
            header?.titleLabel.text = "Your current email address is already verified."
        } else {
            header?.titleLabel.text = "Please verify your email address. This helps secure your account."
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "settingsTableSectionHeader") as? SettingsTableSectionHeader
        footer?.titleLabel.text = "We won't show your email address to other Profeeys or send spam."
        return footer
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func newEmailTextFieldChanged(_ sender: AnyObject) {
        guard let newEmail = self.newEmailTextField.text?.trimm(), !newEmail.isEmpty, let currentEmail = self.currentEmail else {
            self.nextButton.isEnabled = false
            return
        }
        
        // Set header message and done button.
        let header = self.tableView.headerView(forSection: 0) as? SettingsTableSectionHeader
        if newEmail == currentEmail {
            if let currentEmailVerified = self.currentEmailVerified, currentEmailVerified.intValue == 1 {
                header?.titleLabel.text = "Your current email address is already verified."
                self.nextButton.isEnabled = false
            } else {
                header?.titleLabel.text = "Please verify your email address. This helps secure your account."
                self.nextButton.isEnabled = true
            }
        } else {
            (self.tableView.headerView(forSection: 0) as? SettingsTableSectionHeader)?.titleLabel.text = "By setting a new email address, \(currentEmail) will no longer belong to your account."
            self.nextButton.isEnabled = true
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        guard let newEmail = self.newEmailTextField.text?.trimm(), !newEmail.isEmpty, let currentEmail = self.currentEmail else {
            return
        }
        self.view.endEditing(true)
        // If verification, just update user, otherwise query for emails.
        if newEmail == currentEmail {
            FullScreenIndicator.show()
            self.updateUser(newEmail)
        } else {
            FullScreenIndicator.show()
            self.queryEmails()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    // 1. Check if email already exists in DynamoDB.
    fileprivate func queryEmails() {
        guard let newEmail = self.newEmailTextField.text?.trimm(), !newEmail.isEmpty else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryEmailsDynamoDB(newEmail, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    FullScreenIndicator.hide()
                    print("queryEmails error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error!.localizedDescription, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                guard response == nil || response?.items.count == 0 else {
                    FullScreenIndicator.hide()
                    let alertController = self.getSimpleAlertWithTitle("Email exists", message: "This email already belongs to another account. Please choose a different one and try again.", cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                // 2. Update email in userPool.
                self.userPoolUpdateEmail(newEmail)
            })
        })
    }
    
    fileprivate func userPoolUpdateEmail(_ email: String) {
        var userAttributes: [AWSCognitoIdentityUserAttributeType] = []
        userAttributes.append(AWSCognitoIdentityUserAttributeType(name: "email", value: email))
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.userPool?.currentUser()?.update(userAttributes).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    FullScreenIndicator.hide()
                    print("userPoolUpdateEmail error: \(task.error!)")
                    // Error handling.
                    var title: String = "Something went wrong"
                    var message: String? = "Please try again."
                    if let type = (task.error as! NSError).userInfo["__type"] as? String {
                        switch type {
                        case "AliasExistsException":
                            title = "Email exists"
                            message = "This email already belongs to another account. Please choose a different one and try again."
                        case "InvalidParameterException":
                            title = "Invalid Email"
                            message = "The email you entered is not in valid format. Please try again."
                        default:
                            title = type
                            message = (task.error as! NSError).userInfo["message"] as? String
                        }
                    }
                    let alertController = self.getSimpleAlertWithTitle(title, message: message, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                // 3. Update email in DynamoDB.
                self.updateUser(email)
            })
            return nil
        })
    }
    
    fileprivate func updateUser(_ email: String) {
        // If new email, it's not yet verified.
        let emailVerified = NSNumber(value: 0)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().updateUserEmailDynamoDB(email, emailVerified: emailVerified, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                guard task.error == nil else {
                    print("updateUser error: \(task.error!)")
                    let alertController = UIAlertController(title: "Save error", message: task.error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                // Set new email.
                self.newEmail = email
                // Notifiy observers. Email is not yet verified.
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: UpdateEmailNotificationKey), object: self, userInfo: ["email": email, "emailVerified": emailVerified])
                // 4. getEmailVerificationCode in background.
                self.getEmailVerificationCode()
                // 5. Segue to Verification.
                self.performSegue(withIdentifier: "segueToVerifyEmailVc", sender: self)
            })
            return nil
        })
    }
    
    // Request userPool for verification code. In background.
    fileprivate func getEmailVerificationCode() {
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

extension EditEmailTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.newEmailTextField:
            guard let newEmail = self.newEmailTextField.text?.trimm(), !newEmail.isEmpty else {
                    return true
            }
            self.newEmailTextField.resignFirstResponder()
            self.queryEmails()
            return true
        default:
            return false
        }
    }
}
