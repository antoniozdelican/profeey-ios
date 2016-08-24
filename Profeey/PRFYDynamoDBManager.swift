//
//  PRFYDynamoDBManager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 03/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSDynamoDB

class PRFYDynamoDBManager: NSObject, DynamoDBManager {
    
    private static var sharedInstance: PRFYDynamoDBManager!
    
    static func defaultDynamoDBManager() -> PRFYDynamoDBManager {
        if sharedInstance == nil {
            sharedInstance = PRFYDynamoDBManager()
        }
        return sharedInstance
    }
    
    // MARK: Users
    
    func getUserDynamoDB(userId: String, completionHandler: AWSContinuationBlock) {
        print("getUserDynamoDB:")
        let usersTable = AWSUsersTable()
        usersTable.getUser(userId, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                print("getUserDynamoDB error:")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                print("getUserDynamoDB success!")
                return task.continueWithBlock(completionHandler)
            }
        })
    }
    
    func getCurrentUserDynamoDB(completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
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
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("updateFirstLastNameDynamoDB:")
                let usersTable = AWSUsersTable()
                let user = AWSUserFirstLastName()
                user._userId = identityId
                user._firstName = firstName
                user._lastName = lastName
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
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("updatePreferredUsernameDynamoDB:")
                let usersTable = AWSUsersTable()
                let user = AWSUserPreferredUsername()
                user._userId = identityId
                user._preferredUsername = preferredUsername
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
    
    func updateUserProfessionDynamoDB(profession: String?, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("updateUserProfessionDynamoDB:")
                let usersTable = AWSUsersTable()
                let user = AWSUserProfession()
                user._userId = identityId
                user._profession = profession
                usersTable.saveUserProfession(user, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("updateUserProfessionDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("updateUserProfessionDynamoDB success!")
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
    
    func updateUserLocationDynamoDB(location: String?, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("updateUserLocationDynamoDB:")
                let usersTable = AWSUsersTable()
                let user = AWSUserLocation()
                user._userId = identityId
                user._location = location
                usersTable.saveUserLocation(user, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("updateUserLocationDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("updateUserLocationDynamoDB success!")
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
    
    func updateUserAboutDynamoDB(about: String?, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("updateUserAboutDynamoDB:")
                let usersTable = AWSUsersTable()
                let user = AWSUserAbout()
                user._userId = identityId
                user._about = about
                usersTable.saveUserAbout(user, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("updateUserAboutDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("updateUserAboutDynamoDB success!")
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
    
    func updateProfilePicDynamoDB(profilePicUrl: String?, completionHandler: AWSContinuationBlock) {
//        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
//            (task: AWSTask) in
//            if let error = task.error {
//                print("getIdentityId error: \(error.localizedDescription)")
//                return AWSTask(error: error).continueWithBlock(completionHandler)
//            } else if let identityId = task.result as? String {
//                let usersTable = AWSUsersTable()
//                let user = AWSUserProfilePic()
//                user._userId = identityId
//                user._profilePicUrl = profilePicUrl
//                print("updateProfilePicDynamoDB:")
//                usersTable.saveUserProfilePic(user, completionHandler: {
//                    (task: AWSTask) in
//                    if let error = task.error {
//                        print("updateProfilePicDynamoDB error:")
//                        return AWSTask(error: error).continueWithBlock(completionHandler)
//                    } else {
//                        print("updateProfilePicDynamoDB success!")
//                        return task.continueWithBlock(completionHandler)
//                    }
//                })
//                return nil
//            } else {
//                print("This should not happen with getIdentityId!")
//                return AWSTask().continueWithBlock(completionHandler)
//            }
//        })
    }
    
    // MARK: Posts
    
    func getUserPostsDynamoDB(userId: String, completionHandler: AWSContinuationBlock) {
        print("getUserPostsDynamoDb:")
        let postsPrimaryIndex = AWSPostsPrimaryIndex()
        postsPrimaryIndex.queryUserPosts(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            if let error = error {
                print("getUserPostsDynamoDb error:")
                AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                print("getUserPostsDynamoDb success!")
                print(response?.items)
                AWSTask(result: response).continueWithBlock(completionHandler)
            }
        })
    }
    
    func getCurrentUserPostsDynamoDB(completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("getCurrentUserPostsDynamoDB:")
                let postsPrimaryIndex = AWSPostsPrimaryIndex()
                postsPrimaryIndex.queryUserPosts(identityId, completionHandler: {
                    (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
                    if let error = error {
                        print("getCurrentUserPostsDynamoDB error:")
                        AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("getCurrentUserPostsDynamoDB success!")
                        AWSTask(result: response).continueWithBlock(completionHandler)
                    }
                })
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func createPostDynamoDB(imageUrl: String?, title: String?, description: String?, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("createPostDynamoDb:")
                let postsTable = AWSPostsTable()
                let post = AWSPost()
                post._userId = identityId
                post._postId = NSUUID().UUIDString.lowercaseString
                post._imageUrl = imageUrl
                post._title = title
                post._description = description
                postsTable.savePost(post, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("createPostDynamoDb error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("createPostDynamoDb success!")
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
}