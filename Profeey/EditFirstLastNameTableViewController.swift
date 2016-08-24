//
//  EditFirstLastNameTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 10/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol EditFirstLastNameDelegate {
    func firstLastNameUpdated(firstName: String?, lastName: String?)
}

class EditFirstLastNameTableViewController: UITableViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var firstName: String?
    var lastName: String?
    var editFirstLastNameDelegate: EditFirstLastNameDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.firstNameTextField.text = self.firstName
        self.lastNameTextField.text = self.lastName
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
        return 74.0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
        self.updateFirstLastName()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: AWS
    
    private func updateFirstLastName() {
        guard let firstNameText = self.firstNameTextField.text,
            let lastNameText = self.lastNameTextField.text else {
            return
        }
        
        // DynamoDB deletes attribute with nil.
        let firstName: String? = firstNameText.trimm().isEmpty ? nil : firstNameText.trimm()
        let lastName: String? = lastNameText.trimm().isEmpty ? nil : lastNameText.trimm()
        
        FullScreenIndicator.show()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        AWSClientManager.defaultClientManager().updateFirstLastName(firstName, lastName: lastName, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                
                FullScreenIndicator.hide()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.editFirstLastNameDelegate?.firstLastNameUpdated(firstName, lastName: lastName)
                    self.performSegueWithIdentifier("segueUnwindToEditProfileTableVc", sender: self)
                }
            })
            return nil
        })
    }
}
