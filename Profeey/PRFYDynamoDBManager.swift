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
            } else if (task.result as? AWSUser) != nil {
                print("getUserDynamoDB success!")
                return task.continueWithBlock(completionHandler)
            } else {
                print("This should not happen with getUserDynamoDB!")
                return AWSTask().continueWithBlock(completionHandler)
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
                
                print("getCurrentUserDynamoDB:")
                let usersTable = AWSUsersTable()
                usersTable.getUser(identityId, completionHandler: completionHandler)
                
//                let usersTable = AWSUsersTable()
//                usersTable.getUser(identityId, completionHandler: {
//                    (task: AWSTask) in
//                    if let error = task.error {
//                        print("getCurrentUserDynamoDB error:")
//                        return AWSTask(error: error).continueWithBlock(completionHandler)
//                    } else if (task.result as? AWSUser) != nil {
//                        print("getCurrentUserDynamoDB success!")
//                        return task.continueWithBlock(completionHandler)
//                    } else {
//                        print("This should not happen with getCurrentUserDynamoDB!")
//                        return AWSTask().continueWithBlock(completionHandler)
//                    }
//                })
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
    
    func updateProfessionDynamoDB(profession: String?, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("updateProfessionDynamoDB:")
                let usersTable = AWSUsersTable()
                let user = AWSUserProfession()
                user._userId = identityId
                user._profession = profession
                usersTable.saveUserProfession(user, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("updateProfessionDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("updateProfessionDynamoDB success!")
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
    
    func updateLocationDynamoDB(location: String?, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("updateLocationDynamoDB:")
                let usersTable = AWSUsersTable()
                let user = AWSUserLocation()
                user._userId = identityId
                user._location = location
                usersTable.saveUserLocation(user, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("updateLocationDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("updateLocationDynamoDB success!")
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
    
    func updateAboutDynamoDB(about: String?, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("updateAboutDynamoDB:")
                let usersTable = AWSUsersTable()
                let user = AWSUserAbout()
                user._userId = identityId
                user._about = about
                usersTable.saveUserAbout(user, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("updateAboutDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("updateAboutDynamoDB success!")
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
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("updateUserProfilePicDynamoDB:")
                let usersTable = AWSUsersTable()
                let user = AWSUserProfilePic()
                user._userId = identityId
                user._profilePicUrl = profilePicUrl
                usersTable.saveUserProfilePic(user, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("updateUserProfilePicDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("updateUserProfilePicDynamoDB success!")
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
    
    func scanUsersDynamoDB(completionHandler: AWSContinuationBlock) {
        print("scanUsersDynamoDB:")
        let usersTable = AWSUsersTable()
        usersTable.scanUsers({
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            if let error = error {
                print("scanUsersDynamoDB error:")
                AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                print("scanUsersDynamoDB success!")
                AWSTask(result: response).continueWithBlock(completionHandler)
            }
        })
    }
    
    // MARK: UserRelationships
    
    func getUserRelationshipDynamoDB(followingId: String, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("getUserRelationshipDynamoDB:")
                let userRelationshipsTable = AWSUserRelationshipsTable()
                userRelationshipsTable.getUserRelationship(identityId, followingId: followingId, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func saveUserRelationshipDynamoDB(followingId: String, followingFirstName: String?, followingLastName: String?, followingPreferredUsername: String?, followingProfession: String?, followingProfilePicUrl: String?, numberOfNewPosts: NSNumber?, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveUserRelationshipDynamoDB:")
                let userRelationshipsTable = AWSUserRelationshipsTable()
                let userRelationship = AWSUserRelationship()
                userRelationship._userId = identityId
                userRelationship._creationDate = NSNumber(double: NSDate().timeIntervalSince1970)
                userRelationship._followingId = followingId
                userRelationship._followingFirstName = followingFirstName
                userRelationship._followingLastName = followingLastName
                userRelationship._followingPreferredUsername = followingPreferredUsername
                userRelationship._followingProfession = followingProfession
                userRelationship._followingProfilePicUrl = followingProfilePicUrl
                userRelationship._numberOfNewPosts = numberOfNewPosts
                userRelationshipsTable.saveUserRelationship(userRelationship, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func removeUserRelationshipDynamoDB(followingId: String, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("removeUserRelationshipDynamoDB:")
                let userRelationshipsTable = AWSUserRelationshipsTable()
                let userRelationship = AWSUserRelationship()
                userRelationship._userId = identityId
                userRelationship._followingId = followingId
                userRelationshipsTable.removeUserRelationship(userRelationship, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func queryUserFollowingDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("queryUserFollowingDynamoDB:")
        let userRelationshipsPrimaryIndex = AWSUserRelationshipsPrimaryIndex()
        userRelationshipsPrimaryIndex.queryUserFollowing(userId, completionHandler: completionHandler)
    }
    
    // MARK: Likes
    
    func getLikeDynamoDB(postId: String, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("getLikeDynamoDB:")
                let likesTable = AWSLikesTable()
                likesTable.getLike(identityId, postId: postId, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("getLikeDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("getLikeDynamoDB success!")
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
    
    func saveLikeDynamoDB(postId: String, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveLikeDynamoDB:")
                let likesTable = AWSLikesTable()
                let like = AWSLike()
                like._userId = identityId
                like._postId = postId
                like._creationDate = NSNumber(double: NSDate().timeIntervalSince1970)
                likesTable.saveLike(like, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("saveLikeDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("saveLikeDynamoDB success!")
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
    
    func removeLikeDynamoDB(postId: String, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("removeLikeDynamoDB:")
                let likesTable = AWSLikesTable()
                let like = AWSLike()
                like._userId = identityId
                like._postId = postId
                likesTable.removeLike(like, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        print("removeLikeDynamoDB error:")
                        return AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        print("removeLikeDynamoDB success!")
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
    
    func queryPostLikersDynamoDB(postId: String, completionHandler: AWSContinuationBlock) {
        print("queryPostLikersDynamoDB:")
        let likesPostIndex = AWSLikesPostIndex()
        likesPostIndex.queryPostLikers(postId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            if let error = error {
                print("queryPostLikersDynamoDB error:")
                AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                print("queryPostLikersDynamoDB success!")
                AWSTask(result: response).continueWithBlock(completionHandler)
            }
        })
    }
    
    
    // MARK: Posts
    
    func queryUserPostsDateSortedDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("queryUserPostsDateSortedDynamoDB:")
        let postsDateSortedIndex = AWsPostsDateSortedIndex()
        postsDateSortedIndex.queryUserPostsDateSorted(userId, completionHandler: completionHandler)
    }
    
    func savePostDynamoDB(imageUrl: String?, title: String?, description: String?, category: String?, user: User?, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("savePostDynamoDB:")
                let postsTable = AWSPostsTable()
                let post = AWSPost()
                post._userId = identityId
                post._postId = NSUUID().UUIDString.lowercaseString
                post._imageUrl = imageUrl
                post._title = title
                post._description = description
                post._category = category
                post._creationDate = NSNumber(double: NSDate().timeIntervalSince1970)
                
                post._userFirstName = user?.firstName
                post._userLastName = user?.lastName
                post._userPreferredUsername = user?.preferredUsername
                post._userProfession = user?.profession
                post._userProfilePicUrl = user?.profilePicUrl
                
                postsTable.savePost(post, completionHandler: completionHandler)
                postsTable.savePost(post, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        // Return initialized post to caller.
                        AWSTask(result: post).continueWithBlock(completionHandler)
                    }
                    return nil
                })
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func scanFollowedPosts(followedIds: [String], completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("scanFollowedPosts:")
        let postsTable = AWSPostsTable()
        postsTable.scanFollowedPosts(followedIds, completionHandler: completionHandler)
    }
}