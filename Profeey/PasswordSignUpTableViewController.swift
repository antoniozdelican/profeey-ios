//
//  PasswordSignUpTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol PasswordSignUpDelegate {
    func toggleContinueButton(enabled: Bool)
    func updatePassword(password: String?)
}

class PasswordSignUpTableViewController: UITableViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var titleTableViewCell: UITableViewCell!
    @IBOutlet weak var warningTableViewCell: UITableViewCell!
    
    var passwordSignUpDelegate: PasswordSignUpDelegate?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0)
        self.titleTableViewCell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.view.bounds.width)
        self.titleTableViewCell.layoutMargins = UIEdgeInsetsZero
        self.warningTableViewCell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.view.bounds.width)
        self.warningTableViewCell.layoutMargins = UIEdgeInsetsZero
        self.warningTableViewCell.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.passwordTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
        guard let passwordText = self.passwordTextField.text?.trimm()  else {
            return
        }
        // Always hide warning message.
        self.warningTableViewCell.hidden = true
        self.password = passwordText.characters.count < 8 ? nil : passwordText
        if self.password != nil {
            self.passwordSignUpDelegate?.toggleContinueButton(true)
        } else {
            self.passwordSignUpDelegate?.toggleContinueButton(false)
        }
        self.passwordSignUpDelegate?.updatePassword(self.password)
    }
}

extension PasswordSignUpTableViewController: InvalidPasswordSignUpDelegate {
    
    func toggleWarningTableViewCell(hidden: Bool) {
        self.warningTableViewCell.hidden = hidden
    }
}
