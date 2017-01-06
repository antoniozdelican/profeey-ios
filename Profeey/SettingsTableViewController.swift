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
    @IBOutlet weak var logOutTableViewCell: UITableViewCell!
    
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
        if cell == self.logOutTableViewCell {
            self.logOutTableViewCellTapped()
        }
        if cell == self.privacyPolicyTableViewCell {
            self.privacyPolicyTableViewCellTapped()
        }
        if cell == self.termsAndConditionsTableViewCell {
            self.termsAndConditionsTableViewCellTapped()
        }
    }
    
    
    // MARK: Helpers
    
    fileprivate func logOutTableViewCellTapped() {
        let alertController = UIAlertController(title: "Log Out from Profeey?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        let deleteConfirmAction = UIAlertAction(title: "Log Out", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
            self.logOut()
        })
        alertController.addAction(deleteConfirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func privacyPolicyTableViewCellTapped() {
        guard let privacyPolicyUrl = URL(string: PRFYPrivacyPolicyUrl) else {
            return
        }
        UIApplication.shared.openURL(privacyPolicyUrl)
        
    }
    
    fileprivate func termsAndConditionsTableViewCellTapped() {
        guard let termsUrl = URL(string: PRFYTermsUrl) else {
            return
        }
        UIApplication.shared.openURL(termsUrl)
    }
    
    fileprivate func redirectToOnboarding() {
        guard let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    // MARK: AWS
    
    fileprivate func logOut() {
        print("logOut:")
        if (AWSIdentityManager.defaultIdentityManager().isLoggedIn) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            FullScreenIndicator.show()
            AWSIdentityManager.defaultIdentityManager().logout(completionHandler: {
                (result: Any?, error: Error?) in
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    FullScreenIndicator.hide()
                    // Credentials provider cleanUp.
//                    AWSIdentityManager.defaultIdentityManager().credentialsProvider.clearKeychain()
                    // User file manager cleanUp.
                    AWSUserFileManager.defaultUserFileManager().clearCache()
                    // Current user cleanUp.
                    PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB = nil
                    self.redirectToOnboarding()
                })
            })
        }
    }
}
