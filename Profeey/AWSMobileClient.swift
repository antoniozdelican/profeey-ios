//
//  AWSMobileClient.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSMobileHubHelper
//import AWSMobileAnalytics

/**
 * AWSMobileClient is a singleton that bootstraps the app. It creates an identity manager to establish the user identity with Amazon Cognito.
 */
class AWSMobileClient: NSObject {
    // Amazon Mobile Analytics client - Use to generate custom or monetization analytics events.
    //var mobileAnalytics: AWSMobileAnalytics!
    
    // Shared instance of this class
    static let sharedInstance = AWSMobileClient()
    private var isInitialized: Bool
    
    private override init() {
        self.isInitialized = false
        super.init()
    }
    
    deinit {
        // Should never be called
        print("Mobile Client deinitialized. This should not happen.")
    }
    
    /**
     * Configure third-party services from application delegate with url, application
     * that called this provider, and any annotation info.
     *
     * - parameter application: instance from application delegate.
     * - parameter url: called from application delegate.
     * - parameter sourceApplication: that triggered this call.
     * - parameter annotation: from application delegate.
     * - returns: true if call was handled by this component
     */
    func withApplication(_ application: UIApplication, withURL url: URL, withSourceApplication sourceApplication: String?, withAnnotation annotation: Any) -> Bool {
        print("withApplication:withURL")
        AWSIdentityManager.defaultIdentityManager().interceptApplication(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        if (!self.isInitialized) {
            self.isInitialized = true
        }
        return false;
    }
    
    /**
     * Performs any additional activation steps required of the third party services
     * e.g. Facebook
     *
     * - parameter application: from application delegate.
     */
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive:")
        //self.initializeMobileAnalytics()
    }
    
//    private func initializeMobileAnalytics() {
//        if (self.mobileAnalytics == nil) {
//            self.mobileAnalytics = AWSMobileAnalytics.default()
//        }
//    }
    
    /**
     * Handles callback from iOS platform indicating push notification registration was a success.
     * - parameter application: application
     * - parameter deviceToken: device token
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AWSPushManager.defaultPushManager().interceptApplication(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    /**
     * Handles callback from iOS platform indicating push notification registration failed.
     * - parameter application: application
     * - parameter error: error
     */
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AWSPushManager.defaultPushManager().interceptApplication(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    /**
     * Handles a received push notification.
     * - parameter userInfo: push notification contents
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("didReceiveRemoteNotification:")
        AWSPushManager.defaultPushManager().interceptApplication(application, didReceiveRemoteNotification: userInfo)
    }
    
    /**
     * Configures all the enabled AWS services from application delegate with options.
     *
     * - parameter application: instance from application delegate.
     * - parameter launchOptions: from application delegate.
     */
    func didFinishLaunching(_ application: UIApplication, withOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("didFinishLaunching:")
        
        // Register the sign in provider instances with their unique identifier.
        
        // Set up cognito user pool.
        self.setupUserPool()
        
        // Set up Cloud Logic API invocation clients.
        self.setupCloudLogicAPI()
        
        let didFinishLaunching: Bool = AWSIdentityManager.defaultIdentityManager().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        
        /*
         AWSPushManager.defaultPushManager().interceptApplication is called only in MainTabBarVc to 
         prevent registering push notifications before user actually Signs Up into the newly installed app.
         */
//        didFinishLaunching = didFinishLaunching && AWSPushManager.defaultPushManager().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        
        if (!self.isInitialized) {
            AWSIdentityManager.defaultIdentityManager().resumeSession(completionHandler: {
                (result: Any?, error: Error?) in
                print("resumeSession:")
                print("Result: \(result) \n Error:\(error)")
            })
        }
        
        return didFinishLaunching
    }
    
    fileprivate func setupUserPool() {
        // Register user pool configuration.
        AWSCognitoUserPoolsSignInProvider.setupUserPool(withId: AWSCognitoUserPoolId, cognitoIdentityUserPoolAppClientId: AWSCognitoUserPoolAppClientId, cognitoIdentityUserPoolAppClientSecret: AWSCognitoUserPoolClientSecret, region: AWSCognitoUserPoolRegion)
        
        AWSSignInProviderFactory.sharedInstance().registerAWSSign(AWSCognitoUserPoolsSignInProvider.sharedInstance(), forKey:AWSCognitoUserPoolsSignInProviderKey)
    }
    
    fileprivate func setupCloudLogicAPI() {
//        let serviceConfiguration = AWSServiceConfiguration(region: AWSCloudLogicDefaultRegion, credentialsProvider: AWSIdentityManager.defaultIdentityManager().credentialsProvider)
//        PRFYCloudSearchProxyClient.registerClientWithConfiguration(configuration: serviceConfiguration!, forKey: AWSCloudLogicDefaultConfigurationKey as NSString)
    }
    
}
