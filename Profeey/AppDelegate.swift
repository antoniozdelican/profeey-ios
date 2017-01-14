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
        self.configureUI()
        
        let didFinishLaunching = AWSMobileClient.sharedInstance.didFinishLaunching(application, withOptions: launchOptions)
        
        // Check if user is logged in.
        if !AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            let rootViewController = storyboard.instantiateInitialViewController()
            self.window?.rootViewController = rootViewController
        }
        
        // TODO: save userId (identityId) for this device (endpointARN)
        // This is done upon user signIn.
        // For user signOut - delete record in DynamoDB??
//        if let endpointARN = AWSPushManager.defaultPushManager().endpointARN {
//            PRFYDynamoDBManager.defaultDynamoDBManager().createEndpointUserDynamoDB(endpointARN, completionHandler: {
//                (task: AWSTask) in
//                return nil
//            })
//        }
        
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
        
        // Clear the badge icon when you open the app.
        UIApplication.shared.applicationIconBadgeNumber = 0
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
        AWSMobileClient.sharedInstance.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AWSMobileClient.sharedInstance.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AWSMobileClient.sharedInstance.application(application, didReceiveRemoteNotification: userInfo)
        
        // Set badge.
        //(self.window?.rootViewController as? MainTabBarController)?.toggleNewNotificationsView(false)
        
        // Determine notification type.
        if let conversationId = userInfo["conversationId"] as? String, let messageId = userInfo["messageId"] as? String {
            self.getMessage(conversationId, messageId: messageId)
        } else {
            print("It's something else!")
        }
        
        // TODO play with constants depending on case.
        completionHandler(UIBackgroundFetchResult.newData)
        
        // Open NotificationsVc if needed.
        if UIApplication.shared.applicationState != UIApplicationState.active {
            (self.window?.rootViewController as? MainTabBarController)?.selectNotificationsViewController()
        }
    }
    
    fileprivate func configureUI() {
        // UINavigationBar
        UINavigationBar.appearance().barTintColor = Colors.whiteDark
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
    
    // MARK: AWS
    
    fileprivate func getMessage(_ conversationId: String, messageId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getMessageDynamoDB(conversationId, messageId: messageId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    print("getConversationMessage error: \(task.error!)")
                    return
                }
                guard let awsMessage = task.result as? AWSMessage else {
                    print("getMessage error: Not AWSMessage. This should not happen.")
                    return
                }
                let message = Message(conversationId: awsMessage._conversationId, messageId: awsMessage._messageId, created: awsMessage._created, messageText: awsMessage._messageText, senderId: awsMessage._senderId, recipientId: awsMessage._recipientId)
                // Notify observers.
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: APNsNewMessageNotificationKey), object: self, userInfo: ["message": message])
            })
            return nil
        })
    }
}

