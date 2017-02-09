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
import AWSMobileHubHelper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Configure UI.
        self.configureUI()
        
        // Configure AWS.
        let didFinishLaunching = AWSMobileClient.sharedInstance.didFinishLaunching(application, withOptions: launchOptions)
        
        if !AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            let rootViewController = storyboard.instantiateInitialViewController()
            self.window?.rootViewController = rootViewController
        }
        
        return didFinishLaunching
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return AWSMobileClient.sharedInstance.withApplication(application, withURL: url, withSourceApplication: sourceApplication, withAnnotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("applicationWillResignActive:")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground:")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground:")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AWSMobileClient.sharedInstance.applicationDidBecomeActive(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("applicationWillTerminate:")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken:")
        AWSMobileClient.sharedInstance.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AWSMobileClient.sharedInstance.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AWSMobileClient.sharedInstance.application(application, didReceiveRemoteNotification: userInfo)

        if let notificationType = (userInfo["notificationType"] as? NSNumber)?.intValue {
            let mainTabBarController = self.window?.rootViewController as? MainTabBarController
            
            // Get new message.
            if notificationType == NotificationType.message.rawValue, let conversationId = userInfo["conversationId"] as? String, let messageId = userInfo["messageId"] as? String {
                (mainTabBarController)?.getMessage(conversationId, messageId: messageId)
            }
            
            // Open NotificationsVc if user tapped notification banner.
            if UIApplication.shared.applicationState != UIApplicationState.active {
                
                // Special case when app haven't loaded HomeVc yet. Fixes bug when posting.
                if let homeViewController = (mainTabBarController?.childViewControllers[0] as? UINavigationController)?.childViewControllers[0] as? HomeTableViewController, homeViewController.viewIfLoaded == nil {
                    homeViewController.loadViewIfNeeded()
                }
                
                // Select and load NotificationsVc always.
                (mainTabBarController)?.selectedIndex = MainChildController.notifications.rawValue
                if let navigationController = (mainTabBarController)?.selectedViewController as? UINavigationController, let childViewController = navigationController.childViewControllers[0] as? NotificationsViewController {
                    // Set segment.
                    childViewController.notificationsSegmentType = (notificationType == NotificationType.message.rawValue) ? NotificationsSegmentType.conversations : NotificationsSegmentType.notifications
                }
            }
        } else {
            print("No notificationType. This should not happen.")
        }
        
        // TODO play with constants depending on case.
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        // Called when the application receives a memory warning from the system. It is strongly recommended that you implement this method. If your app does not release enough memory during low-memory conditions, the system may terminate it outright.
        print("applicationDidReceiveMemoryWarning in AppDelegate:")
        
        print("AWSUserFileManager cache:")
        print(AWSUserFileManager.defaultUserFileManager().maxCacheSize)
        print(AWSUserFileManager.defaultUserFileManager().cachedUsedSize)
        print(AWSUserFileManager.defaultUserFileManager().pinnedSize)
        
        // Clear all cached images for now.
        AWSUserFileManager.defaultUserFileManager().clearCache()
    }
    
    fileprivate func configureUI() {
        // UINavigationBar
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = Colors.black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Colors.black, NSFontAttributeName: UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightMedium)]
        //UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Colors.black]
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage(named: "ic_navbar_shadow_resizable")
        // UITabBar
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = Colors.grey
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage(named: "ic_tabbar_shadow_resizable")
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
    }
}

