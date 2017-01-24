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
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var verificationCodeBoxView: UIView!
    @IBOutlet weak var verifyButton: UIButton!
    
    // Got from SignUpVc.
    var firstName: String?
    var email: String?
    
    fileprivate var userPool: AWSCognitoIdentityUserPool?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.verificationCodeTextField.delegate = self
        self.verificationCodeBoxView.layer.cornerRadius = 4.0
        
        self.verifyButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.normal)
        self.verifyButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.highlighted)
        self.verifyButton.setBackgroundImage(UIImage(named: "btn_white_not_active_resizable"), for: UIControlState.disabled)
        self.verifyButton.setTitleColor(Colors.turquoise, for: UIControlState.normal)
        self.verifyButton.setTitleColor(Colors.turquoise.withAlphaComponent(0.2), for: UIControlState.highlighted)
        self.verifyButton.setTitleColor(UIColor.white, for: UIControlState.disabled)
        self.verifyButton.isEnabled = false
        
        if let firstName = self.firstName, let email = self.email {
            self.welcomeMessage.text = "Welcome to Profeey, \(firstName)!"
            self.verificationMessage.text = "To verify your email, please enter the verification code we sent to \(email)"
        }
        
        self.userPool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.verificationCodeTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
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
        guard let verificationCode = self.verificationCodeTextField.text?.trimm(), !verificationCode.isEmpty else {
                self.verifyButton.isEnabled = false
                return
        }
        self.verifyButton.isEnabled = true
    }
    
    
    @IBAction func verifyButtonTapped(_ sender: AnyObject) {
        UIView.transition(
            with: self.verifyButton,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: {
                self.verifyButton.isHighlighted = true
        },
            completion: nil)
        self.view.endEditing(true)
        self.verifyEmail()
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        let alertController = UIAlertController(title: "Email Not Verified", message: "If you ever forget your password, we can only help you if you have a verified email.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Verify Now", style: UIAlertActionStyle.cancel, handler: nil)
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
        guard let verificationCode = self.verificationCodeTextField.text?.trimm(), !verificationCode.isEmpty, let email = self.email else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
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
                            message = "Verification code you entered is invalid. Please try again."
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
                self.updateUser(email)
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
                // Perform segue.
                self.performSegue(withIdentifier: "segueToUsernameVc", sender: self)
            })
            return nil
        })
    }
    
}

extension WelcomeVerificationTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let verificationCode = self.verificationCodeTextField.text?.trimm(), !verificationCode.isEmpty else {
            return true
        }
        self.verificationCodeTextField.resignFirstResponder()
        self.verifyEmail()
        return true
    }
}
