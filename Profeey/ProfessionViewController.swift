//
//  ProfessionViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 01/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol ProfessionViewDelegate {
    func removeKeyboard()
}

class ProfessionViewController: UIViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintConstant: CGFloat = 0.0
    var profession: String?
    var professionViewDelegate: ProfessionViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.continueButton.enabled = false
        self.toolbarBottomConstraintConstant = self.toolbarBottomConstraint.constant
        self.registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? ProfessionTableViewController {
            destinationViewController.professionDelegate = self
            self.professionViewDelegate = destinationViewController
        }
    }
    
    // MARK: IBActions
    
    @IBAction func continueButtonTapped(sender: AnyObject) {
        self.professionViewDelegate?.removeKeyboard()
        self.updateProfession()
    }
    
    @IBAction func skipButtonTapped(sender: AnyObject) {
        self.redirectToMain()
    }
    
    // MARK: AWS
    
    private func updateProfession() {
        
//        FullScreenIndicator.show()
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        AWSClientManager.defaultClientManager().updateProfession(self.profession, completionHandler: {
//            (task: AWSTask) in
//            dispatch_async(dispatch_get_main_queue(), {
//                FullScreenIndicator.hide()
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                if let error = task.error {
//                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
//                    self.presentViewController(alertController, animated: true, completion: nil)
//                } else {
//                    self.redirectToMain()
//                }
//            })
//            return nil
//        })
    }
    
    // MARK: Helpers
    
    private func redirectToMain() {
        guard let window = UIApplication.sharedApplication().keyWindow,
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
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
extension ProfessionViewController: ProfessionDelegate {
    
    func toggleContinueButton(enabled: Bool) {
        self.continueButton.enabled = enabled
    }
    
    func updateProfession(profession: String?) {
        self.profession = profession
    }
}
