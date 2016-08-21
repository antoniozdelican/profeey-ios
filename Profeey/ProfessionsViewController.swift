//
//  ProfessionsViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol ProfessionsTextFieldDelegate {
    func textFieldChanged(searchText: String)
}

protocol ProfessionsAddDelegate {
    func addProfession(profession: String)
}

// Used in edit profile.
protocol EditProfessionsDelegate {
    func professionsUpdated(professions:[String]?)
}

class ProfessionsViewController: UIViewController {
    
    @IBOutlet weak var professionTextField: UITextField!
    
    var professions: [String] = []
    var professionsTextFieldDelegate: ProfessionsTextFieldDelegate?
    var professionsAddDelegate: ProfessionsAddDelegate?
    var editProfessionsDelegate: EditProfessionsDelegate?
    var isEditProfessions: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.navigationItem.hidesBackButton = true
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

    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? ProfessionsCollectionViewController {
            destinationViewController.professions = self.professions
            // Add profession to collection view delegate.
            self.professionsAddDelegate = destinationViewController
            // Set remove delegate.
            destinationViewController.professionsRemoveDelegate = self
        }
        if let destinationViewController = segue.destinationViewController as? ProfessionsTableViewController {
            // Set textField delegate.
            self.professionsTextFieldDelegate = destinationViewController
            // Set didSelectRow delegate.
            destinationViewController.professionsDidSelectRowDelegate = self
        }
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        self.professionTextField.resignFirstResponder()
        self.updateUserProfessions()
    }
    
    @IBAction func professionTextFieldChanged(sender: AnyObject) {
        guard let professionTextField = sender as? UITextField,
        let searchText = professionTextField.text else {
            return
        }
        self.professionsTextFieldDelegate?.textFieldChanged(searchText)
    }
    
    // MARK: AWS
    
    private func updateUserProfessions() {
        
        // DynamoDB deletes attribute with nil.
        let professions: [String]? = self.professions.isEmpty ? nil : self.professions
        FullScreenIndicator.show()
        AWSClientManager.defaultClientManager().updateUserProfessions(professions, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                FullScreenIndicator.hide()
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    // Can be edit or signUp flow.
                    if self.isEditProfessions {
                        self.editProfessionsDelegate?.professionsUpdated(professions)
                        self.performSegueWithIdentifier("segueUnwindToEditProfileTableVc", sender: self)
                    } else {
                        self.redirectToMain()
                    }
                }
            })
            return nil
        })
    }
    
    // MARK: Helpers
    
    private func redirectToMain() {
        guard let window = UIApplication.sharedApplication().keyWindow,
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
}

extension ProfessionsViewController: ProfessionsDidSelectRowDelegate {
    
    func didSelectRow(profession: String) {
        self.professionTextField.text = ""
        // Don't add if profession already exists.
        guard !self.professions.contains(profession) else {
            return
        }
        self.professionsAddDelegate?.addProfession(profession)
        self.professions.insert(profession, atIndex: 0)
    }
}

extension ProfessionsViewController: ProfessionsRemoveDelegate {
    
    func removeAtIndex(professionIndex: Int) {
        self.professions.removeAtIndex(professionIndex)
    }
}
