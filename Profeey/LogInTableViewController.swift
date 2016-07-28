//
//  LogInTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol LogInDelegate {
    func toggleLogInButton(enabled: Bool)
    func updateUsernamePassword(username: String?, password: String?)
}

class LogInTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var titleTableViewCell: UITableViewCell!
    
    var logInDelegate: LogInDelegate?
    var username: String?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0)
        self.titleTableViewCell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.view.bounds.width)
        self.titleTableViewCell.layoutMargins = UIEdgeInsetsZero
        
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.usernameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    // MARK: IBActions
    
    @IBAction func textFieldChanged(sender: AnyObject) {
        guard let usernameText = self.usernameTextField.text,
            let passwordText = self.passwordTextField.text else {
                return
        }
        self.username = usernameText
        self.password = passwordText
        if !self.username!.isEmpty && !self.password!.isEmpty {
            self.logInDelegate?.toggleLogInButton(true)
        } else {
            self.logInDelegate?.toggleLogInButton(false)
        }
        self.logInDelegate?.updateUsernamePassword(self.username, password: self.password)
    }
}

extension LogInTableViewController: UITextFieldDelegate {
    
    // For jumping bug.
    func textFieldDidEndEditing(textField: UITextField) {
        textField.layoutIfNeeded()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        return true
    }
}
