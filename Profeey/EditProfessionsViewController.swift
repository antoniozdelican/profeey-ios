//
//  EditProfessionsViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol EditProfessionsDelegate {
    func professionsUpdated(professions: [String]?)
}

protocol ProfessionsTextFieldDelegate {
    func textFieldChanged(searchText: String)
}

protocol ProfessionsAddDelegate {
    func add(profession: String)
}

class EditProfessionsViewController: UIViewController {
    
    @IBOutlet weak var addProfessionTextField: UITextField!
    
    var professions: [String]?
    var professionsArray: [String] = []
    var delegate: EditProfessionsDelegate?
    var professionsTextFieldDelegate: ProfessionsTextFieldDelegate?
    var professionsAddDelegate: ProfessionsAddDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add user professions into array if has some(not nil).
        if let professions = self.professions {
            self.professionsArray = professions
        }
        self.addProfessionTextField.addTarget(self, action: #selector(EditProfessionsViewController.addProfessionTextFieldChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addProfessionTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.addProfessionTextField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? ProfessionsCollectionViewController {
            destinationViewController.professions = self.professions
            // Add profession to collection view delegate.
            self.professionsAddDelegate = destinationViewController
            // Set remove delegate.
            destinationViewController.professionsRemoveDelegate = self
        }
        if let destinationViewController = segue.destinationViewController as? SearchProfessionsTableViewController {
            // Set textField delegate.
            self.professionsTextFieldDelegate = destinationViewController
            // Set didSelectRow delegate.
            destinationViewController.professionsDidSelectRowDelegate = self
        }
    }
    
    // MARK: Tappers
    
    func addProfessionTextFieldChanged(sender: UITextField) {
        guard let searchText = sender.text else {
            return
        }
        self.professionsTextFieldDelegate?.textFieldChanged(searchText)
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.setProfessions()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: AWS
    
    private func setProfessions() {
        // Set nil if empty to comply with DynamoDB!
        self.professions = (self.professionsArray.isEmpty ? nil : self.professionsArray)
        FullScreenIndicator.show()
        AWSRemoteService.defaultRemoteService().saveUserProfessions(self.professions, completionHandler: {
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
                    LocalService.setProfessionsLocal(self.professions)
                    // Inform delegate.
                    self.delegate?.professionsUpdated(self.professions)
                    self.performSegueWithIdentifier("segueUnwindToEditProfileTableVc", sender: self)
                }
            })
            return nil
        })
    }

}

extension EditProfessionsViewController: ProfessionsDidSelectRowDelegate {
    
    func didSelectRow(profession: String) {
        self.addProfessionTextField.text = ""
        self.professionsAddDelegate?.add(profession)
        self.professionsArray.insert(profession, atIndex: 0)
    }
}

extension EditProfessionsViewController: ProfessionsRemoveDelegate {
    
    func removeAtIndex(professionIndex: Int) {
        self.professionsArray.removeAtIndex(professionIndex)
    }
}
