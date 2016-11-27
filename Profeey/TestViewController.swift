//
//  TestViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            self.getCurrentUser()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        self.logOut()
    }
    
    fileprivate func redirectToOnboarding() {
        guard let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    // MARK: AWS
    
    fileprivate func getCurrentUser() {
        // Get currentUser from DynamoDB and check if it has preferredUsername in DynamoDB.
        PRFYDynamoDBManager.defaultDynamoDBManager().getCurrentUserDynamoDB({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                if let error = task.error {
                    print("getCurrentUser error: \(error)")
                } else {
                    guard let awsUser = task.result as? AWSUser else {
                        print("getCurrentUser error: Not an awsUser.")
                        return
                    }
                    guard awsUser._preferredUsername != nil else {
                        // This only happens if users closes the app on the UsernameTableViewController of the Welcome flow.
                        print("getCurrentUser error: currentUser doesn't have preferredUsername.")
                        guard let window = UIApplication.shared.keyWindow,
                            let initialViewController = UIStoryboard(name: "Welcome", bundle: nil).instantiateInitialViewController() else {
                                return
                        }
                        window.rootViewController = initialViewController
                        return
                    }
                }
            })
            return nil
        })

    }
    
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
