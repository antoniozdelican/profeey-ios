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
    
    fileprivate static var sharedInstance: PRFYDynamoDBManager!
    
    static func defaultDynamoDBManager() -> PRFYDynamoDBManager {
        if sharedInstance == nil {
            sharedInstance = PRFYDynamoDBManager()
        }
        return sharedInstance
    }
    
    // MARK: Users
    
    func getCurrentUserDynamoDB(_ completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("getCurrentUserDynamoDB:")
                let usersTable = AWSUsersTable()
                usersTable.getUser(identityId, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func getUserDynamoDB(_ userId: String, completionHandler: @escaping AWSContinuationBlock) {
        print("getUserDynamoDB:")
        let usersTable = AWSUsersTable()
        usersTable.getUser(userId, completionHandler: completionHandler)
    }
    
    // Creates a user on landing.
    func createUserDynamoDB(_ email: String, firstName: String, lastName: String, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveUserDynamoDB:")
                let awsUsersTable = AWSUsersTable()
                let awsUser = AWSUser()
                awsUser?._userId = identityId
                awsUser?._creationDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
                awsUser?._email = email
                awsUser?._firstName = firstName
                awsUser?._lastName = lastName
                awsUser?._searchFirstName = firstName.lowercased()
                awsUser?._searchLastName = lastName.lowercased()
                awsUsersTable.saveUserSkipNull(awsUser, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func saveUserPreferredUsernameAndProfilePicDynamoDB(_ preferredUsername: String, profilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveUserPreferredUsernameAndProfilePicDynamoDB:")
                let awsUsersTable = AWSUsersTable()
                let awsUser = AWSUser()
                awsUser?._userId = identityId
                awsUser?._preferredUsername = preferredUsername
                awsUser?._searchPreferredUsername = preferredUsername.lowercased()
                awsUser?._profilePicUrl = profilePicUrl
                awsUsersTable.saveUserSkipNull(awsUser, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func saveUserProfessionDynamoDB(_ professionName: String, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveUserProfessionDynamoDB:")
                let awsUsersTable = AWSUsersTable()
                let awsUser = AWSUser()
                awsUser?._userId = identityId
                awsUser?._professionName = professionName
                awsUsersTable.saveUserSkipNull(awsUser, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func saveUserDynamoDB(_ user: User?, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveUserDynamoDB:")
                let usersTable = AWSUsersTable()
                let awsUserUpdate = AWSUserUpdate()
                awsUserUpdate?._userId = identityId
                awsUserUpdate?._firstName = user?.firstName
                awsUserUpdate?._lastName = user?.lastName
                awsUserUpdate?._professionName = user?.professionName
                awsUserUpdate?._profilePicUrl = user?.profilePicUrl
                awsUserUpdate?._about = user?.about
                awsUserUpdate?._locationName = user?.locationName
                awsUserUpdate?._searchFirstName = user?.firstName?.lowercased()
                awsUserUpdate?._searchLastName = user?.lastName?.lowercased()
                usersTable.saveUser(awsUserUpdate, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func scanUsersDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let usersTable = AWSUsersTable()
        usersTable.scanUsers(completionHandler)
    }
    
    func scanUsersByFirstLastNameDynamoDB(_ searchFirstName: String, searchLastName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("scanUsersByFirstLastNameDynamoDB:")
        let usersTable = AWSUsersTable()
        usersTable.scanUsersByFirstLastName(searchFirstName, searchLastName: searchLastName, completionHandler: completionHandler)
    }
    
    // MARK: UserRelationships
    
    func getUserRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("getUserRelationshipDynamoDB:")
                let userRelationshipsTable = AWSUserRelationshipsTable()
                userRelationshipsTable.getUserRelationship(identityId, followingId: followingId, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func saveUserRelationshipDynamoDB(_ followingId: String, follower: User?, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveUserRelationshipDynamoDB:")
                let userRelationshipsTable = AWSUserRelationshipsTable()
                let userRelationship = AWSUserRelationship()
                userRelationship?._userId = identityId
                userRelationship?._creationDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
                userRelationship?._followingId = followingId
                
                userRelationship?._firstName = follower?.firstName
                userRelationship?._lastName = follower?.lastName
                userRelationship?._preferredUsername = follower?.preferredUsername
                userRelationship?._professionName = follower?.professionName
                userRelationship?._profilePicUrl = follower?.profilePicUrl
                
                userRelationshipsTable.saveUserRelationship(userRelationship, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func removeUserRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("removeUserRelationshipDynamoDB:")
                let userRelationshipsTable = AWSUserRelationshipsTable()
                let userRelationship = AWSUserRelationship()
                userRelationship?._userId = identityId
                userRelationship?._followingId = followingId
                userRelationshipsTable.removeUserRelationship(userRelationship, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func queryUserFollowersDynamoDB(_ followingId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryUserFollowersDynamoDB:")
        let userRelationshipsFollowersIndex = AWSUserRelationshipsFollowersIndex()
        userRelationshipsFollowersIndex.queryUserFollowers(followingId, completionHandler: completionHandler)
    }
    
    // MARK: Likes
    
    func getLikeDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("getLikeDynamoDB:")
                let likesTable = AWSLikesTable()
                likesTable.getLike(identityId, postId: postId, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func saveLikeDynamoDB(_ postId: String, postUserId: String, liker: User?, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveLikeDynamoDB:")
                let likesTable = AWSLikesTable()
                let like = AWSLike()
                like?._userId = identityId
                like?._postId = postId
                like?._postUserId = postUserId
                like?._creationDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
                
                like?._firstName = liker?.firstName
                like?._lastName = liker?.lastName
                like?._preferredUsername = liker?.preferredUsername
                like?._professionName = liker?.professionName
                like?._profilePicUrl = liker?.profilePicUrl
                likesTable.saveLike(like, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func removeLikeDynamoDB(_ postId: String, postUserId: String, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("removeLikeDynamoDB:")
                let likesTable = AWSLikesTable()
                let like = AWSLike()
                like?._userId = identityId
                like?._postId = postId
                like?._postUserId = postUserId
                likesTable.removeLike(like, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func queryPostLikersDynamoDB(_ postId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryPostLikersDynamoDB:")
        let likesPostIndex = AWSLikesPostIndex()
        likesPostIndex.queryPostLikers(postId, completionHandler: completionHandler)
    }
    
    
    // MARK: Posts
    
    func queryUserPostsDateSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryUserPostsDateSortedDynamoDB:")
        let postsDateSortedIndex = AWSPostsDateSortedIndex()
        postsDateSortedIndex.queryUserPostsDateSorted(userId, completionHandler: completionHandler)
    }
    
    func queryCategoryPostsDateSortedDynamoDB(_ categoryName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryCategoryPostsDateSortedDynamoDB:")
        let postsCategoryNameIndex = AWSPostsCategoryNameIndex()
        postsCategoryNameIndex.queryCategoryPostsDateSorted(categoryName, completionHandler: completionHandler)
    }
    
    func createPostDynamoDB(_ imageUrl: String?, caption: String?, categoryName: String?, user: User?, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("savePostDynamoDB:")
                let awsPostsTable = AWSPostsTable()
                let awsPost = AWSPost()
                awsPost?._userId = identityId
                awsPost?._postId = NSUUID().uuidString.lowercased()
                awsPost?._caption = caption
                awsPost?._categoryName = categoryName
                awsPost?._creationDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
                awsPost?._imageUrl = imageUrl
                awsPost?._numberOfLikes = 0
                
                awsPost?._firstName = user?.firstName
                awsPost?._lastName = user?.lastName
                awsPost?._preferredUsername = user?.preferredUsername
                awsPost?._professionName = user?.professionName
                awsPost?._profilePicUrl = user?.profilePicUrl
                
                awsPostsTable.savePost(awsPost, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        AWSTask(error: error).continue(completionHandler)
                    } else {
                        // Return initialized post to caller.
                        AWSTask(result: awsPost).continue(completionHandler)
                    }
                    return nil
                })
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func updatePostDynamoDB(_ post: Post?, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("updatePostDynamoDB:")
                let awsPostsTable = AWSPostsTable()
                let awsPostUpdate = AWSPostUpdate()
                awsPostUpdate?._userId = identityId
                awsPostUpdate?._postId = post?.postId
                awsPostUpdate?._caption = post?.caption
                awsPostUpdate?._categoryName = post?.categoryName
                awsPostsTable.savePost(awsPostUpdate, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        AWSTask(error: error).continue(completionHandler)
                    } else {
                        // Return initialized post to caller.
                        AWSTask(result: awsPostUpdate).continue(completionHandler)
                    }
                    return nil
                })
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func removePostDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("removePostDynamoDB:")
                let awsPostsTable = AWSPostsTable()
                let awsPost = AWSPost()
                awsPost?._userId = identityId
                awsPost?._postId = postId
                awsPostsTable.removePost(awsPost, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    // MARK: Categories
    
    func scanCategoriesDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("scanCategoriesDynamoDB:")
        let categoriesTable = AWSCategoriesTable()
        categoriesTable.scanCategories(completionHandler)
    }
    
    func scanCategoriesByCategoryNameDynamoDB(_ searchCategoryName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("scanCategoriesByCategoryNameDynamoDB:")
        let categoriesTable = AWSCategoriesTable()
        categoriesTable.scanCategoriesByCategoryName(searchCategoryName, completionHandler: completionHandler)
    }
    
    // MARK: Professions
    
    func scanProfessionsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("scanProfessions:")
        let professionsTable = AWSProfessionsTable()
        professionsTable.scanProfessions(completionHandler)
    }
    
    func scanProfessionsByProfessionNameDynamoDB(_ searchProfessionName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("scanProfessionsByProfessionNameDynamoDB:")
        let professionsTable = AWSProfessionsTable()
        professionsTable.scanProfessionsByProfessionName(searchProfessionName, completionHandler: completionHandler)
    }
    
    // MARK: Activities
    
    func queryUserActivitiesDateSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryUserActivitiesDateSortedDynamoDB:")
        let activitiesDateSortedIndex = AWSActivitiesDateSortedIndex()
        activitiesDateSortedIndex.queryUserActivitiesDateSorted(userId, completionHandler: completionHandler)
    }
    
    // MARK: UserCategories
    
    func queryUserCategoriesNumberOfPostsSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryUserCategoriesNumberOfPostsSortedDynamoDB:")
        let userCategoriesNumberOfPostsIndex = AWSUserCategoriesNumberOfPostsIndex()
        userCategoriesNumberOfPostsIndex.queryUserCategoriesNumberOfPostsSorted(userId, completionHandler: completionHandler)
    }
    
    // MARK: UserExperiences
    
    func queryUserExperiencesDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryUserExperiencesDynamoDB:")
        let userExperiencesPrimaryIndex = AWSUserExperiencesPrimaryIndex()
        userExperiencesPrimaryIndex.queryUserExperiences(userId, completionHandler: completionHandler)
    }
    
    func saveUserExperienceDynamoDB(_ experienceId: String?, position: String?, organization: String?, fromDate: NSNumber?, toDate: NSNumber?, experienceType: NSNumber?, completionHandler: @escaping AWSContinuationBlock) {
        // Save new and update existing hence experienceId is optional.
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("saveUserExperienceDynamoDB:")
                let userExperiencesTable = AWSUserExperiencesTable()
                let userExperience = AWSUserExperience()
                userExperience?._userId = identityId
                userExperience?._experienceId = experienceId != nil ? experienceId : NSUUID().uuidString.lowercased()
                userExperience?._position = position
                userExperience?._organization = organization
                userExperience?._fromDate = fromDate
                userExperience?._toDate = toDate
                userExperience?._experienceType = experienceType
                userExperiencesTable.saveUserExperience(userExperience, completionHandler: {
                    (task: AWSTask) in
                    if let error = task.error {
                        AWSTask(error: error).continue(completionHandler)
                    } else {
                        AWSTask(result: userExperience).continue(completionHandler)
                    }
                    return nil
                })
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func removeUserExperienceDynamoDB(_ experienceId: String, completionHandler: @escaping AWSContinuationBlock) {
        AWSClientManager.defaultClientManager().credentialsProvider?.getIdentityId().continue({
            (task: AWSTask) in
            if let error = task.error {
                print("getIdentityId error: \(error.localizedDescription)")
                return AWSTask(error: error).continue(completionHandler)
            } else if let identityId = task.result as? String {
                
                print("removeUserExperienceDynamoDB:")
                let userExperiencesTable = AWSUserExperiencesTable()
                let userExperience = AWSUserExperience()
                userExperience?._userId = identityId
                userExperience?._experienceId = experienceId
                userExperiencesTable.removeUserExperience(userExperience, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
}
