//
//  EditAboutTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol EditAboutDelegate {
    func aboutUpdated(about: String?)
}

class EditAboutTableViewController: UITableViewController {
    
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var aboutFakePlaceholderLabel: UILabel!
    
    var about: String?
    var delegate: EditAboutDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = Colors.grey
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.aboutTextView.text = self.about
        self.aboutTextView.delegate = self
        self.aboutFakePlaceholderLabel.hidden = !self.aboutTextView.text.isEmpty
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.aboutTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.aboutTextView.resignFirstResponder()
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
        self.setAbout()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: AWS
    
    private func setAbout() {
        guard let aboutText = self.aboutTextView.text?.trimm() else {
            return
        }
        // Set nil if empty to comply with DynamoDB!
        let about: String? = (aboutText.isEmpty ? nil : aboutText)
        FullScreenIndicator.show()
        AWSRemoteService.defaultRemoteService().saveUserAbout(about, completionHandler: {
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
                    LocalService.setAboutLocal(about)
                    // Inform delegate.
                    self.delegate?.aboutUpdated(about)
                    self.performSegueWithIdentifier("segueUnwindToEditProfileTableVc", sender: self)
                }
            })
            return nil
        })
    }
}

extension EditAboutTableViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        self.aboutFakePlaceholderLabel.hidden = !textView.text.isEmpty
        
        // Changing height of the cell
        let currentOffset = self.tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.tableView.setContentOffset(currentOffset, animated: false)
    }
}
