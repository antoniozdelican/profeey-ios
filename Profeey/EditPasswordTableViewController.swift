//
//  EditPasswordTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider
import AWSDynamoDB

class EditPasswordTableViewController: UITableViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newConfirmPasswordTextField: UITextField!
    
    fileprivate var userPool: AWSCognitoIdentityUserPool?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        self.doneButton.isEnabled = false
        self.oldPasswordTextField.delegate = self
        self.newPasswordTextField.delegate = self
        self.newConfirmPasswordTextField.delegate = self
        
        self.userPool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.oldPasswordTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func textFieldChanged(_ sender: AnyObject) {
        guard let oldPassword = self.oldPasswordTextField.text?.trimm(), !oldPassword.isEmpty,
            let newPassword = self.newPasswordTextField.text?.trimm(), !newPassword.isEmpty,
            let newConfirmPassword = self.newConfirmPasswordTextField.text?.trimm(), !newConfirmPassword.isEmpty else {
                self.doneButton.isEnabled = false
                return
        }
        self.doneButton.isEnabled = true
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.confirmNewPassword()
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    fileprivate func confirmNewPassword() {
        guard let oldPassword = self.oldPasswordTextField.text?.trimm(), !oldPassword.isEmpty,
            let newPassword = self.newPasswordTextField.text?.trimm(), !newPassword.isEmpty,
            let newConfirmPassword = self.newConfirmPasswordTextField.text?.trimm(), !newConfirmPassword.isEmpty else {
                return
        }
        guard newPassword == newConfirmPassword else {
            let alertController = self.getSimpleAlertWithTitle("Passwords do not match", message: "Your new password and retype new password do not match. Please try again.", cancelButtonTitle: "Try Again")
            self.present(alertController, animated: true, completion: nil)
            return
        }
        self.userPoolUpdatePassword(oldPassword, newPassword: newPassword)
    }
    
    // MARK: AWS
    
    fileprivate func userPoolUpdatePassword(_ oldPassword: String, newPassword: String) {
        FullScreenIndicator.show()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.userPool?.currentUser()?.changePassword(oldPassword, proposedPassword: newPassword).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                guard task.error == nil else {
                    print("userPoolUpdatePassword error: \(task.error!)")
                    // Error handling.
                    var title: String = "Something went wrong"
                    var message: String? = "Please try again."
                    if let type = (task.error as! NSError).userInfo["__type"] as? String {
                        switch type {
                        case "InvalidParameterException":
                            title = "Invalid Password"
                            message = "Passwords you entered should be at least 8 characters long with numbers, uppercase and lowercase letters."
                        case "InvalidPasswordException":
                            title = "Invalid Password"
                            message = "Passwords you entered should be at least 8 characters long with numbers, uppercase and lowercase letters."
                        case "NotAuthorizedException":
                            title = "Incorrect Current Password"
                            message = "Current password you entered does not match with your username. Please try again."
                        default:
                            title = type
                            message = (task.error as! NSError).userInfo["message"] as? String
                        }
                    }
                    let alertController = self.getSimpleAlertWithTitle(title, message: message, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            })
            return nil
        })
    }

}

extension EditPasswordTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.oldPasswordTextField:
            self.oldPasswordTextField.resignFirstResponder()
            self.newPasswordTextField.becomeFirstResponder()
            return true
        case self.newPasswordTextField:
            self.newPasswordTextField.resignFirstResponder()
            self.newConfirmPasswordTextField.becomeFirstResponder()
            return true
        case self.newConfirmPasswordTextField:
            guard let oldPassword = self.oldPasswordTextField.text?.trimm(), !oldPassword.isEmpty,
                let newPassword = self.newPasswordTextField.text?.trimm(), !newPassword.isEmpty,
                let newConfirmPassword = self.newConfirmPasswordTextField.text?.trimm(), !newConfirmPassword.isEmpty else {
                    return true
            }
            self.newConfirmPasswordTextField.resignFirstResponder()
            self.confirmNewPassword()
            return true
        default:
            return false
        }
    }
}
