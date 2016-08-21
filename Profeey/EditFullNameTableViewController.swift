//
//  EditNameTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol EditNameDelegate {
    func nameUpdated(fullName: String?)
}

class EditNameTableViewController: UITableViewController {
    
    @IBOutlet weak var fullNameTextField: UITextField!
    
    var fullName: String?
    var delegate: EditNameDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = Colors.grey
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.fullNameTextField.text = self.fullName
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.fullNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.fullNameTextField.resignFirstResponder()
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
        self.setFullName()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: AWS
    
    private func setFullName() {
//        guard let fullNameText = self.fullNameTextField.text?.trimm() else {
//            return
//        }
//        // Set nil if empty to comply with DynamoDB!
//        let fullName: String? = (fullNameText.isEmpty ? nil : fullNameText)
//        FullScreenIndicator.show()
//        AWSRemoteService.defaultRemoteService().setFullName(fullName, completionHandler: {
//            (task: AWSTask) in
//            dispatch_async(dispatch_get_main_queue(), {
//                FullScreenIndicator.hide()
//                if let error = task.error {
//                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
//                    if self.presentedViewController == nil {
//                        self.presentViewController(alertController, animated: true, completion: nil)
//                    }
//                } else {
//                    // Cache locally.
//                    LocalService.setFullNameLocal(fullName)
//                    // Inform delegate.
//                    self.delegate?.nameUpdated(fullName)
//                    self.performSegueWithIdentifier("segueUnwindToEditProfileTableVc", sender: self)
//                }
//            })
//            return nil
//        })
    }
}
