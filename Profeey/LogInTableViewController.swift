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
        self.logInButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureForgotPasswordLabel() {
        let forgotPasswordAttributedString = NSAttributedString(string: "Forgot password?", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        self.forgotPasswordLabel.attributedText = forgotPasswordAttributedString
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
        guard let usernameText = self.usernameTextField.text,
            let passwordText = self.passwordTextField.text else {
                return
        }
        guard !usernameText.trimm().isEmpty &&
            !passwordText.trimm().isEmpty else {
                self.logInButton.isEnabled = false
                return
        }
        self.logInButton.isEnabled = true
    }
    
    
    @IBAction func logInButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.prepareForLogIn()
    }
    
    // MARK: Helpers
    
    fileprivate func prepareForLogIn() {
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
    
    fileprivate func redirectToMain() {
        guard let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    // MARK: AWS
    
    fileprivate func logInUserPool(_ username: String, password: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYUserPoolManager.defaultUserPoolManager().logInUserPool(username, password: password, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("logInUserPool error: \(error)")
                    let alertController = UIAlertController(title: "Login failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
