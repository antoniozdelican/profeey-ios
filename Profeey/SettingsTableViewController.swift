//
//  SettingsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 16/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var privacyPolicyTableViewCell: UITableViewCell!
    @IBOutlet weak var termsAndConditionsTableViewCell: UITableViewCell!
    @IBOutlet weak var signOutTableViewCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell == self.signOutTableViewCell {
            self.signOutTableViewCellTapped()
        }
    }
    
    
    // MARK: Helpers
    
    fileprivate func signOutTableViewCellTapped() {
        let alertController = UIAlertController(title: "Sign Out from Profeey?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        let deleteConfirmAction = UIAlertAction(title: "Sign Out", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
//            self.signOut()
            self.handleLogout()
        })
        alertController.addAction(deleteConfirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func redirectToOnboarding() {
        guard let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    // MARK: AWS
    
//    fileprivate func signOut() {
//        AWSClientManager.defaultClientManager().signOut({
//            (task: AWSTask) in
//            DispatchQueue.main.async(execute: {
//                if let error = task.error {
//                    print("signOut error: \(error)")
//                } else {
//                    self.redirectToOnboarding()
//                }
//            })
//            return nil
//        })
//    }
    
    //NEW
    func handleLogout() {
        if (AWSIdentityManager.defaultIdentityManager().isLoggedIn) {
            AWSIdentityManager.defaultIdentityManager().logout(completionHandler: {
                (result: Any?, error: Error?) in
                DispatchQueue.main.async(execute: {
                    if let error = error {
                        print("signOut error: \(error)")
                    } else {
                        self.redirectToOnboarding()
                    }
                })
            })
        }
    }
}
