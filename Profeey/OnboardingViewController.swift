//
//  OnboardingViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import FBSDKCoreKit
import FBSDKLoginKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.configureButtons()
        self.activityIndicatorView.isHidden = true
        // Set Facebook permissions.
        AWSFacebookSignInProvider.sharedInstance().setPermissions(["public_profile", "email"])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureButtons() {
        self.facebookButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.normal)
        self.facebookButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.highlighted)
        self.facebookButton.setTitleColor(Colors.turquoise, for: UIControlState.normal)
        self.facebookButton.setTitleColor(Colors.turquoise.withAlphaComponent(0.2), for: UIControlState.highlighted)
        self.facebookButton.adjustsImageWhenHighlighted = false
        self.signUpButton.setBackgroundImage(UIImage(named: "btn_white_borders_resizable"), for: UIControlState.normal)
        self.signUpButton.setBackgroundImage(UIImage(named: "btn_white_borders_resizable"), for: UIControlState.highlighted)
        self.signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.signUpButton.setTitleColor(UIColor.white.withAlphaComponent(0.2), for: UIControlState.highlighted)
        
        self.termsButton.setAttributedTitle(NSAttributedString(string: "Terms", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSForegroundColorAttributeName: UIColor.white]), for: UIControlState.normal)
        self.privacyPolicyButton.setAttributedTitle(NSAttributedString(string: "Privacy Policy.", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSForegroundColorAttributeName: UIColor.white]), for: UIControlState.normal)
        self.logInButton.setAttributedTitle(NSAttributedString(string: "Log in.", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSForegroundColorAttributeName: UIColor.white]), for: UIControlState.normal)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? UsernameTableViewController {
            // It's coming from Facebook logIn.
            destinationViewController.isUserPoolUser = false
        }
    }
    
    // MARK: IBActions
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        // Check again because it can be tapped before detecting.
        if !AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            self.facebookLogIn()
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        UIView.transition(
            with: self.signUpButton,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: {
                self.signUpButton.isHighlighted = true
        },
            completion: nil)
    }
    
    @IBAction func termsButtonTapped(_ sender: Any) {
        if let termsUrl = URL(string: PRFYTermsUrl) {
            UIApplication.shared.openURL(termsUrl)
        }
    }
    
    @IBAction func privacyPolicyButtonTapped(_ sender: Any) {
        if let privacyPolicyUrl = URL(string: PRFYPrivacyPolicyUrl) {
            UIApplication.shared.openURL(privacyPolicyUrl)
        }
    }
    
    // MARK: Helpers
    
    fileprivate func redirectToMain() {
        if let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
                window.rootViewController = initialViewController
        }
    }
    
    // For disabledUser.
    fileprivate func redirectToOnboarding() {
        if let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController() {
            window.rootViewController = initialViewController
        }
    }
    
    fileprivate func showDisabledMessage() {
        let alertController = self.getSimpleAlertWithTitle("Disabled account", message: "Your account has been disabled for violating our terms. Go to www.profeey.com/terms and learn more.", cancelButtonTitle: "Ok")
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func enableButtons() {
        // Enable all buttons.
        self.signUpButton.isEnabled = true
        //self.termsButton.isEnabled = true
        self.privacyPolicyButton.isEnabled = true
        self.logInButton.isEnabled = true
        self.facebookButton.isEnabled = true
        // Remove activity.
        self.activityIndicatorView.isHidden = true
        self.activityIndicatorView.stopAnimating()
    }
    
    // MARK: AWS
    
    fileprivate func facebookLogIn() {
        print("facebookLogIn:")
        // 1. logIn user with Facebook.
        self.logInWithFacebookSignInProvider(AWSFacebookSignInProvider.sharedInstance())
    }
    
    fileprivate func logInWithFacebookSignInProvider(_ signInProvider: AWSSignInProvider) {
        print("logInWithSignInProvider:")
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        AWSIdentityManager.defaultIdentityManager().loginWithSign(signInProvider, completionHandler: {
            (result: Any?, error: Error?) in
            DispatchQueue.main.async(execute: {
                //UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("logInWithSignInProvider error: \(error!)")
                    return
                }
                // Disable all buttons.
                self.signUpButton.isEnabled = false
                //self.termsButton.isEnabled = false
                self.privacyPolicyButton.isEnabled = false
                self.logInButton.isEnabled = false
                UIView.transition(
                    with: self.facebookButton,
                    duration: 0.2,
                    options: .transitionCrossDissolve,
                    animations: {
                        self.facebookButton.isEnabled = false
                },
                    completion: {
                        (finished: Bool) in
                        // Add activity
                        self.activityIndicatorView.isHidden = false
                        self.activityIndicatorView.startAnimating()
                })
                /* 
                 2. Check if user already exists in DynamoDB. 
                 If not, get email, firstName, lastName from Facenook Graph API and create user in DynamoDB.
                 If yes, just redirect to MainVc.
                */
                self.getCurrentUser()
            })
        })
    }
    
    fileprivate func getCurrentUser() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getCurrentUserDynamoDB({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    // Handle error.
                    print("getCurrentUser error: \(task.error!)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: task.error?.localizedDescription, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                    self.enableButtons()
                    return
                }
                if let user = task.result as? AWSUser {
                    // User already exists in DynamoDB, so this is logIn.
                    
                    // Check if disabled. If yes, logOut.
                    if let isDisabled = user._isDisabled, isDisabled.intValue == 1 {
                        self.logOut()
                    } else {
                        // Update enpointARN.
                        self.createEndpointUser()
                    }
                } else {
                    // User doesn't exists in DynamoDB, so this is signUp.
                    self.getFacebookGraphData()
                }
            })
            return nil
        })
    }
    
    fileprivate func getFacebookGraphData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id, first_name, last_name, email"]).start(completionHandler: {
            (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("getFacebookGraphData error: \(error!)")
                    self.enableButtons()
                    return
                }
                guard let result = result as? [AnyHashable: Any?] else {
                    print("No result!")
                    self.enableButtons()
                    return
                }
                let email = result["email"] as? String
                let firstName = result["first_name"] as? String
                let lastName = result["last_name"] as? String
                // 3. Create user in DynamoDB.
                self.createFacebookUser(email, firstName: firstName, lastName: lastName)
            })
        })
    }
    
    fileprivate func createFacebookUser(_ email: String?, firstName: String?, lastName: String?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createFacebookUserDynamoDB(email, firstName: firstName, lastName: lastName, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    print("createFacebookUser error: \(task.error!)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: task.error?.localizedDescription, cancelButtonTitle: "Try Again")
                    self.present(alertController, animated: true, completion: nil)
                    self.enableButtons()
                    return
                }
                // 4. Segue to UsernameVc.
                self.performSegue(withIdentifier: "segueToUsernameVc", sender: self)
            })
            return nil
        })
    }
    
    /*
     Each time a user Logs in, create/update an EnpointUser in DynamoDB.
     On User Sign up, it will be done in didRegisterForRemoteNotificationsWithDeviceToken after user confirms
     remote notifications.
     */
    fileprivate func createEndpointUser() {
        if let endpointARN = AWSPushManager.defaultPushManager().endpointARN {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            PRFYDynamoDBManager.defaultDynamoDBManager().createEndpointUserDynamoDB(endpointARN, completionHandler: {
                (task: AWSTask) in
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let error = task.error {
                        print("createEndpointUser error :\(error)")
                    }
                    self.redirectToMain()
                })
                return nil
            })
        } else {
            self.redirectToMain()
        }
    }
    
    // Just in case it's a disabled user.
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
                
                // Present disabled message.
                self.showDisabledMessage()
                
                // Redirect.
                self.redirectToOnboarding()
            })
        })
    }
    
}
