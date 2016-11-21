//
//  AWSClientManager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 19/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSCognitoIdentityProvider
import AWSDynamoDB

protocol IncompleteSignUpDelegate {
    func preferredUsernameNotSet()
}

class AWSClientManager: NSObject, ClientManager {
    
    fileprivate static var sharedInstance: AWSClientManager!
    static func defaultClientManager() -> AWSClientManager {
        if sharedInstance == nil {
            sharedInstance = AWSClientManager()
            sharedInstance.configure()
        }
        return sharedInstance
    }
    
    // Properties.
    var credentialsProvider: AWSCognitoCredentialsProvider?
    var userPool: AWSCognitoIdentityUserPool?
    var userFileManager: AWSUserFileManager?
    
    // TEST properties.
    var incompleteSignUpDelegate: IncompleteSignUpDelegate?
    
    fileprivate func configure() {
        print("Configuring client...")
        
        // Setup logging.
        AWSLogger.default().logLevel = AWSLogLevel.verbose
        
        // Service.
        let serviceConfiguration = AWSServiceConfiguration(
            region: AWSConstants.COGNITO_REGIONTYPE,
            credentialsProvider: nil)
        
        // User pool.
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(
            clientId: AWSConstants.COGNITO_USER_POOL_CLIENT_ID,
            clientSecret: AWSConstants.COGNITO_USER_POOL_CLIENT_SECRET,
            poolId: AWSConstants.COGNITO_USER_POOL_ID)
        AWSCognitoIdentityUserPool.register(
            with: serviceConfiguration,
            userPoolConfiguration: userPoolConfiguration,
            forKey: "UserPool")
        self.userPool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        
        // Credentials provider.
        self.credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSConstants.COGNITO_REGIONTYPE,
            identityPoolId: AWSConstants.COGNITO_IDENTITY_POOL_ID,
            identityProviderManager: self.userPool)

        // Default service.
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSConstants.COGNITO_REGIONTYPE,
            credentialsProvider: self.credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = defaultServiceConfiguration
        
        // Default userFileManager.
        let userFileManagerConfiguration = AWSUserFileManagerConfiguration(
            bucketName: AWSConstants.BUCKET_NAME,
            serviceConfiguration: defaultServiceConfiguration)
        AWSUserFileManager.register(
            with: userFileManagerConfiguration,
            forKey: "USEast1BucketManager")
        self.userFileManager = AWSUserFileManager.custom(key: "USEast1BucketManager")
    }
    
    // MARK: UserPool
    
    func logIn(_ username: String, password: String, completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserSession>) -> Any?) {
        print("logIn:")
        let user = AWSClientManager.defaultClientManager().userPool?.getUser()
        user?.getSession(username, password: password, validationData: nil).continue(completionHandler)
    }
    
    func signUp(_ username: String, password: String, email: String, firstName: String, lastName: String, completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserPoolSignUpResponse>) -> Any?) {
        print("signUp:")
        var attributes: [AWSCognitoIdentityUserAttributeType] = []
        let emailAttribute = AWSCognitoIdentityUserAttributeType()
        emailAttribute?.name = "email"
        emailAttribute?.value = email
        attributes.append(emailAttribute!)
        let firstNameAttribute = AWSCognitoIdentityUserAttributeType()
        firstNameAttribute?.name = "given_name"
        firstNameAttribute?.value = firstName
        attributes.append(firstNameAttribute!)
        let lastNameAttribute = AWSCognitoIdentityUserAttributeType()
        lastNameAttribute?.name = "family_name"
        lastNameAttribute?.value = lastName
        attributes.append(lastNameAttribute!)
        self.userPool?.signUp(username, password: password, userAttributes: attributes, validationData: nil).continue(completionHandler)
    }
    
    func signOut(_ completionHandler: @escaping AWSContinuationBlock) {
        print("signOut:")
        // UserPool signOut.
        self.userPool?.currentUser()?.signOut()
        // Credentials provider cleanUp.
        self.credentialsProvider?.clearKeychain()
        // User file manager cleanUp.
        self.userFileManager?.clearCache()
        // Current user cleanUp.
        PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB = nil
        
        AWSTask(result: nil).continue(completionHandler)
    }
    
    func getUserDetails(_ completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserGetDetailsResponse>) -> Any?) {
        print("getUserDetails:")
        self.userPool?.currentUser()?.getDetails().continue(completionHandler)
    }
    
    func updatePreferredUsername(_ preferredUsername: String, completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserUpdateAttributesResponse>) -> Any?) {
        print("updatePreferredUsername:")
        var attributes: [AWSCognitoIdentityUserAttributeType] = []
        let preferredUsernameAttribute = AWSCognitoIdentityUserAttributeType()
        preferredUsernameAttribute?.name = "preferred_username"
        preferredUsernameAttribute?.value = preferredUsername
        attributes.append(preferredUsernameAttribute!)
        self.userPool?.currentUser()?.update(attributes).continue(completionHandler)
    }
}
