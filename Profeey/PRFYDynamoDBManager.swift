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
    
    // Properties
    
    // Stores some currentUser attributes from DynamoDB during the session.
    // Need it just for saving likes, following and post in NoSQL tables.
    var currentUserDynamoDB: CurrentUser?
    
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
                awsUser?._searchProfessionName = professionName.lowercased()
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
                awsUserUpdate?._searchProfessionName = user?.professionName?.lowercased()
                usersTable.saveUser(awsUserUpdate, completionHandler: completionHandler)
                return nil
            } else {
                print("This should not happen with getIdentityId!")
                return AWSTask().continue(completionHandler)
            }
        })
    }
    
    func scanUsersDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let awsUsersTable = AWSUsersTable()
        awsUsersTable.scanUsers(completionHandler)
    }
    
    func scanUsersByProfessionNameDynamoDB(_ searchProfessionName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("scanUsersByProfessionNameDynamoDB:")
        let awsUsersTable = AWSUsersTable()
        awsUsersTable.scanUsersByProfessionName(searchProfessionName, completionHandler: completionHandler)
    }
    
    // MARK: Relationships
    
    func getRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("getRelationshipDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("getRelationshipDynamoDB:")
        let awsRelationshipsTable = AWSRelationshipsTable()
        awsRelationshipsTable.getRelationship(identityId, followingId: followingId, completionHandler: completionHandler)
    }
    
    func createRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("createRelationshipDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("createRelationshipDynamoDB:")
        let creationDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsRelationshipsTable = AWSRelationshipsTable()
        let awsRelationship = AWSRelationship(_userId: identityId, _followingId: followingId, _creationDate: creationDate, _firstName: self.currentUserDynamoDB?.firstName, _lastName: self.currentUserDynamoDB?.lastName, _preferredUsername: self.currentUserDynamoDB?.preferredUsername, _professionName: self.currentUserDynamoDB?.professionName, _profilePicUrl: self.currentUserDynamoDB?.profilePicUrl)
        awsRelationshipsTable.createRelationship(awsRelationship, completionHandler: completionHandler)
    }
    
    func removeRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("removeRelationshipDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("removeRelationshipDynamoDB:")
        let awsRelationshipsTable = AWSRelationshipsTable()
        let awsRelationship = AWSRelationship(_userId: identityId, _followingId: followingId)
        awsRelationshipsTable.removeRelationship(awsRelationship, completionHandler: completionHandler)
    }
    
    func queryFollowersDynamoDB(_ followingId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryFollowersDynamoDB:")
        let awsRelationshipsFollowersIndex = AWSRelationshipsFollowersIndex()
        awsRelationshipsFollowersIndex.queryFollowers(followingId, completionHandler: completionHandler)
    }
    
    func queryFollowingDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryFollowingDynamoDB:")
        let awsRelationshipsPrimaryIndex = AWSRelationshipsPrimaryIndex()
        awsRelationshipsPrimaryIndex.queryFollowing(userId, completionHandler: completionHandler)
    }
    
    // MARK: Recommendations
    
    func getRecommendationDynamoDB(_ recommendingId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("getRecommendationDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("getRecommendationDynamoDB:")
        let awsRecommendationsTable = AWSRecommendationsTable()
        awsRecommendationsTable.getRecommendation(identityId, recommendingId: recommendingId, completionHandler: completionHandler)
    }
    
    func createRecommendationDynamoDB(_ recommendingId: String, recommendationText: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("createRecommendationDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("createRecommendationDynamoDB:")
        let creationDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsRecommendationsTable = AWSRecommendationsTable()
        let awsRecommendation = AWSRecommendation(_userId: identityId, _recommendingId: recommendingId, _creationDate: creationDate, _recommendationText: recommendationText, _firstName: self.currentUserDynamoDB?.firstName, _lastName: self.currentUserDynamoDB?.lastName, _preferredUsername: self.currentUserDynamoDB?.preferredUsername, _professionName: self.currentUserDynamoDB?.professionName, _profilePicUrl: self.currentUserDynamoDB?.profilePicUrl)
        awsRecommendationsTable.createRecommendation(awsRecommendation, completionHandler: completionHandler)
    }
    
    func removeRecommendationDynamoDB(_ recommendingId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("removeRecommendationDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("removeRecommendationDynamoDB:")
        let awsRecommendationsTable = AWSRecommendationsTable()
        let awsRecommendation = AWSRecommendation(_userId: identityId, _recommendingId: recommendingId)
        awsRecommendationsTable.removeRecommendation(awsRecommendation, completionHandler: completionHandler)
    }
    
    func queryRecommendationsDateSortedDynamoDB(_ recommendingId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryRecommendationsDateSortedDynamoDB:")
        let awsRecommendationsDateSortedIndex = AWSRecommendationsDateSortedIndex()
        awsRecommendationsDateSortedIndex.queryRecommendationsDateSorted(recommendingId, completionHandler: completionHandler)
    }
    
    // MARK: Likes
    
    func getLikeDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("getLikeDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("getLikeDynamoDB:")
        let awsLikesTable = AWSLikesTable()
        awsLikesTable.getLike(identityId, postId: postId, completionHandler: completionHandler)
    }
    
    func createLikeDynamoDB(_ postId: String, postUserId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("createLikeDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("createLikeDynamoDB:")
        let creationDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsLikesTable = AWSLikesTable()
        let awsLike = AWSLike(_userId: identityId, _postId: postId, _creationDate: creationDate, _postUserId: postUserId, _firstName: self.currentUserDynamoDB?.firstName, _lastName: self.currentUserDynamoDB?.lastName, _preferredUsername: self.currentUserDynamoDB?.preferredUsername, _professionName: self.currentUserDynamoDB?.professionName, _profilePicUrl: self.currentUserDynamoDB?.profilePicUrl)
        awsLikesTable.createLike(awsLike, completionHandler: completionHandler)
    }
    
    func removeLikeDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("removeLikeDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("removeLikeDynamoDB:")
        let awsLikesTable = AWSLikesTable()
        let awsLike = AWSLike(_userId: identityId, _postId: postId)
        awsLikesTable.removeLike(awsLike, completionHandler: completionHandler)
    }
    
    func queryPostLikesDynamoDB(_ postId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryPostLikesDynamoDB:")
        let awsLikesPostIndex = AWSLikesPostIndex()
        awsLikesPostIndex.queryPostLikes(postId, completionHandler: completionHandler)
    }
    
    // MARK: Comments
    
    func createCommentDynamoDB(_ postId: String, postUserId: String, commentText: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("createCommentDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("createCommentDynamoDB:")
        let commentId = NSUUID().uuidString.lowercased()
        let creationDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsCommentsTable = AWSCommentsTable()
        let awsComment = AWSComment(_userId: identityId, _commentId: commentId, _creationDate: creationDate, _postId: postId, _postUserId: postUserId, _commentText: commentText, _firstName: self.currentUserDynamoDB?.firstName, _lastName: self.currentUserDynamoDB?.lastName, _preferredUsername: self.currentUserDynamoDB?.preferredUsername, _professionName: self.currentUserDynamoDB?.professionName, _profilePicUrl: self.currentUserDynamoDB?.profilePicUrl)
        awsCommentsTable.createComment(awsComment, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                AWSTask(error: error).continue(completionHandler)
            } else {
                AWSTask(result: awsComment).continue(completionHandler)
            }
            return nil
        })
    }
    
    func removeCommentDynamoDB(_ commentId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("removeCommentDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        let awsCommentsTable = AWSCommentsTable()
        let awsComment = AWSComment(_userId: identityId, _commentId: commentId)
        awsCommentsTable.removeComment(awsComment, completionHandler: completionHandler)
    }
    
    func queryPostCommentsDateSortedDynamoDB(_ postId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryPostCommentsDateSortedDynamoDB:")
        let awsCommentsPostIndex = AWSCommentsPostIndex()
        awsCommentsPostIndex.queryPostCommentsDateSorted(postId, completionHandler: completionHandler)
    }
    
    
    // MARK: Posts
    
    func queryUserPostsDateSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryUserPostsDateSortedDynamoDB:")
        let awsPostsDateSortedIndex = AWSPostsDateSortedIndex()
        awsPostsDateSortedIndex.queryUserPostsDateSorted(userId, completionHandler: completionHandler)
    }
    
    func queryUserPostsDateSortedWithCategoryNameDynamoDB(_ userId: String, categoryName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryUserPostsDateSortedWithCategoryNameDynamoDB:")
        let awsPostsDateSortedIndex = AWSPostsDateSortedIndex()
        awsPostsDateSortedIndex.queryUserPostsDateSortedWithCategoryName(userId, categoryName: categoryName, completionHandler: completionHandler)
    }
    
    func createPostDynamoDB(_ imageUrl: String?, caption: String?, categoryName: String?, completionHandler: @escaping AWSContinuationBlock) {
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
                
                awsPost?._firstName = self.currentUserDynamoDB?.firstName
                awsPost?._lastName = self.currentUserDynamoDB?.lastName
                awsPost?._preferredUsername = self.currentUserDynamoDB?.preferredUsername
                awsPost?._professionName = self.currentUserDynamoDB?.professionName
                awsPost?._profilePicUrl = self.currentUserDynamoDB?.profilePicUrl
                
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
    
    func updatePostDynamoDB(_ postId: String, caption: String?, categoryName: String?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("updatePostDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("updatePostDynamoDB:")
        let awsPostsTable = AWSPostsTable()
        let awsPostUpdate = AWSPostUpdate()
        awsPostUpdate?._userId = identityId
        awsPostUpdate?._postId = postId
        awsPostUpdate?._caption = caption
        awsPostUpdate?._categoryName = categoryName
        awsPostsTable.savePost(awsPostUpdate, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                AWSTask(error: error).continue(completionHandler)
            } else {
                AWSTask(result: awsPostUpdate).continue(completionHandler)
            }
            return nil
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
        let awsCategoriesTable = AWSCategoriesTable()
        awsCategoriesTable.scanCategories(completionHandler)
    }
    
//    func scanCategoriesByCategoryNameDynamoDB(_ searchCategoryName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
//        print("scanCategoriesByCategoryNameDynamoDB:")
//        let awsCategoriesTable = AWSCategoriesTable()
//        awsCategoriesTable.scanCategoriesByCategoryName(searchCategoryName, completionHandler: completionHandler)
//    }
    
    // MARK: Professions
    
    func scanProfessionsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("scanProfessionsDynamoDB:")
        let awsProfessionsTable = AWSProfessionsTable()
        awsProfessionsTable.scanProfessions(completionHandler)
    }
    
//    func scanProfessionsByProfessionNameDynamoDB(_ searchProfessionName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
//        print("scanProfessionsByProfessionNameDynamoDB:")
//        let awsProfessionsTable = AWSProfessionsTable()
//        awsProfessionsTable.scanProfessionsByProfessionName(searchProfessionName, completionHandler: completionHandler)
//    }
    
    // MARK: Locations
    
    func scanLocationsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("scanLocationsDynamoDB:")
        let awsLocationsTable = AWSLocationsTable()
        awsLocationsTable.scanLocations(completionHandler)
    }
    
//    func scanLocationsByCountryOrCityNameDynamoDB(_ searchCountryName: String, searchCityName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
//        print("scanLocationsByCountryOrCityNameDynamoDB:")
//        let awsLocationsTable = AWSLocationsTable()
//        awsLocationsTable.scanLocationsByCountryOrCityName(searchCountryName, searchCityName: searchCityName, completionHandler: completionHandler)
//    }
    
    // MARK: Activities
    
    func queryUserActivitiesDateSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryUserActivitiesDateSortedDynamoDB:")
        let awsActivitiesDateSortedIndex = AWSActivitiesDateSortedIndex()
        awsActivitiesDateSortedIndex.queryUserActivitiesDateSorted(userId, completionHandler: completionHandler)
    }
    
    // MARK: UserCategories
    
    func queryUserCategoriesNumberOfPostsSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryUserCategoriesNumberOfPostsSortedDynamoDB:")
        let awsUserCategoriesNumberOfPostsSortedIndex = AWSUserCategoriesNumberOfPostsSortedIndex()
        awsUserCategoriesNumberOfPostsSortedIndex.queryUserCategoriesNumberOfPostsSorted(userId, completionHandler: completionHandler)
    }
    
    // MARK: WorkExperiences
    
    func createWorkExperienceDynamoDB(_ title: String?, organization: String?, workDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("createWorkExperienceDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("createWorkExperienceDynamoDB:")
        let workExperienceId = NSUUID().uuidString.lowercased()
        let creationDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsWorkExperiencesTable = AWSWorkExperiencesTable()
        let awsWorkExperience = AWSWorkExperience(_userId: identityId, _workExperienceId: workExperienceId, _creationDate: creationDate, _title: title, _organization: organization, _workDescription: workDescription, _fromMonth: fromMonth, _fromYear: fromYear, _toMonth: toMonth, _toYear: toYear)
        awsWorkExperiencesTable.saveWorkExperience(awsWorkExperience, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                AWSTask(error: error).continue(completionHandler)
            } else {
                AWSTask(result: awsWorkExperience).continue(completionHandler)
            }
            return nil
        })
    }
    
    func updateWorkExperienceDynamoDB(_ workExperienceId: String, title: String?, organization: String?, workDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("updateWorkExperienceDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("updateWorkExperienceDynamoDB:")
        let awsWorkExperiencesTable = AWSWorkExperiencesTable()
        let awsWorkExperienceUpdate = AWSWorkExperienceUpdate(_userId: identityId, _workExperienceId: workExperienceId, _creationDate: nil, _title: title, _organization: organization, _workDescription: workDescription, _fromMonth: fromMonth, _fromYear: fromYear, _toMonth: toMonth, _toYear: toYear)
        awsWorkExperiencesTable.saveWorkExperience(awsWorkExperienceUpdate, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                AWSTask(error: error).continue(completionHandler)
            } else {
                AWSTask(result: awsWorkExperienceUpdate).continue(completionHandler)
            }
            return nil
        })
    }
    
    func removeWorkExperienceDynamoDB(_ workExperienceId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("removeWorkExperienceDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("removeWorkExperienceDynamoDB:")
        let awsWorkExperiencesTable = AWSWorkExperiencesTable()
        let awsWorkExperience = AWSWorkExperience(_userId: identityId, _workExperienceId: workExperienceId)
        awsWorkExperiencesTable.removeWorkExperience(awsWorkExperience, completionHandler: completionHandler)
    }
    
    func queryWorkExperiencesDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryWorkExperiencesDynamoDB:")
        let awsWorkExperiencesPrimaryIndex = AWSWorkExperiencesPrimaryIndex()
        awsWorkExperiencesPrimaryIndex.queryWorkExperiences(userId, completionHandler: completionHandler)
    }
    
    // MARK: WorkExperiences
    
    func createEducationDynamoDB(_ school: String?, fieldOfStudy: String?, educationDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("creatEducationDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("creatEducationDynamoDB:")
        let educationId = NSUUID().uuidString.lowercased()
        let creationDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsEducationsTable = AWSEducationsTable()
        let awsEducation = AWSEducation(_userId: identityId, _educationId: educationId, _creationDate: creationDate, _school: school, _fieldOfStudy: fieldOfStudy, _educationDescription: educationDescription, _fromMonth: fromMonth, _fromYear: fromYear, _toMonth: toMonth, _toYear: toYear)
        awsEducationsTable.saveEducation(awsEducation, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                AWSTask(error: error).continue(completionHandler)
            } else {
                AWSTask(result: awsEducation).continue(completionHandler)
            }
            return nil
        })
    }
    
    func updateEducationDynamoDB(_ educationId: String, school: String?, fieldOfStudy: String?, educationDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("updateEducationDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("updateEducationDynamoDB:")
        let awsEducationsTable = AWSEducationsTable()
        let awsEducationUpdate = AWSEducationUpdate(_userId: identityId, _educationId: educationId, _creationDate: nil, _school: school, _fieldOfStudy: fieldOfStudy, _educationDescription: educationDescription, _fromMonth: fromMonth, _fromYear: fromYear, _toMonth: toMonth, _toYear: toYear)
        awsEducationsTable.saveEducation(awsEducationUpdate, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                AWSTask(error: error).continue(completionHandler)
            } else {
                AWSTask(result: awsEducationUpdate).continue(completionHandler)
            }
            return nil
        })
    }
    
    func removeEducationDynamoDB(_ educationId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("removeEducationDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("removeEducationDynamoDB:")
        let awsEducationsTable = AWSEducationsTable()
        let awsEducation = AWSEducation(_userId: identityId, _educationId: educationId)
        awsEducationsTable.removeEducation(awsEducation, completionHandler: completionHandler)
    }
    
    func queryEducationsDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryEducationsDynamoDB:")
        let awsEducationsPrimaryIndex = AWSEducationsPrimaryIndex()
        awsEducationsPrimaryIndex.queryEducations(userId, completionHandler: completionHandler)
    }
}
