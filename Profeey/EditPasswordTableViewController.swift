//
//  EditPasswordTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

class EditPasswordTableViewController: UITableViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newConfirmPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        self.doneButton.isEnabled = false
        self.oldPasswordTextField.delegate = self
        self.newPasswordTextField.delegate = self
        self.newConfirmPasswordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.oldPasswordTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func textFieldChanged(_ sender: AnyObject) {
        guard let oldPassword = self.oldPasswordTextField.text?.trimm(), !oldPassword.isEmpty,
            let newPassword = self.newPasswordTextField.text?.trimm(), !newPassword.isEmpty,
            let newConfirmPassword = self.newConfirmPasswordTextField.text?.trimm(), !newConfirmPassword.isEmpty else {
                self.doneButton.isEnabled = false
                return
        }
        self.doneButton.isEnabled = true
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        // TODO
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension EditPasswordTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.oldPasswordTextField:
            self.oldPasswordTextField.resignFirstResponder()
            self.newPasswordTextField.becomeFirstResponder()
            return true
        case self.newPasswordTextField:
            self.newPasswordTextField.resignFirstResponder()
            self.newConfirmPasswordTextField.becomeFirstResponder()
            return true
        case self.newConfirmPasswordTextField:
            guard let oldPassword = self.oldPasswordTextField.text?.trimm(), !oldPassword.isEmpty,
                let newPassword = self.newPasswordTextField.text?.trimm(), !newPassword.isEmpty,
                let newConfirmPassword = self.newConfirmPasswordTextField.text?.trimm(), !newConfirmPassword.isEmpty else {
                    return true
            }
            self.newConfirmPasswordTextField.resignFirstResponder()
            // TODO
            return true
        default:
            return false
        }
    }
}
