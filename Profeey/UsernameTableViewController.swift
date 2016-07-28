//
//  UsernameSignUpTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol UsernameDelegate {
    func toggleContinueButton(enabled: Bool)
    func updateUsername(username: String?)
}

class UsernameTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var titleTableViewCell: UITableViewCell!
    @IBOutlet weak var warningTableViewCell: UITableViewCell!
    
    var usernameDelegate: UsernameDelegate?
    var username: String?

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
        self.usernameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.usernameTextField.resignFirstResponder()
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
        guard let usernameText = self.usernameTextField.text?.trimm() else {
            return
        }
        self.username = usernameText.isEmpty ? nil : usernameText
        if self.username != nil {
            self.usernameDelegate?.toggleContinueButton(true)
        } else {
            self.usernameDelegate?.toggleContinueButton(false)
        }
        self.usernameDelegate?.updateUsername(self.username)
    }
}
