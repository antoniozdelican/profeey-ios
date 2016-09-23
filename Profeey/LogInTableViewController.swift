//
//  LogInTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class LogInTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureForgotPasswordLabel()
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.logInButton.enabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureForgotPasswordLabel() {
        let forgotPasswordAttributedString = NSAttributedString(string: "Forgot password?", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
        self.forgotPasswordLabel.attributedText = forgotPasswordAttributedString
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
        guard let usernameText = self.usernameTextField.text,
            let passwordText = self.passwordTextField.text else {
                return
        }
        guard !usernameText.trimm().isEmpty &&
            !passwordText.trimm().isEmpty else {
                self.logInButton.enabled = false
                return
        }
        self.logInButton.enabled = true
    }
    
    
    @IBAction func logInButtonTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.prepareForLogIn()
    }
    
    // MARK: Helpers
    
    private func prepareForLogIn() {
        guard let usernameText = self.usernameTextField.text,
            let passwordText = self.passwordTextField.text else {
                return
        }
        guard !usernameText.trimm().isEmpty &&
            !passwordText.trimm().isEmpty else {
                return
        }
        let username = usernameText.trimm()
        let password = passwordText.trimm()
        FullScreenIndicator.show()
        self.logInUserPool(username, password: password)
    }
    
    private func redirectToMain() {
        guard let window = UIApplication.sharedApplication().keyWindow,
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    // MARK: AWS
    
    private func logInUserPool(username: String, password: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYUserPoolManager.defaultUserPoolManager().logInUserPool(username, password: password, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("logInUserPool error: \(error)")
                    let alertController = UIAlertController(title: "Login failed", message: error.userInfo["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    FullScreenIndicator.hide()
                    self.redirectToMain()
                }
            })
            return nil
        })
    }
}

extension LogInTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case self.usernameTextField:
            self.usernameTextField.resignFirstResponder()
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
