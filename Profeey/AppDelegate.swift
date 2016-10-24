//
//  AppDelegate.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSCognito
import AWSCore

import AWSCognitoIdentityProvider
import AWSMobileHubHelper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.configureUI()
        
        AWSClientManager.defaultClientManager().userPool?.delegate = self
        AWSClientManager.defaultClientManager().getUserDetails({
            (task: AWSTask) in
            return nil
        })
        return true
    }
    
    fileprivate func configureUI() {
        // UINavigationBar
        UINavigationBar.appearance().barTintColor = Colors.greyLight
        // DON'T FCKING CHANGE translucent!! it messes up capture.
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = Colors.black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Colors.black]
        
        // UITabBar
        UITabBar.appearance().barTintColor = Colors.greyLight
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = Colors.black
        
        // UITableView
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorColor = Colors.grey
        // WARNING
        //UITableView.appearance().separatorInset = UIEdgeInsets.zero
        
        // UITableViewCell
        let colorView = UIView()
        colorView.backgroundColor = Colors.greyLight
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        // UITextField
        UITextField.appearance().tintColor = Colors.black
        
        // UITextView
        UITextView.appearance().tintColor = Colors.black
        
        // UISearchBar
        UISearchBar.appearance().searchBarStyle = UISearchBarStyle.minimal
    }
}

extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        print("Started password authentication:")
        // If calling from LogInViewController stay there.
//        if let rootViewController = self.window?.rootViewController,
//            let presentedViewController = rootViewController.presentedViewController as? UINavigationController,
//            let logInViewController = presentedViewController.topViewController as? LogInViewController {
//            print("Called from logInViewController.")
//            return logInViewController
//        }
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let rootViewController = storyboard.instantiateInitialViewController() as! OnboardingNavigationController
        DispatchQueue.main.async(execute: {
            self.window?.rootViewController = rootViewController
        })
        return rootViewController
    }
    
}

extension AppDelegate: IncompleteSignUpDelegate {
    
    func preferredUsernameNotSet() {
        print("PreferredUsername not set:")
//        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
//        if let navigationViewController = storyboard.instantiateInitialViewController() as? UINavigationController,
//        let _ = navigationViewController.childViewControllers[0] as? UsernameViewController {
//            dispatch_async(dispatch_get_main_queue(), {
//                self.window?.rootViewController = navigationViewController
//            })
//        }
    }
}

