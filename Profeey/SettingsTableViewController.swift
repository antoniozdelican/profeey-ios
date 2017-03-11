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

    @IBOutlet weak var editProfileTableViewCell: UITableViewCell!
    @IBOutlet weak var editEmailTableViewCell: UITableViewCell!
    @IBOutlet weak var editPasswordTableViewCell: UITableViewCell!
    @IBOutlet weak var privacyPolicyTableViewCell: UITableViewCell!
    @IBOutlet weak var termsAndConditionsTableViewCell: UITableViewCell!
    @IBOutlet weak var getHelpTableViewCell: UITableViewCell!
    @IBOutlet weak var logOutTableViewCell: UITableViewCell!
    @IBOutlet weak var currentEmailLabel: UILabel!
    
    var user: EditUser?
    var currentEmail: String?
    var currentEmailVerified: NSNumber?
    var isFacebookUser: NSNumber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.register(UINib(nibName: "SettingsTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "settingsTableSectionHeader")
        
        // Configure current email.
        self.currentEmailLabel.text = self.currentEmail
        if let currentEmailVerified = self.currentEmailVerified, currentEmailVerified.intValue == 1 {
            self.currentEmailLabel.textColor = Colors.grey
        } else {
            self.currentEmailLabel.textColor = Colors.red
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateEmailNotification(_:)), name: NSNotification.Name(UpdateEmailNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? EditProfileTableViewController {
            childViewController.user = self.user
        }
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? EditEmailTableViewController {
            childViewController.currentEmail = self.currentEmail
            childViewController.currentEmailVerified = self.currentEmailVerified
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell == self.editProfileTableViewCell {
            self.performSegue(withIdentifier: "segueToEditProfileVc", sender: cell)
        }
        if cell == self.editEmailTableViewCell {
            self.performSegue(withIdentifier: "segueToEditEmail", sender: self)
        }
        if cell == self.editPasswordTableViewCell {
            self.performSegue(withIdentifier: "segueToEditPassword", sender: self)
        }
        if cell == self.privacyPolicyTableViewCell {
            if let privacyPolicyUrl = URL(string: PRFYPrivacyPolicyUrl) {
                UIApplication.shared.openURL(privacyPolicyUrl)
            }
        }
        if cell == self.termsAndConditionsTableViewCell {
            if let termsUrl = URL(string: PRFYTermsUrl) {
                UIApplication.shared.openURL(termsUrl)
            }
        }
        if cell == self.getHelpTableViewCell {
            if let getHelpUrl = URL(string: PRFYGetHelpUrl) {
                UIApplication.shared.openURL(getHelpUrl)
            }
        }
        if cell == self.logOutTableViewCell {
            self.logOutTableViewCellTapped()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Remove editEmail and editPassword if facebookUser.
        if let isFacebookUser = self.isFacebookUser, isFacebookUser.intValue == 1 {
            if indexPath == IndexPath(row: 1, section: 0) {
                return 0.0
            }
            if indexPath == IndexPath(row: 2, section: 0) {
                return 0.0
            }
        }
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "settingsTableSectionHeader") as? SettingsTableSectionHeader
            header?.titleLabel.text = "ACCOUNT"
            return header
        case 1:
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "settingsTableSectionHeader") as? SettingsTableSectionHeader
            header?.titleLabel.text = "ABOUT"
            return header
        default:
            return UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 40.0
        }
        return 32.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    
    // MARK: Helpers
    
    fileprivate func logOutTableViewCellTapped() {
        let alertController = UIAlertController(title: "Log Out from Profeey?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        let deleteConfirmAction = UIAlertAction(title: "Log Out", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
            // First remove endpointUser (if exists) and then logOut.
            self.removeEndpointUser()
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
    
    fileprivate func removeEndpointUser() {
        if (AWSIdentityManager.defaultIdentityManager().isLoggedIn) {
            FullScreenIndicator.show()
            if let endpointARN = AWSPushManager.defaultPushManager().endpointARN {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                PRFYDynamoDBManager.defaultDynamoDBManager().removeEndpointUserDynamoDB(endpointARN, completionHandler: {
                    (task: AWSTask) in
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if let error = task.error {
                            print("removeEndpointUser error :\(error)")
                        }
                        self.logOut()
                    })
                    return nil
                })
            } else {
                self.logOut()
            }
        }
    }
    
    fileprivate func logOut() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        AWSIdentityManager.defaultIdentityManager().logout(completionHandler: {
            (result: Any?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                // Don't put error because it will be shown before redirection!
                
                // Credentials provider cleanUp.
                //AWSIdentityManager.defaultIdentityManager().credentialsProvider.clearKeychain()
                // User file manager cleanUp.
                AWSUserFileManager.defaultUserFileManager().clearCache()
                // Current user cleanUp.
                PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB = nil
                // Clean NSUserDefaults also.
                LocalUser.clearAllLocal()
                
                // Redirect.
                self.redirectToOnboarding()
            })
        })
    }
}

extension SettingsTableViewController {
    
    // MARK: NotificationCenterActions
    
    func updateEmailNotification(_ notification: NSNotification) {
        guard let email = notification.userInfo?["email"] as? String, let emailVerified = notification.userInfo?["emailVerified"] as? NSNumber else {
            return
        }
        guard self.user?.userId == AWSIdentityManager.defaultIdentityManager().identityId else {
            return
        }
        self.currentEmail = email
        self.currentEmailVerified = emailVerified
        self.currentEmailLabel.text = self.currentEmail
        if let currentEmailVerified = self.currentEmailVerified, currentEmailVerified.intValue == 1 {
            self.currentEmailLabel.textColor = Colors.grey
        } else {
            self.currentEmailLabel.textColor = Colors.red
        }
    }
}
