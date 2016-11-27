//
//  AppDelegate.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import CoreFoundation

import UIKit
//import AWSCognito
//import AWSCore
//
//import AWSCognitoIdentityProvider
import AWSMobileHubHelper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.configureUI()
        
        let didFinishLaunching = AWSMobileClient.sharedInstance.didFinishLaunching(application, withOptions: launchOptions)
        
        // Check if user is logged in.
        if !AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            let rootViewController = storyboard.instantiateInitialViewController()
            self.window?.rootViewController = rootViewController
        } else {
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
                        if awsUser._preferredUsername == nil {
                            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
                            let rootViewController = storyboard.instantiateInitialViewController()
                            self.window?.rootViewController = rootViewController
                        }
                    }
                })
                return nil
            })
        }
        
        return didFinishLaunching
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

        return AWSMobileClient.sharedInstance.withApplication(application, withURL: url, withSourceApplication: sourceApplication, withAnnotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AWSMobileClient.sharedInstance.applicationDidBecomeActive(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        // Clear the badge icon when you open the app.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AWSMobileClient.sharedInstance.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AWSMobileClient.sharedInstance.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        AWSMobileClient.sharedInstance.application(application, didReceiveRemoteNotification: userInfo)
    }

//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        self.configureUI()
//        
//        AWSClientManager.defaultClientManager().userPool?.delegate = self
//        AWSClientManager.defaultClientManager().getUserDetails({
//            (task: AWSTask) in
//            return nil
//        })
//        return true
//    }
    
    fileprivate func configureUI() {
        // UINavigationBar
        UINavigationBar.appearance().barTintColor = Colors.whiteDark
        // DON'T FCKING CHANGE translucent!! it messes up capture.
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = Colors.black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Colors.black]
        
        // UITabBar
        UITabBar.appearance().barTintColor = Colors.whiteDark
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = Colors.grey
        
        // UITableView
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorColor = Colors.greyLight
        
        // UITableViewCell
        let colorView = UIView()
        colorView.backgroundColor = Colors.whiteDark
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        // UITextField
        UITextField.appearance().tintColor = Colors.black
        
        // UITextView
        UITextView.appearance().tintColor = Colors.black
        
        // UISearchBar
        UISearchBar.appearance().searchBarStyle = UISearchBarStyle.minimal
    }
}

//extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
//    
//    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
//        print("AWSCognitoIdentityInteractiveAuthenticationDelegate is AppDelegate")
//        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
//        let rootViewController = storyboard.instantiateInitialViewController() as! OnboardingNavigationController
//        DispatchQueue.main.async(execute: {
//            self.window?.rootViewController = rootViewController
//        })
//        return rootViewController
//    }
//    
//}

//extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
//    
//    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
//        print("Started password authentication:")
//        // If calling from LogInViewController stay there.
////        if let rootViewController = self.window?.rootViewController,
////            let presentedViewController = rootViewController.presentedViewController as? UINavigationController,
////            let logInViewController = presentedViewController.topViewController as? LogInViewController {
////            print("Called from logInViewController.")
////            return logInViewController
////        }
//        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
//        let rootViewController = storyboard.instantiateInitialViewController() as! OnboardingNavigationController
//        DispatchQueue.main.async(execute: {
//            self.window?.rootViewController = rootViewController
//        })
//        return rootViewController
//    }
//    
//}
//
//extension AppDelegate: IncompleteSignUpDelegate {
//    
//    func preferredUsernameNotSet() {
//        print("PreferredUsername not set:")
////        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
////        if let navigationViewController = storyboard.instantiateInitialViewController() as? UINavigationController,
////        let _ = navigationViewController.childViewControllers[0] as? UsernameViewController {
////            dispatch_async(dispatch_get_main_queue(), {
////                self.window?.rootViewController = navigationViewController
////            })
////        }
//    }
//}

