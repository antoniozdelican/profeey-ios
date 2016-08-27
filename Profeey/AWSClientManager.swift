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
    
    // MARK: Likes
    
    func getLike(postId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB getLike.
        PRFYDynamoDBManager.defaultDynamoDBManager().getLikeDynamoDB(postId, completionHandler: completionHandler)
    }
    
    func saveLike(postId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB saveLike.
        PRFYDynamoDBManager.defaultDynamoDBManager().saveLikeDynamoDB(postId, completionHandler: completionHandler)
    }
    
    func removeLike(postId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB removeLike.
        PRFYDynamoDBManager.defaultDynamoDBManager().removeLikeDynamoDB(postId, completionHandler: completionHandler)
    }
    
    func queryPostLikers(postId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB queryPostLikers.
        PRFYDynamoDBManager.defaultDynamoDBManager().queryPostLikersDynamoDB(postId, completionHandler: completionHandler)
    }
    
    
    // MARK: UserRelationsips
    
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
    
    func queryUserFollowed(userId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB queryUserFollowed.
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserFollowedDynamoDB(userId, completionHandler: completionHandler)
    }
    
    // MARK: Posts
    
    func queryUserPosts(userId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB queryUserPosts.
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserPostsDynamoDB(userId, completionHandler: completionHandler)
    }
    
    func queryUserPostsDateSorted(userId: String, completionHandler: AWSContinuationBlock) {
        // DynamoDB queryUserPostsDateSorted.
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserPostsDateSortedDynamoDB(userId, completionHandler: completionHandler)
    }
    
    func savePost(imageData: NSData, title: String?, description: String?, category: String?, user: User?, isProfilePic: Bool, completionHandler: AWSContinuationBlock) {
        // S3 uploadImage.
        PRFYS3Manager.defaultDynamoDBManager().uploadImageS3(
            imageData,
            isProfilePic: isProfilePic,
            progressBlock: {
                (localContent: AWSLocalContent, progress: NSProgress) in
                // TODO
                return
            },
            completionHandler: {
                (task: AWSTask) in
                if let error = task.error {
                    return AWSTask(error: error).continueWithBlock(completionHandler)
                } else if let imageUrl = task.result as? String {
                    // DynamoDB savePostDynamoDb SYNC.
                    PRFYDynamoDBManager.defaultDynamoDBManager().savePostDynamoDB(imageUrl, title: title, description: description, category: category, user: user, completionHandler: completionHandler)
                    return nil
                } else {
                    print("This should not happen with savePost.")
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
                return
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