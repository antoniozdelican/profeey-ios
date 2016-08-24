//
//  EditUsernameTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol EditUsernameDelegate {
    func usernameUpdated(preferredUsername: String?)
}

class EditUsernameTableViewController: UITableViewController {

    @IBOutlet weak var preferredUsernameTextField: UITextField!
    
    var preferredUsername: String?
    var editUsernameDelegate: EditUsernameDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredUsernameTextField.text = self.preferredUsername
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.preferredUsernameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.preferredUsernameTextField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76.0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.preferredUsernameTextField.resignFirstResponder()
        self.updatePreferredUsername()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: AWS
    
    private func updatePreferredUsername() {
        guard let preferredUsernameText = self.preferredUsernameTextField.text else {
            return
        }
        
        // This should not be emtpy!
        let preferredUsername = preferredUsernameText.trimm()
        
        FullScreenIndicator.show()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        AWSClientManager.defaultClientManager().updatePreferredUsername(preferredUsername, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                
                FullScreenIndicator.hide()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.editUsernameDelegate?.usernameUpdated(preferredUsername)
                    self.performSegueWithIdentifier("segueUnwindToEditProfileTableVc", sender: self)
                }
            })
            return nil
        })
    }
}
