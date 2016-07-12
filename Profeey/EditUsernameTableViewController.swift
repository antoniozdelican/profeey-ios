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
    var delegate: EditUsernameDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = Colors.grey
        self.tableView.separatorInset = UIEdgeInsetsZero
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
        return 84.0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.setPreferredUsername()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: AWS
    
    private func setPreferredUsername() {
        guard let preferredUsernameText = self.preferredUsernameTextField.text?.trimm() else {
            return
        }
        // Set nil if empty to comply with DynamoDB!
        let preferredUsername: String? = (preferredUsernameText.isEmpty ? nil : preferredUsernameText)
        FullScreenIndicator.show()
        AWSRemoteService.defaultRemoteService().setPreferredUsername(preferredUsername, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                FullScreenIndicator.hide()
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    if self.presentedViewController == nil {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                } else {
                    // Cache locally.
                    LocalService.setPreferredUsernameLocal(preferredUsername)
                    // Inform delegate.
                    self.delegate?.usernameUpdated(preferredUsername)
                    self.performSegueWithIdentifier("segueUnwindToEditProfileTableVc", sender: self)
                }
            })
            return nil
        })
    }
}
