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
import AWSMobileAnalytics

/**
 * AWSMobileClient is a singleton that bootstraps the app. It creates an identity manager to establish the user identity with Amazon Cognito.
 */
class AWSMobileClient: NSObject {
    // Amazon Mobile Analytics client - Use to generate custom or monetization analytics events.
    var mobileAnalytics: AWSMobileAnalytics!
    
    // Shared instance of this class
    static let sharedInstance = AWSMobileClient()
    private var isInitialized: Bool
    
    private override init() {
        isInitialized = false
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
    func withApplication(application: UIApplication, withURL url: NSURL, withSourceApplication sourceApplication: String?, withAnnotation annotation: AnyObject) -> Bool {
        print("withApplication:withURL")
        AWSIdentityManager.defaultIdentityManager().interceptApplication(application, open: url as URL, sourceApplication: sourceApplication, annotation: annotation)
        
        if (!isInitialized) {
            isInitialized = true
        }
        
        return false;
    }
    
    /**
     * Performs any additional activation steps required of the third party services
     * e.g. Facebook
     *
     * - parameter application: from application delegate.
     */
    func applicationDidBecomeActive(application: UIApplication) {
        print("applicationDidBecomeActive:")
        initializeMobileAnalytics()
    }
    
    private func initializeMobileAnalytics() {
        if (mobileAnalytics == nil) {
            mobileAnalytics = AWSMobileAnalytics.default()
        }
    }
    
    /**
     * Handles callback from iOS platform indicating push notification registration was a success.
     * - parameter application: application
     * - parameter deviceToken: device token
     */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        AWSPushManager.defaultPushManager().interceptApplication(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken as Data)
    }
    
    /**
     * Handles callback from iOS platform indicating push notification registration failed.
     * - parameter application: application
     * - parameter error: error
     */
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        AWSPushManager.defaultPushManager().interceptApplication(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    /**
     * Handles a received push notification.
     * - parameter userInfo: push notification contents
     */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        AWSPushManager.defaultPushManager().interceptApplication(application, didReceiveRemoteNotification: userInfo)
    }
    
    /**
     * Configures all the enabled AWS services from application delegate with options.
     *
     * - parameter application: instance from application delegate.
     * - parameter launchOptions: from application delegate.
     */
    func didFinishLaunching(application: UIApplication, withOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        print("didFinishLaunching:")
        
        // Register the sign in provider instances with their unique identifier
        
        // set up cognito user pool
        setupUserPool()
        
        
        var didFinishLaunching: Bool = AWSIdentityManager.defaultIdentityManager().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        didFinishLaunching = didFinishLaunching && AWSPushManager.defaultPushManager().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        
        if (!isInitialized) {
            AWSIdentityManager.defaultIdentityManager().resumeSession(completionHandler: {
                (result: Any?, error: Error?) in
                // If you get an EXC_BAD_ACCESS here in iOS Simulator, then do Simulator -> "Reset Content and Settings..."
                // This will clear bad auth tokens stored by other apps with the same bundle ID.
                print("Result: \(result) \n Error:\(error)")
            })
        }
        
        return didFinishLaunching
    }
    
    func setupUserPool() {
        // register your user pool configuration
//        AWSCognitoUserPoolsSignInProvider.setupUserPoolWithId(AWSCognitoUserPoolId, cognitoIdentityUserPoolAppClientId: AWSCognitoUserPoolAppClientId, cognitoIdentityUserPoolAppClientSecret: AWSCognitoUserPoolClientSecret, region: AWSCognitoUserPoolRegion)
//        
//        AWSSignInProviderFactory.sharedInstance().registerAWSSignInProvider(AWSCognitoUserPoolsSignInProvider.sharedInstance(), forKey:AWSCognitoUserPoolsSignInProviderKey)
        
    }
    
}
