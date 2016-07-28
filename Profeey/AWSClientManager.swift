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
    var contentManager: AWSContentManager?
    var currentUser: User?
    
    var incompleteSignUpDelegate: IncompleteSignUpDelegate?
    
    // Singleton initialization.
    static func defaultClientManager() -> AWSClientManager {
        if sharedInstance == nil {
            sharedInstance = AWSClientManager()
            sharedInstance.configure()
        }
        return sharedInstance
    }
    
    private func configure() {
        print("Configure client...")
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
        
        // Default contentManager.
//        let contentManagerConfiguration = AWSContentManagerConfiguration(
//            bucketName: AWSConstants.BUCKET_NAME)
//        AWSContentManager.registerContentManagerWithConfiguration(
//            contentManagerConfiguration,
//            forKey: "USEast1BucketManager")
//        self.contentManager = AWSContentManager(forKey: "USEast1BucketManager")
    }
    
    // MARK: UserPool
    
    func logIn(username: String, password: String, completionHandler: AWSContinuationBlock) {
        let user = self.userPool?.getUser()
        print("GetSession:")
        user?.getSession(username, password: password, validationData: nil, scopes: nil).continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("GetSession error:")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                print("GetSession success!")
                return task.continueWithBlock(completionHandler)
            }
        })
    }
    
    func signUp(username: String, password: String, email: String, completionHandler: AWSContinuationBlock) {
        var attributes: [AWSCognitoIdentityUserAttributeType] = []
        let emailAttribute = AWSCognitoIdentityUserAttributeType()
        emailAttribute.name = "email"
        emailAttribute.value = email
        attributes.append(emailAttribute)
        
        print("SignUp:")
        self.userPool?.signUp(username, password: password, userAttributes: attributes, validationData: nil).continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("SignUp error:")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                print("SignUp success!")
                // Proceed to log in.
                self.logIn(username, password: password, completionHandler: completionHandler)
                return nil
            }
        })
    }
    
    func signOut(completionHandler: AWSContinuationBlock) {
        print("SignOut:")
        self.userPool?.currentUser()?.signOut()
        self.credentialsProvider?.clearKeychain()
        AWSTask(result: nil).continueWithBlock(completionHandler)
    }
    
    func getCurrentUser(completionHandler: AWSContinuationBlock) {
        print("Update currentUser:")
        self.userPool?.currentUser()?.getDetails().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("Update currentUser error: \(error)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let result = task.result as? AWSCognitoIdentityUserGetDetailsResponse {
                let userAttributes = result.userAttributes
                let user = User()
                // If preferredUsername is not yet set, notifiy delegate (AppDelegate).
                if let preferredUsernameIndex = userAttributes?.indexOf({ $0.name == "preferred_username" }) {
                    user.preferredUsername = userAttributes?[preferredUsernameIndex].value
                } else {
                    print("PreferredUsername not set:")
                    self.incompleteSignUpDelegate?.preferredUsernameNotSet()
                }
                if let firstNameIndex = userAttributes?.indexOf({ $0.name == "given_name" }) {
                    user.firstName = userAttributes?[firstNameIndex].value
                }
                if let lastNameIndex = userAttributes?.indexOf({ $0.name == "family_name" }) {
                    user.lastName = userAttributes?[lastNameIndex].value
                }
                self.currentUser = user
                print("Update currentUser success!")
                return task.continueWithBlock(completionHandler)
            } else {
                print("This should not happen with GetDetails.")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func updateFirstLastName(firstName: String?, lastName: String?, completionHandler: AWSContinuationBlock) {
        var attributes: [AWSCognitoIdentityUserAttributeType] = []
        let firstNameAttribute = AWSCognitoIdentityUserAttributeType()
        firstNameAttribute.name = "given_name"
        firstNameAttribute.value = firstName != nil ? firstName : ""
        attributes.append(firstNameAttribute)
        let lastNameAttribute = AWSCognitoIdentityUserAttributeType()
        lastNameAttribute.name = "family_name"
        lastNameAttribute.value = lastName != nil ? lastName : ""
        attributes.append(lastNameAttribute)
        
        print("updateFirstLastName:")
        self.userPool?.currentUser()?.updateAttributes(attributes).continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("updateFirstLastName error:")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                print("updateFirstLastName success!")
                self.updateFirstLastNameDynamoDB(firstName, lastName: lastName, completionHandler: completionHandler)
                return nil
            }
        })
    }
    
    func updatePreferredUsername(preferredUsername: String, completionHandler: AWSContinuationBlock) {
        var attributes: [AWSCognitoIdentityUserAttributeType] = []
        let preferredUsernameAttribute = AWSCognitoIdentityUserAttributeType()
        preferredUsernameAttribute.name = "preferred_username"
        preferredUsernameAttribute.value = preferredUsername
        attributes.append(preferredUsernameAttribute)
        
        print("updatePreferredUsername:")
        self.userPool?.currentUser()?.updateAttributes(attributes).continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("updatePreferredUsername error:")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                print("updatePreferredUsername success!")
                self.updatePreferredUsernameDynamoDB(preferredUsername, completionHandler: completionHandler)
                return nil
            }
        })
    }
    
    // MARK: DynamoDB
    
    func getCurrentUserDynamoDB(completionHandler: AWSContinuationBlock) {
        print("getCurrentUserDynamoDB:")
        self.credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("GetIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                let usersTable = AWSUsersTable()
                print("getCurrentUserDynamoDB:")
                usersTable.getUser(identityId, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("getCurrentUserDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else if (task.result as? AWSUser) != nil {
                        print("getCurrentUserDynamoDB success!")
                        return task.continueWithBlock(completionHandler)
                    } else {
                        print("This should not happen with getCurrentUserDynamoDB!")
                        return AWSTask().continueWithBlock(completionHandler)
                    }
                })
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func updateFirstLastNameDynamoDB(firstName: String?, lastName: String?, completionHandler: AWSContinuationBlock) {
        self.credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("GetIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                let usersTable = AWSUsersTable()
                let user = AWSUserFirstLastName()
                user._userId = identityId
                user._firstName = firstName
                user._lastName = lastName
                print("updateFirstLastNameDynamoDB:")
                usersTable.saveUserFirstLastName(user, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("updateFirstLastNameDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("updateFirstLastNameDynamoDB success!")
                        return task.continueWithBlock(completionHandler)
                    }
                })
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func updatePreferredUsernameDynamoDB(preferredUsername: String?, completionHandler: AWSContinuationBlock) {
        self.credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("GetIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                let usersTable = AWSUsersTable()
                let user = AWSUserPreferredUsername()
                user._userId = identityId
                user._preferredUsername = preferredUsername
                print("updatePreferredUsernameDynamoDB:")
                usersTable.saveUserPreferredUsername(user, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("updatePreferredUsernameDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("updatePreferredUsernameDynamoDB success!")
                        return task.continueWithBlock(completionHandler)
                    }
                })
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func updateUserProfessionsDynamoDB(professions: [String]?, completionHandler: AWSContinuationBlock) {
        self.credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("GetIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                let usersTable = AWSUsersTable()
                let user = AWSUserProfessions()
                user._userId = identityId
                user._professions = professions
                print("updateProfessionsDynamoDB:")
                usersTable.saveUserProfessions(user, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("updateProfessionsDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("updateProfessionsDynamoDB success!")
                        return task.continueWithBlock(completionHandler)
                    }
                })
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func updateProfessionsDynamoDB(professions: [String]) {
        let professionsTable = AWSProfessionsTable()
        print("updateProfessionsDynamoDB:")
        professionsTable.saveProfessions(professions) {
            (errors: [NSError]?) in
            if let errors = errors {
                print("updateProfessionsDynamoDB errors: \(errors)")
            }
        }

    }
}