//
//  EditEmailTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

class EditEmailTableViewController: UITableViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var newEmailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        self.doneButton.isEnabled = false
        self.tableView.register(UINib(nibName: "SettingsTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "settingsTableSectionHeader")
        self.newEmailTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.newEmailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "settingsTableSectionHeader") as? SettingsTableSectionHeader
        header?.titleLabel.text = "Your current email: antonio.zdelican@gmail.com"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func newEmailTextFieldChanged(_ sender: AnyObject) {
        guard let newEmail = self.newEmailTextField.text?.trimm(), !newEmail.isEmpty else {
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

extension EditEmailTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.newEmailTextField:
            guard let newEmail = self.newEmailTextField.text?.trimm(), !newEmail.isEmpty else {
                    return true
            }
            self.newEmailTextField.resignFirstResponder()
            // TODO
            return true
        default:
            return false
        }
    }
}
