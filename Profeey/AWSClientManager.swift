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
    
    private static var sharedInstance: AWSClientManager!
    
    // Properties.
    var credentialsProvider: AWSCognitoCredentialsProvider?
    var userPool: AWSCognitoIdentityUserPool?
    var userFileManager: AWSUserFileManager?
    
    // TEST properties.
    var incompleteSignUpDelegate: IncompleteSignUpDelegate?

    static func defaultClientManager() -> AWSClientManager {
        if sharedInstance == nil {
            sharedInstance = AWSClientManager()
            sharedInstance.configure()
        }
        return sharedInstance
    }
    
    private func configure() {
        print("Configuring client...")
        
        // Setup logging.
        AWSLogger.defaultLogger().logLevel = AWSLogLevel.Verbose
        
        // Service.
        let serviceConfiguration = AWSServiceConfiguration(
            region: AWSConstants.COGNITO_REGIONTYPE,
            credentialsProvider: nil)
        
        // User pool.
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(
            clientId: AWSConstants.COGNITO_USER_POOL_CLIENT_ID,
            clientSecret: AWSConstants.COGNITO_USER_POOL_CLIENT_SECRET,
            poolId: AWSConstants.COGNITO_USER_POOL_ID)
        AWSCognitoIdentityUserPool.registerCognitoIdentityUserPoolWithConfiguration(
            serviceConfiguration,
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
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
        
        // Default userFileManager.
        let userFileManagerConfiguration = AWSUserFileManagerConfiguration(
            bucketName: AWSConstants.BUCKET_NAME,
            serviceConfiguration: defaultServiceConfiguration)
        AWSUserFileManager.registerUserFileManagerWithConfiguration(
            userFileManagerConfiguration,
            forKey: "USEast1BucketManager")
        self.userFileManager = AWSUserFileManager.custom(key: "USEast1BucketManager")
        
    }
    
    func logIn(username: String, password: String, completionHandler: AWSContinuationBlock) {
        // UserPool logIn.
        PRFYUserPoolManager.defaultUserPoolManager().logInUserPool(username, password: password, completionHandler: completionHandler)
    }
    
    func signUp(username: String, password: String, email: String, firstName: String?, lastName: String?, completionHandler: AWSContinuationBlock) {
        // UserPool signUp.
        PRFYUserPoolManager.defaultUserPoolManager().signUpUserPool(username, password: password, email: email, firstName: firstName, lastName: lastName, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                // DynamoDB updateFirstLastName ASYNC.
                PRFYDynamoDBManager.defaultDynamoDBManager().updateFirstLastNameDynamoDB(firstName, lastName: lastName, completionHandler: {
                    (task: AWSTask) in
                    return nil
                })
                return task.continueWithBlock(completionHandler)
            }
        })
    }
    
    func signOut(completionHandler: AWSContinuationBlock) {
        // UserPool signOut.
        PRFYUserPoolManager.defaultUserPoolManager().signOutUserPool(completionHandler)
        // Credentials provider cleanUp.
        self.credentialsProvider?.clearKeychain()
        // User file manager cleanUp.
        self.userFileManager?.clearCache()
    }
    
    func getUserDetails(completionHandler: AWSContinuationBlock) {
        // UserPool getUserDetails.
        PRFYUserPoolManager.defaultUserPoolManager().getUserDetailsUserPool(completionHandler)
    }
    
    func getUser(userId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB getUser.
        PRFYDynamoDBManager.defaultDynamoDBManager().getUserDynamoDB(userId, completionHandler: completionHandler)
    }
    
    func updateFirstLastName(firstName: String?, lastName: String?, completionHandler: AWSContinuationBlock) {
        // UserPool updateFirstLastName.
        PRFYUserPoolManager.defaultUserPoolManager().updateFirstLastNameUserPool(firstName, lastName: lastName, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                // DynamoDB updateFirstLastName SYNC.
                PRFYDynamoDBManager.defaultDynamoDBManager().updateFirstLastNameDynamoDB(firstName, lastName: lastName, completionHandler: completionHandler)
                return nil
            }
        })
    }
    
    func updatePreferredUsername(preferredUsername: String, completionHandler: AWSContinuationBlock) {
        // UserPool updatePreferredUsername.
        PRFYUserPoolManager.defaultUserPoolManager().updatePreferredUsernameUserPool(preferredUsername, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                // DynamoDB updatePreferredUsername SYNC.
                PRFYDynamoDBManager.defaultDynamoDBManager().updatePreferredUsernameDynamoDB(preferredUsername, completionHandler: completionHandler)
                return nil
            }
        })
    }
    
    func updateProfession(profession: String?, completionHandler: AWSContinuationBlock) {
        // DynamoDB updateProfession.
        PRFYDynamoDBManager.defaultDynamoDBManager().updateProfessionDynamoDB(profession, completionHandler: completionHandler)
        // TODO should update Profession table!
    }
    
    func updateLocation(location: String?, completionHandler: AWSContinuationBlock) {
        // DynamoDB updateLocation.
        PRFYDynamoDBManager.defaultDynamoDBManager().updateLocationDynamoDB(location, completionHandler: completionHandler)
    }
    
    func updateAbout(about: String?, completionHandler: AWSContinuationBlock) {
        // DynamoDB updateAbout.
        PRFYDynamoDBManager.defaultDynamoDBManager().updateAboutDynamoDB(about, completionHandler: completionHandler)
    }
    
    func scanUsers(completionHandler: AWSContinuationBlock) {
        // DynamoDB scanUsers.
        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersDynamoDB(completionHandler)
    }
}