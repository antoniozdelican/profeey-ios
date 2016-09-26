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
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func getUserDynamoDB(userId: String, completionHandler: AWSContinuationBlock) {
        print("getUserDynamoDB:")
        let usersTable = AWSUsersTable()
        usersTable.getUser(userId, completionHandler: completionHandler)
    }
    
    // Creates a user on landing.
    func createUserDynamoDB(email: String, firstName: String, lastName: String, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveUserDynamoDB:")
                let awsUsersTable = AWSUsersTable()
                let awsUser = AWSUser()
                awsUser._userId = identityId
                awsUser._creationDate = NSNumber(double: NSDate().timeIntervalSince1970)
                awsUser._email = email
                awsUser._firstName = firstName
                awsUser._lastName = lastName
                awsUser._searchFirstName = firstName.lowercaseString
                awsUser._searchLastName = lastName.lowercaseString
                awsUsersTable.saveUserSkipNull(awsUser, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func saveUserPreferredUsernameAndProfilePicDynamoDB(preferredUsername: String, profilePicUrl: String?, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveUserPreferredUsernameAndProfilePicDynamoDB:")
                let awsUsersTable = AWSUsersTable()
                let awsUser = AWSUser()
                awsUser._userId = identityId
                awsUser._preferredUsername = preferredUsername
                awsUser._searchPreferredUsername = preferredUsername.lowercaseString
                awsUser._profilePicUrl = profilePicUrl
                awsUsersTable.saveUserSkipNull(awsUser, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func saveUserProfessionDynamoDB(professionName: String, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveUserProfessionDynamoDB:")
                let awsUsersTable = AWSUsersTable()
                let awsUser = AWSUser()
                awsUser._userId = identityId
                awsUser._professionName = professionName
                awsUsersTable.saveUserSkipNull(awsUser, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func saveUserDynamoDB(user: User?, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveUserDynamoDB:")
                let usersTable = AWSUsersTable()
                let awsUserUpdate = AWSUserUpdate()
                awsUserUpdate._userId = identityId
                awsUserUpdate._firstName = user?.firstName
                awsUserUpdate._lastName = user?.lastName
                awsUserUpdate._professionName = user?.professionName
                awsUserUpdate._profilePicUrl = user?.profilePicUrl
                awsUserUpdate._about = user?.about
                awsUserUpdate._locationName = user?.locationName
                awsUserUpdate._searchFirstName = user?.firstName?.lowercaseString
                awsUserUpdate._searchLastName = user?.lastName?.lowercaseString
                usersTable.saveUser(awsUserUpdate, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func scanUsersDynamoDB(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let usersTable = AWSUsersTable()
        usersTable.scanUsers(completionHandler)
    }
    
    func scanUsersByFirstLastNameDynamoDB(searchFirstName: String, searchLastName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("scanUsersByFirstLastNameDynamoDB:")
        let usersTable = AWSUsersTable()
        usersTable.scanUsersByFirstLastName(searchFirstName, searchLastName: searchLastName, completionHandler: completionHandler)
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
    
    func saveUserRelationshipDynamoDB(followingId: String, follower: User?, completionHandler: AWSContinuationBlock) {
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
                
                userRelationship._firstName = follower?.firstName
                userRelationship._lastName = follower?.lastName
                userRelationship._preferredUsername = follower?.preferredUsername
                userRelationship._professionName = follower?.professionName
                userRelationship._profilePicUrl = follower?.profilePicUrl
                
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
    
    func queryUserFollowersDynamoDB(followingId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("queryUserFollowersDynamoDB:")
        let userRelationshipsFollowersIndex = AWSUserRelationshipsFollowersIndex()
        userRelationshipsFollowersIndex.queryUserFollowers(followingId, completionHandler: completionHandler)
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
                likesTable.getLike(identityId, postId: postId, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func saveLikeDynamoDB(postId: String, postUserId: String, liker: User?, completionHandler: AWSContinuationBlock) {
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
                like._postUserId = postUserId
                like._creationDate = NSNumber(double: NSDate().timeIntervalSince1970)
                
                like._firstName = liker?.firstName
                like._lastName = liker?.lastName
                like._preferredUsername = liker?.preferredUsername
                like._professionName = liker?.professionName
                like._profilePicUrl = liker?.profilePicUrl
                likesTable.saveLike(like, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func removeLikeDynamoDB(postId: String, postUserId: String, completionHandler: AWSContinuationBlock) {
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
                like._postUserId = postUserId
                likesTable.removeLike(like, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
    
    func queryPostLikersDynamoDB(postId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("queryPostLikersDynamoDB:")
        let likesPostIndex = AWSLikesPostIndex()
        likesPostIndex.queryPostLikers(postId, completionHandler: completionHandler)
    }
    
    
    // MARK: Posts
    
    func queryUserPostsDateSortedDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("queryUserPostsDateSortedDynamoDB:")
        let postsDateSortedIndex = AWSPostsDateSortedIndex()
        postsDateSortedIndex.queryUserPostsDateSorted(userId, completionHandler: completionHandler)
    }
    
    func queryCategoryPostsDateSortedDynamoDB(categoryName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("queryCategoryPostsDateSortedDynamoDB:")
        let postsCategoryNameIndex = AWSPostsCategoryNameIndex()
        postsCategoryNameIndex.queryCategoryPostsDateSorted(categoryName, completionHandler: completionHandler)
    }
    
    func savePostDynamoDB(imageUrl: String?, title: String?, description: String?, categoryName: String?, user: User?, completionHandler: AWSContinuationBlock) {
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
                post._categoryName = categoryName
                post._creationDate = NSNumber(double: NSDate().timeIntervalSince1970)
                post._description = description
                post._imageUrl = imageUrl
                post._numberOfLikes = 0
                post._title = title
                
                post._firstName = user?.firstName
                post._lastName = user?.lastName
                post._preferredUsername = user?.preferredUsername
                post._professionName = user?.professionName
                post._profilePicUrl = user?.profilePicUrl
                
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
    
    // MARK: FeaturedCategories
    
    func scanFeaturedCategoriesDynamoDB(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("scanFeaturedCategoriesDynamoDB:")
        let featuredCategoriesTable = AWSFeaturedCategoriesTable()
        featuredCategoriesTable.scanFeaturedCategories(completionHandler)
    }
    
    // MARK: Categories
    
    func scanCategoriesDynamoDB(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("scanCategoriesDynamoDB:")
        let categoriesTable = AWSCategoriesTable()
        categoriesTable.scanCategories(completionHandler)
    }
    
    func scanCategoriesByCategoryNameDynamoDB(searchCategoryName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("scanCategoriesByCategoryNameDynamoDB:")
        let categoriesTable = AWSCategoriesTable()
        categoriesTable.scanCategoriesByCategoryName(searchCategoryName, completionHandler: completionHandler)
    }
    
    // MARK: Professions
    
    func scanProfessionsDynamoDB(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("scanProfessions:")
        let professionsTable = AWSProfessionsTable()
        professionsTable.scanProfessions(completionHandler)
    }
    
    func scanProfessionsByProfessionNameDynamoDB(searchProfessionName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("scanProfessionsByProfessionNameDynamoDB:")
        let professionsTable = AWSProfessionsTable()
        professionsTable.scanProfessionsByProfessionName(searchProfessionName, completionHandler: completionHandler)
    }
    
    // MARK: Activities
    
    func queryUserActivitiesDateSortedDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("queryUserActivitiesDateSortedDynamoDB:")
        let activitiesDateSortedIndex = AWSActivitiesDateSortedIndex()
        activitiesDateSortedIndex.queryUserActivitiesDateSorted(userId, completionHandler: completionHandler)
    }
    
    // MARK: UserCategories
    
    func queryUserCategoriesNumberOfPostsSortedDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("queryUserCategoriesNumberOfPostsSortedDynamoDB:")
        let userCategoriesNumberOfPostsIndex = AWSUserCategoriesNumberOfPostsIndex()
        userCategoriesNumberOfPostsIndex.queryUserCategoriesNumberOfPostsSorted(userId, completionHandler: completionHandler)
    }
    
    // MARK: UserExperiences
    
    func queryUserExperiencesDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        print("queryUserExperiencesDynamoDB:")
        let userExperiencesPrimaryIndex = AWSUserExperiencesPrimaryIndex()
        userExperiencesPrimaryIndex.queryUserExperiences(userId, completionHandler: completionHandler)
    }
    
    func saveUserExperienceDynamoDB(experienceId: String?, position: String?, organization: String?, fromDate: NSNumber?, toDate: NSNumber?, experienceType: NSNumber?, completionHandler: AWSContinuationBlock) {
        // Save new and update existing hence experienceId is optional.
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveUserExperienceDynamoDB:")
                let userExperiencesTable = AWSUserExperiencesTable()
                let userExperience = AWSUserExperience()
                userExperience._userId = identityId
                userExperience._experienceId = experienceId != nil ? experienceId : NSUUID().UUIDString.lowercaseString
                userExperience._position = position
                userExperience._organization = organization
                userExperience._fromDate = fromDate
                userExperience._toDate = toDate
                userExperience._experienceType = experienceType
                userExperiencesTable.saveUserExperience(userExperience, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        AWSTask(error: error).continueWithBlock(completionHandler)
                    } else {
                        AWSTask(result: userExperience).continueWithBlock(completionHandler)
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
    
    func removeUserExperienceDynamoDB(experienceId: String, completionHandler: AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("removeUserExperienceDynamoDB:")
                let userExperiencesTable = AWSUserExperiencesTable()
                let userExperience = AWSUserExperience()
                userExperience._userId = identityId
                userExperience._experienceId = experienceId
                userExperiencesTable.removeUserExperience(userExperience, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continueWithBlock(completionHandler)
            }
        })
    }
}