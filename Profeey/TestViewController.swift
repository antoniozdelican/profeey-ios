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
        self.handleLogout()
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
    
    fileprivate func handleLogout() {
        print("handleLogout")
        if (AWSIdentityManager.defaultIdentityManager().isLoggedIn) {
            print("AWSIdentityManager.defaultIdentityManager().isLoggedIn")
            AWSIdentityManager.defaultIdentityManager().logout(completionHandler: {
                (result: Any?, error: Error?) in
                DispatchQueue.main.async(execute: {
                    self.redirectToOnboarding()
                })
            })
        }
    }

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
