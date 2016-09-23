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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.configureUI()
        
        AWSClientManager.defaultClientManager().userPool?.delegate = self
        AWSClientManager.defaultClientManager().getUserDetails({
            (task: AWSTask) in
            return nil
        })
        return true
    }
    
    private func configureUI() {
        // UINavigationBar
        UINavigationBar.appearance().backgroundColor = Colors.greyLight
        UINavigationBar.appearance().barTintColor = Colors.greyLight
        // DON'T FCKING CHANGE translucent!! it messes up capture.
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = Colors.blue
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Colors.blue]
        
        // UITabBar
        //UITabBar.appearance().barTintColor = Colors.greyLight
        UITabBar.appearance().barTintColor = UIColor.whiteColor()
        UITabBar.appearance().translucent = false
        UITabBar.appearance().tintColor = Colors.blue
        
        // UITableView
        //UITableView.appearance().backgroundColor = Colors.greyLight
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorColor = Colors.grey
        // WARNING
        //UITableView.appearance().separatorInset = UIEdgeInsetsZero
        
        // UITableViewCell
        let colorView = UIView()
        colorView.backgroundColor = Colors.greyLight
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        // UITextField
        UITextField.appearance().tintColor = Colors.black
        
        // UITextView
        UITextView.appearance().tintColor = Colors.black
        
        // UISearchBar
        UISearchBar.appearance().searchBarStyle = UISearchBarStyle.Minimal
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
        dispatch_async(dispatch_get_main_queue(), {
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

