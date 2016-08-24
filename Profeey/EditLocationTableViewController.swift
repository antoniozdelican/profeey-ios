//
//  EditLocationTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol EditLocationDelegate {
    func locationUpdated(location: String?)
}

class EditLocationTableViewController: UITableViewController {

    @IBOutlet weak var locationTextField: UITextField!
    
    var location: String?
    var editLocationDelegate: EditLocationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationTextField.text = self.location
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.locationTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationTextField.resignFirstResponder()
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
        self.locationTextField.resignFirstResponder()
        self.updateLocation()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: AWS
    
    private func updateLocation() {
        guard let locationText = self.locationTextField.text else {
            return
        }
        
        let location: String? = locationText.trimm().isEmpty ? nil : locationText.trimm()
        
        FullScreenIndicator.show()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        AWSClientManager.defaultClientManager().updateUserLocation(location, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                
                FullScreenIndicator.hide()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.editLocationDelegate?.locationUpdated(location)
                    self.performSegueWithIdentifier("segueUnwindToEditProfileTableVc", sender: self)
                }
            })
            return nil
        })
    }

}
