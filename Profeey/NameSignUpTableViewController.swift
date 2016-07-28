//
//  NameSignUpTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol NameSignUpDelegate {
    func toggleContinueButton(enabled: Bool)
    func updateFirstLastName(firstName: String?, lastName: String?)
}

class NameSignUpTableViewController: UITableViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var legalLabel: UILabel!
    @IBOutlet weak var titleTableViewCell: UITableViewCell!
    @IBOutlet weak var legalTableViewCell: UITableViewCell!
    
    var nameSignUpDelegate: NameSignUpDelegate?
    var firstName: String?
    var lastName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0)
        self.titleTableViewCell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.view.bounds.width)
        self.titleTableViewCell.layoutMargins = UIEdgeInsetsZero
        self.legalTableViewCell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.view.bounds.width)
        self.legalTableViewCell.layoutMargins = UIEdgeInsetsZero
        
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        
        // Legal label
        let legalMutableAttributedString = NSMutableAttributedString(string: "By signing up, you agree to our ")
        let termsOfServiceAttributedString = NSAttributedString(string: "Terms of service", attributes: [NSForegroundColorAttributeName: Colors.blue])
        let privacyPolicyAttributedString = NSAttributedString(string: "Privacy Policy", attributes: [NSForegroundColorAttributeName: Colors.blue])
        legalMutableAttributedString.appendAttributedString(termsOfServiceAttributedString)
        legalMutableAttributedString.appendAttributedString(NSAttributedString(string: " and "))
        legalMutableAttributedString.appendAttributedString(privacyPolicyAttributedString)
        legalMutableAttributedString.appendAttributedString(NSAttributedString(string: "."))
        self.legalLabel.attributedText = legalMutableAttributedString
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.firstNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
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
        guard let firstNameText = self.firstNameTextField.text?.trimm(),
            let lastNameText = self.lastNameTextField.text?.trimm() else {
            return
        }
        self.firstName = firstNameText.isEmpty ? nil : firstNameText
        self.lastName = lastNameText.isEmpty ? nil : lastNameText
        if self.firstName != nil || self.lastName != nil {
           self.nameSignUpDelegate?.toggleContinueButton(true)
        } else {
            self.nameSignUpDelegate?.toggleContinueButton(false)
        }
        self.nameSignUpDelegate?.updateFirstLastName(self.firstName, lastName: self.lastName)
    }
}

extension NameSignUpTableViewController: UITextFieldDelegate {
    
    // For jumping bug.
    func textFieldDidEndEditing(textField: UITextField) {
        textField.layoutIfNeeded()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.firstNameTextField {
            self.lastNameTextField.becomeFirstResponder()
        }
        return true
    }
}
