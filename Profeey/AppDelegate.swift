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
        
//        AWSClientManager.defaultClientManager().userPool?.delegate = self
//        AWSClientManager.defaultClientManager().incompleteSignUpDelegate = self
//        AWSClientManager.defaultClientManager().getCurrentUser({
//            (task: AWSTask) in
//            return nil
//        })
        return true
    }
    
    private func configureUI() {
        // UINavigationBar
        UINavigationBar.appearance().barTintColor = Colors.greyLight
        UINavigationBar.appearance().tintColor = Colors.black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Colors.blue]
        UINavigationBar.appearance().shadowImage = UIImage()
        // UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        // UITabBar
        // UITabBar.appearance().translucent = true
        UITabBar.appearance().translucent = false
        // UITabBar.appearance().barTintColor = Colors.blue.colorWithAlphaComponent(0.8)
        UITabBar.appearance().barTintColor = Colors.greyLight
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        
        // UITableView
        UITableView.appearance().backgroundColor = Colors.greyLight
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorColor = Colors.grey
        UITableView.appearance().separatorInset = UIEdgeInsetsZero
        
        // UITableViewCell
        let colorView = UIView()
        colorView.backgroundColor = Colors.greyLight
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        // UITextField
        UITextField.appearance().tintColor = Colors.black
        
        // UITextView
        UITextView.appearance().tintColor = Colors.black
    }
}

extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    // Set up password authentication ui to retrieve username and password from the user.
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        print("Started password authentication:")
        // If calling from LogInViewController stay there.
        if let rootViewController = self.window?.rootViewController,
            let presentedViewController = rootViewController.presentedViewController as? UINavigationController,
            let logInViewController = presentedViewController.topViewController as? LogInViewController {
            print("Called from logInViewController.")
            return logInViewController
        }
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let rootViewController = storyboard.instantiateInitialViewController() as! OnboardingViewController
        dispatch_async(dispatch_get_main_queue(), {
            self.window?.rootViewController = rootViewController
        })
        return rootViewController
    }
    
}

extension AppDelegate: IncompleteSignUpDelegate {
    
    func preferredUsernameNotSet() {
        print("PreferredUsername not set:")
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        if let navigationViewController = storyboard.instantiateInitialViewController() as? UINavigationController,
        let _ = navigationViewController.childViewControllers[0] as? UsernameViewController {
            dispatch_async(dispatch_get_main_queue(), {
                self.window?.rootViewController = navigationViewController
            })
        }
    }
}

