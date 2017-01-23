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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.register(UINib(nibName: "SettingsTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "settingsTableSectionHeader")
        
        // Configure current email.
        self.currentEmailLabel.text = self.currentEmail
        
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
            self.logOut()
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

extension SettingsTableViewController {
    
    // MARK: NotificationCenterActions
    
    func updateEmailNotification(_ notification: NSNotification) {
        guard let email = notification.userInfo?["email"] as? String else {
            return
        }
        guard self.user?.userId == AWSIdentityManager.defaultIdentityManager().identityId else {
            return
        }
        self.currentEmail = email
    }
}
