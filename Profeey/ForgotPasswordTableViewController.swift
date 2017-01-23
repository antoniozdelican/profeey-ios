//
//  ForgotPasswordTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

class ForgotPasswordTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameBoxView: UIView!
    @IBOutlet weak var sendLinkButton: UIButton!
    
    fileprivate var userPool: AWSCognitoIdentityUserPool?
    fileprivate var user: AWSCognitoIdentityUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.usernameTextField.delegate = self
        self.usernameBoxView.layer.cornerRadius = 4.0
        
        self.sendLinkButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.normal)
        self.sendLinkButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.highlighted)
        self.sendLinkButton.setBackgroundImage(UIImage(named: "btn_white_not_active_resizable"), for: UIControlState.disabled)
        self.sendLinkButton.setTitleColor(Colors.turquoise, for: UIControlState.normal)
        self.sendLinkButton.setTitleColor(Colors.turquoise.withAlphaComponent(0.2), for: UIControlState.highlighted)
        self.sendLinkButton.setTitleColor(UIColor.white, for: UIControlState.disabled)
        self.sendLinkButton.isEnabled = false
        
        self.userPool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.usernameTextField.becomeFirstResponder()
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
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? NewPasswordTableViewController {
            destinationViewController.user = self.user
            destinationViewController.username = self.usernameTextField.text
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func textFieldChanged(_ sender: AnyObject) {
        guard let username = self.usernameTextField.text?.trimm(), !username.isEmpty else {
            self.sendLinkButton.isEnabled = false
            return
        }
        self.sendLinkButton.isEnabled = true
    }
    
    @IBAction func sendLinkButtonTapped(_ sender: AnyObject) {
        UIView.transition(
            with: self.sendLinkButton,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: {
                self.sendLinkButton.isHighlighted = true
        },
            completion: nil)
        self.view.endEditing(true)
        self.sendForgotPasswordCode()
    }
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func sendForgotPasswordCode() {
        guard let username = self.usernameTextField.text?.trimm(), !username.isEmpty else {
                return
        }
        self.user = self.userPool?.getUser(username)
        
        print("forgotPassword:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        self.user?.forgotPassword().continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error as? NSError {
                    print("forgotPassword error: \(error)")
                    // Error handling.
                    var title: String = "Something went wrong"
                    var message: String? = "Please try again."
                    if let type = error.userInfo["__type"] as? String {
                        switch type {
                        case "UserNotFoundException":
                            title = "User Not Found"
                            message = "The username/email you entered doesn't belong to an account. Please try again."
                        case "InvalidParameterException":
                            title = "Unverified Email"
                            message = "It appears that your email is not verfied so we can not reset your password. Please contact our support."
                        default:
                            title = type
                            message = error.userInfo["message"] as? String
                        }
                        
                    }
                    let alertController = self.getSimpleAlertWithTitle(title, message: message, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "segueToNewPasswordVc", sender: self)
                }
            })
            return nil
        })
    }
}

extension ForgotPasswordTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let username = self.usernameTextField.text?.trimm(), !username.isEmpty else {
            return true
        }
        self.usernameTextField.resignFirstResponder()
        self.sendForgotPasswordCode()
        return true
    }
}
