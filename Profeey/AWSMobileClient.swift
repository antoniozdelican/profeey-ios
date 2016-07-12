//
//  AWSMobileClient.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
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
        //AWSIdentityManager.defaultIdentityManager().interceptApplication(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
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
            mobileAnalytics = AWSMobileAnalytics.defaultMobileAnalytics()
        }
    }
    
    /**
     * Configures all the enabled AWS services from application delegate with options.
     *
     * - parameter application: instance from application delegate.
     * - parameter launchOptions: from application delegate.
     */
    func didFinishLaunching(application: UIApplication, withOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        print("didFinishLaunching:")
        
        //let didFinishLaunching: Bool = AWSIdentityManager.defaultIdentityManager().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        
//        if (!isInitialized) {
////            AWSIdentityManager.defaultIdentityManager().resumeSessionWithCompletionHandler({(result: AnyObject?, error: NSError?) -> Void in
////                print("Result: \(result) \n Error:\(error)")
////            })
//            
//            AWSIdentityManager.defaultIdentityManager.resumeSession({
//                (task: AWSTask) in
//                if let error = task.error {
//                    print("Error: \(error)")
//                } else {
//                    print("Result: \(task.result)")
//                }
//                
//                return nil
//            })
//            isInitialized = true
//        }
        
        //return didFinishLaunching
        return true
    }
}
