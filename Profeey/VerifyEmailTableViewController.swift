//
//  VerifyEmailTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider
import AWSDynamoDB

class VerifyEmailTableViewController: UITableViewController {
    
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    var newEmail: String?
    
    fileprivate var userPool: AWSCognitoIdentityUserPool?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.verifyButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        self.verifyButton.isEnabled = false
        self.tableView.register(UINib(nibName: "SettingsTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "settingsTableSectionHeader")
        self.verificationCodeTextField.delegate = self
        
        self.userPool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "settingsTableSectionHeader") as? SettingsTableSectionHeader
        if let newEmail = self.newEmail {
            header?.titleLabel.text = "To verify your email, please enter the verification code we sent to \(newEmail)"
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func verificationCodeTextFieldChanged(_ sender: AnyObject) {
        guard let verificationCode = self.verificationCodeTextField.text?.trimm(), !verificationCode.isEmpty else {
            self.verifyButton.isEnabled = false
            return
        }
        self.verifyButton.isEnabled = true
    }
    
    @IBAction func verifyButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.verifyEmail()
    }
    
    // MARK: AWS
    
    fileprivate func verifyEmail() {
        guard let verificationCode = self.verificationCodeTextField.text?.trimm(), !verificationCode.isEmpty, let newEmail = self.newEmail else {
            return
        }
        FullScreenIndicator.show()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.userPool?.currentUser()?.verifyAttribute("email", code: verificationCode).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    FullScreenIndicator.hide()
                    print("verifyEmail error: \(task.error!)")
                    // Error handling.
                    var title: String = "Something went wrong"
                    var message: String? = "Please try again."
                    if let type = (task.error as! NSError).userInfo["__type"] as? String {
                        switch type {
                        case "CodeMismatchException":
                            title = "Invalid Code"
                            message = "The confirmation code you entered is invalid. Please try again."
                        default:
                            title = type
                            message = (task.error as! NSError).userInfo["message"] as? String
                        }
                        
                    }
                    let alertController = self.getSimpleAlertWithTitle(title, message: message, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                // Update email in DynamoDB.
                self.updateUser(newEmail)
            })
            return nil
        })
    }
    
    fileprivate func updateUser(_ email: String) {
        // Email is now verified.
        let emailVerified = NSNumber(value: 1)
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
                // Notifiy observers. Email is now verified.
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: UpdateEmailNotificationKey), object: self, userInfo: ["email": email, "emailVerified": emailVerified])
                // Dismiss to settings.
                self.dismiss(animated: true, completion: nil)
            })
            return nil
        })
    }

}

extension VerifyEmailTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.verificationCodeTextField:
            guard let verificationCode = self.verificationCodeTextField.text?.trimm(), !verificationCode.isEmpty else {
                return true
            }
            self.verificationCodeTextField.resignFirstResponder()
            self.verifyEmail()
            return true
        default:
            return false
        }
    }
}
