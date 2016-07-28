//
//  Constants.swift
//  Profeey
//
//  Created by Antonio Zdelican on 19/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSCore

@objc class Constants : NSObject {
    
    // MARK: Required: Amazon Cognito Configuration
    
    static let COGNITO_REGIONTYPE = AWSRegionType.USEast1 // e.g. AWSRegionType.USEast1
    static let COGNITO_IDENTITY_POOL_ID = "us-east-1:cf413650-369e-477d-bde4-cbc3758e77d9"
    
    // MARK: Optional: Enable Developer Authentication
    
    //KeyChain Constants
    static let BYOI_PROVIDER = "BYOI"
    
    /**
     * OPTIONAL: Enable Developer Authentication Login
     *
     * This sample uses the Java-based Cognito Authentication backend
     * To enable Dev Auth Login
     * 1. Set the values for the constants below to match the running instance
     *    of the example developer authentication backend
     */
    // This is the default value, if you modified your backend configuration
    // update this value as appropriate
    //static let DEVELOPER_AUTH_APP_NAME = "awscognitodeveloperauthenticationsample"
    // Update this value to reflect where your backend is deployed
    // !!!!!!!!!!!!!!!!!!!
    // Make sure to enable HTTPS for your end point before deploying your
    // app to production.
    // !!!!!!!!!!!!!!!!!!!
    //static let DEVELOPER_AUTH_ENDPOINT = "http://YourEndpoint/"
    // Set to the provider name you configured in the Cognito console.
    //static let DEVELOPER_AUTH_PROVIDER_NAME = "YourAuthProviderName"
    static let DEVELOPER_AUTH_PROVIDER_NAME = "UserPoolProviderName" // not really used in logins
    
    /*******************************************
     * DO NOT CHANGE THE VALUES BELOW HERE
     */
    
    static let DEVICE_TOKEN_KEY = "DeviceToken"
    static let COGNITO_DEVICE_TOKEN_KEY = "CognitoDeviceToken"
    static let COGNITO_PUSH_NOTIF = "CognitoPushNotification"
}