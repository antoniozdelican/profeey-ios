//
//  AppDelegate.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

import AWSMobileHubHelper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AWSCognitoIdentityInteractiveAuthenticationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // UINavigationBar
        UINavigationBar.appearance().barStyle = .Default
        UINavigationBar.appearance().tintColor = Colors.black
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Colors.blue]
        UINavigationBar.appearance().barTintColor = Colors.greyLight
//        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        // UITabBar
        UITabBar.appearance().translucent = true
        UITabBar.appearance().barTintColor = Colors.blue.colorWithAlphaComponent(0.8)
        
        // UITableView
        UITableView.appearance().backgroundColor = Colors.greyLight
        UITableView.appearance().tableFooterView = UIView() // for removing empty cells
        
        // UITableViewCell
        let colorView = UIView()
        colorView.backgroundColor = Colors.greyLight
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        // UITextField
        UITextField.appearance().tintColor = Colors.black
        
        // UITextView
        UITextView.appearance().tintColor = Colors.black
        
        // AWS bootstrap
        let remoteService = AWSRemoteService.defaultRemoteService()
        // Set pool delegate
        remoteService.userPool.delegate = self
        // Update user details.
        remoteService.setUserDetails()
        
        // Resume AWS session
        remoteService.resumeSession({
            (task: AWSTask) in
            return nil
        })
        
        return true
    }
    
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

