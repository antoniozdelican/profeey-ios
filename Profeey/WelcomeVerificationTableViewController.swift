//
//  WelcomeVerificationTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 16/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

class WelcomeVerificationTableViewController: UITableViewController {
    
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var verificationMessage: UILabel!
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    @IBOutlet weak var confirmationCodeBoxView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    
    // Got from SignUpVc.
    var firstName: String?
    var email: String?
    
    fileprivate var userPool: AWSCognitoIdentityUserPool?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.confirmationCodeTextField.delegate = self
        self.confirmationCodeBoxView.layer.cornerRadius = 4.0
        
        self.confirmButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.normal)
        self.confirmButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.highlighted)
        self.confirmButton.setBackgroundImage(UIImage(named: "btn_white_not_active_resizable"), for: UIControlState.disabled)
        self.confirmButton.setTitleColor(Colors.turquoise, for: UIControlState.normal)
        self.confirmButton.setTitleColor(Colors.turquoise.withAlphaComponent(0.2), for: UIControlState.highlighted)
        self.confirmButton.setTitleColor(UIColor.white, for: UIControlState.disabled)
        self.confirmButton.isEnabled = false
        
        if let firstName = self.firstName, let email = self.email {
            self.welcomeMessage.text = "Welcome to Profeey, \(firstName)!"
            self.verificationMessage.text = "To confirm your account, please check your email \(email) and enter the code."
        }
        
        self.userPool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 133.0
        }
        return 76.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        }
        return 76.0
    }
    
    
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func textFieldChanged(_ sender: AnyObject) {
        guard let confirmationCode = self.confirmationCodeTextField.text?.trimm(), !confirmationCode.isEmpty else {
                self.confirmButton.isEnabled = false
                return
        }
        self.confirmButton.isEnabled = true
    }
    
    
    @IBAction func confirmButtonTapped(_ sender: AnyObject) {
        UIView.transition(
            with: self.confirmButton,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: {
                self.confirmButton.isHighlighted = true
        },
            completion: nil)
        self.view.endEditing(true)
        self.verifyEmail()
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        let alertController = UIAlertController(title: "Account Not Confirmed", message: "If you ever forget your password, we can only help you if your account is confirmed.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Confirm Now", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "Later", style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction) in
            self.performSegue(withIdentifier: "segueToUsernameVc", sender: self)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func verifyEmail() {
        guard let confirmationCode = self.confirmationCodeTextField.text?.trimm(), !confirmationCode.isEmpty else {
            return
        }
        print("verifyEmail:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        self.userPool?.currentUser()?.verifyAttribute("email", code: confirmationCode).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error as? NSError {
                    print("verifyEmail error: \(error)")
                    // Error handling.
                    print(error.localizedDescription)
                    var title: String = "Something went wrong"
                    var message: String? = "Please try again."
                    if let type = error.userInfo["__type"] as? String {
                        switch type {
                        case "CodeMismatchException":
                            title = "Invalid Code"
                            message = "The confirmation code you entered is invalid. Please try again."
                        default:
                            title = type
                            message = error.userInfo["message"] as? String
                        }
                        
                    }
                    let alertController = self.getSimpleAlertWithTitle(title, message: message, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // TODO
                    // Should be some kind of a message.
                    self.performSegue(withIdentifier: "segueToUsernameVc", sender: self)
                }
            })
            return nil
        })
    }
    
}

extension WelcomeVerificationTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let confirmationCode = self.confirmationCodeTextField.text?.trimm(), !confirmationCode.isEmpty else {
            return true
        }
        self.confirmationCodeTextField.resignFirstResponder()
        self.verifyEmail()
        return true
    }
}
