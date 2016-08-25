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
    }
    
    func getUserDetails(completionHandler: AWSContinuationBlock) {
        // UserPool getUserDetails.
        PRFYUserPoolManager.defaultUserPoolManager().getUserDetailsUserPool(completionHandler)
    }
    
    func getUser(userId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB getUser.
        PRFYDynamoDBManager.defaultDynamoDBManager().getUserDynamoDB(userId, completionHandler: completionHandler)
    }
    
    func getCurrentUser(completionHandler: AWSContinuationBlock) {
        // DynamoDB getCurrentUser.
        PRFYDynamoDBManager.defaultDynamoDBManager().getCurrentUserDynamoDB(completionHandler)
    }
    
//    func getCurrentUser(completionHandler: AWSContinuationBlock) {
//        print("getCurrentUser:")
//        self.userPool?.currentUser()?.getDetails().continueWithBlock({
//            (task: AWSTask) in
//            if let error = task.error {
//                print("getCurrentUser error: \(error)")
//                return AWSTask(error: error).continueWithBlock(completionHandler)
//            } else if let result = task.result as? AWSCognitoIdentityUserGetDetailsResponse {
//                let userAttributes = result.userAttributes
//                let user = User()
//                // If preferredUsername is not yet set, notifiy delegate (AppDelegate).
//                if let preferredUsernameIndex = userAttributes?.indexOf({ $0.name == "preferred_username" }) {
//                    user.preferredUsername = userAttributes?[preferredUsernameIndex].value
//                } else {
//                    print("PreferredUsername not set:")
//                    //self.incompleteSignUpDelegate?.preferredUsernameNotSet()
//                }
//                if let firstNameIndex = userAttributes?.indexOf({ $0.name == "given_name" }) {
//                    user.firstName = userAttributes?[firstNameIndex].value
//                }
//                if let lastNameIndex = userAttributes?.indexOf({ $0.name == "family_name" }) {
//                    user.lastName = userAttributes?[lastNameIndex].value
//                }
//                if let profilePicUrlIndex = userAttributes?.indexOf({ $0.name == "picture" }) {
//                    user.profilePicUrl = userAttributes?[profilePicUrlIndex].value
//                }
//                self.currentUser = user
//                print("getCurrentUser success!")
//                return task.continueWithBlock(completionHandler)
//            } else {
//                print("This should not happen with getCurrentUser.")
//                return AWSTask().continueWithBlock(completionHandler)
//            }
//        })
//    }
    
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
    
    func updateUserProfession(profession: String?, completionHandler: AWSContinuationBlock) {
        // DynamoDB updateUserProfession.
        PRFYDynamoDBManager.defaultDynamoDBManager().updateUserProfessionDynamoDB(profession, completionHandler: completionHandler)
        // TODO should update Profession table!
    }
    
    func updateUserLocation(location: String?, completionHandler: AWSContinuationBlock) {
        // DynamoDB updateUserLocation.
        PRFYDynamoDBManager.defaultDynamoDBManager().updateUserLocationDynamoDB(location, completionHandler: completionHandler)
    }
    
    func updateUserAbout(about: String?, completionHandler: AWSContinuationBlock) {
        // DynamoDB updateUserAbout.
        PRFYDynamoDBManager.defaultDynamoDBManager().updateUserAboutDynamoDB(about, completionHandler: completionHandler)
    }
    
    func updateProfilePic(profilePicUrl: String?, completionHandler: AWSContinuationBlock) {
//        var attributes: [AWSCognitoIdentityUserAttributeType] = []
//        let profilePicAttribute = AWSCognitoIdentityUserAttributeType()
//        profilePicAttribute.name = "picture"
//        profilePicAttribute.value = profilePicUrl != nil ? profilePicUrl : ""
//        attributes.append(profilePicAttribute)
//        
//        print("updateProfilePic:")
//        self.userPool?.currentUser()?.updateAttributes(attributes).continueWithBlock({
//            (task: AWSTask) in
//            if let error = task.error {
//                print("updateProfilePic error:")
//                return AWSTask(error: error).continueWithBlock(completionHandler)
//            } else {
//                print("updateProfilePic success!")
//                // Update DynamoDB.
//                PRFYDynamoDBManager.defaultDynamoDBManager().updateProfilePicDynamoDB(profilePicUrl, completionHandler: completionHandler)
//                return nil
//            }
//        })
    }
    
    func scanUsers(completionHandler: AWSContinuationBlock) {
        // DynamoDB scanUsers.
        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersDynamoDB(completionHandler)
    }
    
    func getUserRelationship(followedId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB getUserRelationship.
        PRFYDynamoDBManager.defaultDynamoDBManager().getUserRelationshipDynamoDB(followedId, completionHandler: completionHandler)
    }
    
    func saveUserRelationship(followedId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB saveUserRelationship.
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserRelationshipDynamoDB(followedId, completionHandler: completionHandler)
    }
    
    func removeUserRelationship(followedId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB removeUserRelationship.
        PRFYDynamoDBManager.defaultDynamoDBManager().removeUserRelationshipDynamoDB(followedId, completionHandler: completionHandler)
    }
    
    // MARK: Posts
    
    func getUserPosts(userId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB getUserPosts.
        PRFYDynamoDBManager.defaultDynamoDBManager().getUserPostsDynamoDB(userId, completionHandler: completionHandler)
    }
    
    func getCurrentUserPosts(completionHandler: AWSContinuationBlock) {
        // DynamoDb getCurrentUserPosts.
        PRFYDynamoDBManager.defaultDynamoDBManager().getCurrentUserPostsDynamoDB(completionHandler)
    }
    
    func createPost(imageData: NSData, title: String?, description: String?, category: String?, isProfilePic: Bool, completionHandler: AWSContinuationBlock) {
        // S3 uploadImage.
        PRFYS3Manager.defaultDynamoDBManager().uploadImageS3(
            imageData,
            isProfilePic: isProfilePic,
            progressBlock: {
                (localContent: AWSLocalContent, progress: NSProgress) in
                // TODO
            },
            completionHandler: {
                (task: AWSTask) in
                if let error = task.error {
                    return AWSTask(error: error).continueWithBlock(completionHandler)
                } else if let imageUrl = task.result as? String {
                    // DynamoDB createPostDynamoDb SYNC.
                    PRFYDynamoDBManager.defaultDynamoDBManager().createPostDynamoDB(imageUrl, title: title, description: description, category: category, completionHandler: completionHandler)
                    return nil
                } else {
                    print("This should not happen with createPost.")
                    return AWSTask().continueWithBlock(completionHandler)
                }
        })
    }
    
    func downloadImage(imageKey: String, completionHandler: AWSContinuationBlock) {
        // S3 downloadImage.
        PRFYS3Manager.defaultDynamoDBManager().downloadImageS3(
            imageKey,
            progressBlock: {
                (content: AWSContent, progress: NSProgress) in
                // TODO
            },
            completionHandler: {
                (task: AWSTask) in
                if let error = task.error {
                    return AWSTask(error: error).continueWithBlock(completionHandler)
                } else if let data = task.result as? NSData {
                    return AWSTask(result: data).continueWithBlock(completionHandler)
                } else {
                    print("This should not happen with downloadImage.")
                    return AWSTask().continueWithBlock(completionHandler)
                }
        })
    }
    
    // In background.
    func deleteImageS3(imageKey: String, completionHandler: AWSContinuationBlock) {
        guard let userFileManager = self.userFileManager else {
            return
        }
        let content: AWSContent = userFileManager.contentWithKey(imageKey)
        content.removeRemoteContentWithCompletionHandler {
            (content: AWSContent?, error: NSError?) in
            if let error = error {
                print("deleteImageS3 error: \(error)")
                AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                print("deleteImageS3 success!")
                AWSTask().continueWithBlock(completionHandler)
            }
        }
    }
}