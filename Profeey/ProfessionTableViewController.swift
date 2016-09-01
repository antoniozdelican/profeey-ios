//
//  ProfessionTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 01/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ProfessionDelegate {
    func toggleContinueButton(enabled: Bool)
    func updateProfession(profession: String?)
}

class ProfessionTableViewController: UITableViewController {

    @IBOutlet weak var professionTextField: UITextField!
    @IBOutlet weak var titleTableViewCell: UITableViewCell!
    
    var professionDelegate: ProfessionDelegate?
    var profession: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0)
        self.titleTableViewCell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.view.bounds.width)
        self.titleTableViewCell.layoutMargins = UIEdgeInsetsZero
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.professionTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.professionTextField.resignFirstResponder()
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
        guard let professionText = self.professionTextField.text else {
            return
        }
        self.profession = professionText.trimm().isEmpty ? nil : professionText.trimm()
        self.profession != nil ? self.professionDelegate?.toggleContinueButton(true) : self.professionDelegate?.toggleContinueButton(false)
        self.professionDelegate?.updateProfession(self.profession)
    }
}

extension ProfessionTableViewController: ProfessionViewDelegate {
    
    func removeKeyboard() {
        self.professionTextField.resignFirstResponder()
    }
}
