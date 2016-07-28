//
//  EmailSignUpTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EmailSignUpDelegate {
    func toggleContinueButton(enabled: Bool)
    func updateEmail(email: String?)
}

class EmailSignUpTableViewController: UITableViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var titleTableViewCell: UITableViewCell!
    @IBOutlet weak var warningTableViewCell: UITableViewCell!
    
    var emailSignUpDelegate: EmailSignUpDelegate?
    var email: String?
    
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
        self.emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.emailTextField.resignFirstResponder()
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
        guard let emailText = self.emailTextField.text?.trimm() else {
            return
        }
        self.email = !emailText.isEmail() ? nil : emailText
        if self.email != nil {
            self.emailSignUpDelegate?.toggleContinueButton(true)
        } else {
            self.emailSignUpDelegate?.toggleContinueButton(false)
        }
        self.emailSignUpDelegate?.updateEmail(self.email)
    }
}
