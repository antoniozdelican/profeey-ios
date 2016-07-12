//
//  ProfessionsWelcomeViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 13/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class ProfessionsWelcomeViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIBarButtonItem!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintConstant: CGFloat = 0.0
    var childViewController: ProfessionsWelcomeTableViewController!
    
    var professions: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        self.nextButton.addTarget(self, action: #selector(ProfessionsWelcomeViewController.nextButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.nextButton.enabled = false
        self.skipButton.action = #selector(ProfessionsWelcomeViewController.skipButtonTapped(_:))
        self.toolbarBottomConstraintConstant = self.toolbarBottomConstraint.constant
        self.registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Triggered when child is embeded in container view.
        if let destinationViewController = segue.destinationViewController as? ProfessionsWelcomeTableViewController {
            // Set delegate.
            destinationViewController.delegate = self
        }
    }
    
    // MARK: Tappers
    
    func nextButtonTapped(sender: UIButton) {
        self.saveUserProfessions()
    }
    
    func skipButtonTapped(sender: UIButton) {
        self.performSegueWithIdentifier("segueToDiscoverVc", sender: self)
    }
    
    // MARK: AWS
    
    private func saveUserProfessions() {
        guard self.professions.count > 0 else {
            return
        }
        FullScreenIndicator.show()
        AWSRemoteService.defaultRemoteService().saveUserProfessions(professions, completionHandler: {
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
                    self.performSegueWithIdentifier("segueToDiscoverVc", sender: self)
                }
            })
            return nil
        })
    }
    
    // MARK: Keyboard notifications
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillBeShown(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillBeHidden(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    func keyboardWillBeShown(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let duration = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! Double
        self.toolbarBottomConstraint.constant = keyboardSize.height
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let duration = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! Double
        self.toolbarBottomConstraint.constant = toolbarBottomConstraintConstant
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        })
    }

}

extension ProfessionsWelcomeViewController: ProfessionsWelcomeProtocol {
    
    func toggleNextButton(enabled: Bool) {
        self.nextButton.enabled = enabled
    }
    
    func addProfession(profession: String) {
        //self.professions.insert(profession)
    }
    
    func removeProfession(profession: String) {
        //self.professions.remove(profession)
    }
}
