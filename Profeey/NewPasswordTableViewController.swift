//
//  NewPasswordTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

class NewPasswordTableViewController: UITableViewController {
    
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmationCodeBoxView: UIView!
    @IBOutlet weak var newPasswordBoxView: UIView!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    // Got from ForgotPasswordVc.
    var user: AWSCognitoIdentityUser?
    var username: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.confirmationCodeTextField.delegate = self
        self.newPasswordTextField.delegate = self
        self.confirmationCodeBoxView.layer.cornerRadius = 4.0
        self.newPasswordBoxView.layer.cornerRadius = 4.0
        
        self.resetPasswordButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.normal)
        self.resetPasswordButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.highlighted)
        self.resetPasswordButton.setBackgroundImage(UIImage(named: "btn_white_not_active_resizable"), for: UIControlState.disabled)
        self.resetPasswordButton.setTitleColor(Colors.turquoise, for: UIControlState.normal)
        self.resetPasswordButton.setTitleColor(Colors.turquoise.withAlphaComponent(0.2), for: UIControlState.highlighted)
        self.resetPasswordButton.setTitleColor(UIColor.white, for: UIControlState.disabled)
        self.resetPasswordButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.confirmationCodeTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
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
        guard let confirmationCode = self.confirmationCodeTextField.text?.trimm(), !confirmationCode.isEmpty,
            let newPassword = self.newPasswordTextField.text?.trimm(), !newPassword.isEmpty else {
                self.resetPasswordButton.isEnabled = false
                return
        }
        self.resetPasswordButton.isEnabled = true
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: AnyObject) {
        UIView.transition(
            with: self.resetPasswordButton,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: {
                self.resetPasswordButton.isHighlighted = true
        },
            completion: nil)
        self.view.endEditing(true)
        self.resetPassword()
    }
    
    // MARK: AWS
    
    fileprivate func resetPassword() {
        guard let confirmationCode = self.confirmationCodeTextField.text?.trimm(), !confirmationCode.isEmpty,
            let newPassword = self.newPasswordTextField.text?.trimm(), !newPassword.isEmpty else {
                return
        }
        
        print("resetPassword:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        self.user?.confirmForgotPassword(confirmationCode, password: newPassword).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error as? NSError {
                    print("resetPassword error: \(error)")
                    // Error handling.
                    var title: String = "Something went wrong"
                    var message: String? = "Please try again."
                    print(error.localizedDescription)
                    if let type = error.userInfo["__type"] as? String {
                        switch type {
                        case "CodeMismatchException":
                            title = "Invalid Code"
                            message = "The confirmation code you entered is invalid. Please try again."
                        case "InvalidParameterException":
                            title = "Invalid Password"
                            message = "The password you entered should be at least 8 characters long with numbers, uppercase and lowercase letters."
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
                    // Unwind to LogInVc and pass username/email.
                    self.performSegue(withIdentifier: "segueUnwindToLogInVc", sender: self)
                }
            })
            return nil
        })
    }
}

extension NewPasswordTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.confirmationCodeTextField:
            self.confirmationCodeTextField.resignFirstResponder()
            self.newPasswordTextField.becomeFirstResponder()
            return true
        case self.newPasswordTextField:
            if let confirmationCode = self.confirmationCodeTextField.text?.trimm(), !confirmationCode.isEmpty,
                let newPassword = self.newPasswordTextField.text?.trimm(), !newPassword.isEmpty {
                self.newPasswordTextField.resignFirstResponder()
                self.resetPassword()
            }
            return true
        default:
            return true
        }
    }
}
