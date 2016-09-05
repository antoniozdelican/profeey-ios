//
//  EditProfessionTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol EditProfessionDelegate {
    func professionUpdated(profession: String?)
}

class EditProfessionTableViewController: UITableViewController {

    @IBOutlet weak var professionTextField: UITextField!
    
    var profession: String?
    var editProfessionDelegate: EditProfessionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.professionTextField.text = self.profession
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
        return 76.0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.professionTextField.resignFirstResponder()
        self.updateProfession()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: AWS
    
    private func updateProfession() {
        guard let professionText = self.professionTextField.text else {
            return
        }
        
        let profession: String? = professionText.trimm().isEmpty ? nil : professionText.trimm()
        
        FullScreenIndicator.show()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        AWSClientManager.defaultClientManager().updateProfession(profession, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                
                FullScreenIndicator.hide()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.editProfessionDelegate?.professionUpdated(profession)
                    self.performSegueWithIdentifier("segueUnwindToEditProfileTableVc", sender: self)
                }
            })
            return nil
        })
    }

}
