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
    
    // Stores currentUser attributes from DynamoDB during the session.
    var currentUserDynamoDB: CurrentUser?
    
    // MARK: CurrentUser
    
    func updateCurrentUserLocal(_ firstName: String?, lastName: String?, preferredUsername: String?, professionName: String?, profilePicUrl: String?, locationId: String?, locationName: String?, profilePic: UIImage?) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("updateCurrentUserLocal no identityId!")
            return
        }
        if self.currentUserDynamoDB == nil {
            self.currentUserDynamoDB = CurrentUser(userId: identityId)
        }
        self.currentUserDynamoDB?.firstName = firstName
        self.currentUserDynamoDB?.lastName = lastName
        self.currentUserDynamoDB?.preferredUsername = preferredUsername
        self.currentUserDynamoDB?.professionName = professionName
        self.currentUserDynamoDB?.profilePicUrl = profilePicUrl
        self.currentUserDynamoDB?.locationId = locationId
        self.currentUserDynamoDB?.locationName = locationName
        self.currentUserDynamoDB?.profilePic = profilePic
    }
    
    // MARK: Users
    
    func getCurrentUserDynamoDB(_ completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("getCurrentUserDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("getCurrentUserDynamoDB:")
        let usersTable = AWSUsersTable()
        usersTable.getUser(identityId, completionHandler: completionHandler)
    }
    
    func getUserDynamoDB(_ userId: String, completionHandler: @escaping AWSContinuationBlock) {
        print("getUserDynamoDB:")
        let usersTable = AWSUsersTable()
        usersTable.getUser(userId, completionHandler: completionHandler)
    }
    
    // Creates user on landing.
    func createUserDynamoDB(_ email: String, firstName: String, lastName: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("getRelationshipDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("createUserDynamoDB:")
        let creationDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsUsersTable = AWSUsersTable()
        let awsUser = AWSUser(_userId: identityId, _creationDate: creationDate, _firstName: firstName, _lastName: lastName, _email: email)
        awsUsersTable.saveUserSkipNull(awsUser, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                AWSTask(error: error).continue(completionHandler)
            } else {
                // Set currentUser (init).
                self.currentUserDynamoDB = CurrentUser(userId: identityId)
                self.currentUserDynamoDB?.firstName = firstName
                self.currentUserDynamoDB?.lastName = lastName
                AWSTask(result: awsUser).continue(completionHandler)
            }
            return nil
        })
    }
    
    // Updates user on landing.
    func updateUserPreferredUsernameAndProfilePicDynamoDB(_ preferredUsername: String, profilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("saveUserPreferredUsernameAndProfilePicDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("saveUserPreferredUsernameAndProfilePicDynamoDB:")
        let awsUsersTable = AWSUsersTable()
        let awsUser = AWSUser(_userId: identityId, _preferredUsername: preferredUsername, _profilePicUrl: profilePicUrl)
        awsUsersTable.saveUserSkipNull(awsUser, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                AWSTask(error: error).continue(completionHandler)
            } else {
                // Set currentUser.
                self.currentUserDynamoDB?.preferredUsername = preferredUsername
                self.currentUserDynamoDB?.profilePicUrl = profilePicUrl
                AWSTask(result: awsUser).continue(completionHandler)
            }
            return nil
        })
    }
    
    // Updates user on landing.
    func updateUserProfessionDynamoDB(_ professionName: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("saveUserProfessionDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("saveUserProfessionDynamoDB:")
        let awsUsersTable = AWSUsersTable()
        let awsUser = AWSUser(_userId: identityId, _professionName: professionName)
        awsUsersTable.saveUserSkipNull(awsUser, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                AWSTask(error: error).continue(completionHandler)
            } else {
                // Set currentUser.
                self.currentUserDynamoDB?.professionName = professionName
                AWSTask(result: awsUser).continue(completionHandler)
            }
            return nil
        })
    }
    
    func updateUserDynamoDB(_ firstName: String?, lastName: String?, professionName: String?, profilePicUrl: String?, about: String?, locationId: String?, locationName: String?, website: String?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("updateUserDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("updateUserDynamoDB:")
        let awsUsersTable = AWSUsersTable()
        let awsUserUpdate = AWSUserUpdate(_userId: identityId, _firstName: firstName, _lastName: lastName, _professionName: professionName, _profilePicUrl: profilePicUrl, _about: about, _locationId: locationId, _locationName: locationName, _website: website)
        awsUsersTable.saveUser(awsUserUpdate, completionHandler: completionHandler)
    }
    
    func scanUsersDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let awsUsersTable = AWSUsersTable()
        awsUsersTable.scanUsers(completionHandler)
    }
    
    func queryLocationUsers(_ locationId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let awsUsersLocationIndex = AWSUsersLocationIndex()
        awsUsersLocationIndex.queryLocationUsers(locationId, completionHandler: completionHandler)
    }
    
    func queryProfessionUsers(_ professionName: String, locationId: String?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let awsUsersProfessionIndex = AWSUsersProfessionIndex()
        awsUsersProfessionIndex.queryProfessionUsers(professionName, locationId: locationId, completionHandler: completionHandler)
    }
    
    // Check if preferredUsername already exists in DynamoDB.
    func queryPreferredUsernamesDynamoDB(_ preferredUsername: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryPreferredUsernamesDynamoDB:")
        let awsUsersPreferredUsernameIndex = AWSUsersPreferredUsernameIndex()
        awsUsersPreferredUsernameIndex.queryPreferredUsernames(preferredUsername, completionHandler: completionHandler)
    }
    
    // MARK: Relationships
    
    func getRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("getRelationshipDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("getRelationshipDynamoDB:")
        let awsRelationshipsTable = AWSRelationshipsTable()
        awsRelationshipsTable.getRelationship(identityId, followingId: followingId, completionHandler: completionHandler)
    }
    
    func createRelationshipDynamoDB(_ followingId: String, followingFirstName: String?, followingLastName: String?, followingPreferredUsername: String?, followingProfessionName: String?, followingProfilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createRelationshipDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("createRelationshipDynamoDB:")
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsRelationshipsTable = AWSRelationshipsTable()
        let awsRelationship = AWSRelationship(_userId: identityId, _followingId: followingId, _created: created, _firstName: self.currentUserDynamoDB?.firstName, _lastName: self.currentUserDynamoDB?.lastName, _preferredUsername: self.currentUserDynamoDB?.preferredUsername, _professionName: self.currentUserDynamoDB?.professionName, _profilePicUrl: self.currentUserDynamoDB?.profilePicUrl, _followingFirstName: followingFirstName, _followingLastName: followingLastName, _followingPreferredUsername: followingPreferredUsername, _followingProfessionName: followingProfessionName, _followingProfilePicUrl: followingProfilePicUrl)
        awsRelationshipsTable.createRelationship(awsRelationship, completionHandler: completionHandler)
    }
    
    func removeRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("removeRelationshipDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("removeRelationshipDynamoDB:")
        let awsRelationshipsTable = AWSRelationshipsTable()
        let awsRelationship = AWSRelationship(_userId: identityId, _followingId: followingId)
        awsRelationshipsTable.removeRelationship(awsRelationship, completionHandler: completionHandler)
    }
    
    func queryFollowersDynamoDB(_ followingId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryFollowersDynamoDB:")
        let awsRelationshipsFollowingIdIndex = AWSRelationshipsFollowingIdIndex()
        awsRelationshipsFollowingIdIndex.queryFollowers(followingId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    func queryFollowingDynamoDB(_ userId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryFollowingDynamoDB:")
        let awsRelationshipsPrimaryIndex = AWSRelationshipsPrimaryIndex()
        awsRelationshipsPrimaryIndex.queryFollowing(userId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    func queryFollowingIdsDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryFollowingIdsDynamoDB:")
        let awsRelationshipsPrimaryIndex = AWSRelationshipsPrimaryIndex()
        awsRelationshipsPrimaryIndex.queryFollowingIds(userId, completionHandler: completionHandler)
    }
    
    // MARK: Recommendations
    
    func getRecommendationDynamoDB(_ recommendingId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("getRecommendationDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("getRecommendationDynamoDB:")
        let awsRecommendationsTable = AWSRecommendationsTable()
        awsRecommendationsTable.getRecommendation(identityId, recommendingId: recommendingId, completionHandler: completionHandler)
    }
    
    func createRecommendationDynamoDB(_ recommendingId: String, recommendationText: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
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
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
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
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("getLikeDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("getLikeDynamoDB:")
        let awsLikesTable = AWSLikesTable()
        awsLikesTable.getLike(identityId, postId: postId, completionHandler: completionHandler)
    }
    
    func createLikeDynamoDB(_ postId: String, postUserId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
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
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("removeLikeDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("removeLikeDynamoDB:")
        let awsLikesTable = AWSLikesTable()
        let awsLike = AWSLike(_userId: identityId, _postId: postId)
        awsLikesTable.removeLike(awsLike, completionHandler: completionHandler)
    }
    
    func queryPostLikesDynamoDB(_ postId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryPostLikesDynamoDB:")
        let awsLikesPostIndex = AWSLikesPostIndex()
        awsLikesPostIndex.queryPostLikes(postId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    // MARK: Comments
    
    func createCommentDynamoDB(_ postId: String, postUserId: String, commentText: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createCommentDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("createCommentDynamoDB:")
        let commentId = NSUUID().uuidString.lowercased()
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsCommentsTable = AWSCommentsTable()
        let awsComment = AWSComment(_userId: identityId, _commentId: commentId, _created: created, _commentText: commentText, _postId: postId, _postUserId: postUserId, _firstName: self.currentUserDynamoDB?.firstName, _lastName: self.currentUserDynamoDB?.lastName, _preferredUsername: self.currentUserDynamoDB?.preferredUsername, _professionName: self.currentUserDynamoDB?.professionName, _profilePicUrl: self.currentUserDynamoDB?.profilePicUrl)
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
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
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
    
    func queryUserPostsDateSortedDynamoDB(_ userId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryUserPostsDateSortedDynamoDB:")
        let awsPostsDateSortedIndex = AWSPostsDateSortedIndex()
        awsPostsDateSortedIndex.queryUserPostsDateSorted(userId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    func queryUserPostsDateSortedWithCategoryNameDynamoDB(_ userId: String, categoryName: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryUserPostsDateSortedWithCategoryNameDynamoDB:")
        let awsPostsDateSortedIndex = AWSPostsDateSortedIndex()
        awsPostsDateSortedIndex.queryUserPostsDateSortedWithCategoryName(userId, categoryName: categoryName, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    func getPostDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("getPostDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("getPostDynamoDB:")
        let awsPostsTable = AWSPostsTable()
        awsPostsTable.getPost(identityId, postId: postId, completionHandler: completionHandler)
    }
    
    func createPostDynamoDB(_ imageUrl: String?, imageWidth: NSNumber?, imageHeight: NSNumber?, caption: String?, categoryName: String?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createPostDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("createPostDynamoDB:")
        let postId = NSUUID().uuidString.lowercased()
        let creationDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsPostsTable = AWSPostsTable()
        let awsPost = AWSPost(_userId: identityId, _postId: postId, _creationDate: creationDate, _caption: caption, _categoryName: categoryName, _imageUrl: imageUrl, _imageWidth: imageWidth, _imageHeight: imageHeight, _firstName: self.currentUserDynamoDB?.firstName, _lastName: self.currentUserDynamoDB?.lastName, _preferredUsername: self.currentUserDynamoDB?.preferredUsername, _professionName: self.currentUserDynamoDB?.professionName, _profilePicUrl: self.currentUserDynamoDB?.profilePicUrl)
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
    }
    
    func updatePostDynamoDB(_ postId: String, caption: String?, categoryName: String?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("updatePostDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("updatePostDynamoDB:")
        let awsPostsTable = AWSPostsTable()
        let awsPostUpdate = AWSPostUpdate(_userId: identityId, _postId: postId, _caption: caption, _categoryName: categoryName)
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
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("removePostDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("removePostDynamoDB:")
        let awsPostsTable = AWSPostsTable()
        let awsPost = AWSPost(_userId: identityId, _postId: postId)
        awsPostsTable.removePost(awsPost, completionHandler: completionHandler)
    }
    
    // MARK: Activities
    
    func queryUserActivitiesDateSortedDynamoDB(_ lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("queryUserActivitiesDateSortedDynamoDB no identityId!")
            return
        }
        let awsActivitiesDateSortedIndex = AWSActivitiesDateSortedIndex()
        awsActivitiesDateSortedIndex.queryUserActivitiesDateSorted(identityId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    // MARK: Notifications
    
    func queryUserNotificationsDateSortedDynamoDB(_ lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("queryUserNotificationsDateSortedDynamoDB no identityId!")
            return
        }
        let awsNotificationsDateSortedIndex = AWSNotificationsDateSortedIndex()
        awsNotificationsDateSortedIndex.queryUserNotificationsDateSorted(identityId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    // MARK: UserEndpoints
    
    func saveUserEndpointDynamoDB(_ endpointARN: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("saveEndpointDynamoDB no identityId!")
            return
        }
        print("saveEndpointDynamoDB:")
        let awsUserEndpointsTable = AWSUserEndpointsTable()
        let awsUserEndpoint = AWSUserEndpoint(_userId: identityId, _endpointARN: endpointARN)
        awsUserEndpointsTable.saveUserEndpoint(awsUserEndpoint, completionHandler: completionHandler)
    }
    
    // MARK: UserCategories
    
    func queryUserCategoriesNumberOfPostsSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryUserCategoriesNumberOfPostsSortedDynamoDB:")
        let awsUserCategoriesNumberOfPostsSortedIndex = AWSUserCategoriesNumberOfPostsSortedIndex()
        awsUserCategoriesNumberOfPostsSortedIndex.queryUserCategoriesNumberOfPostsSorted(userId, completionHandler: completionHandler)
    }
    
    // MARK: WorkExperiences
    
    func createWorkExperienceDynamoDB(_ title: String?, organization: String?, workDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
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
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
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
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
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
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
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
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
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
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
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
    
    // MARK: Professions
    
    func scanProfessionsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?){
        let awsProfessionsTable = AWSProfessionsTable()
        awsProfessionsTable.scanProfessions(completionHandler)
    }
    
    // MARK: Categories
    
    func scanCategoriesDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?){
        let awsCategoriesTable = AWSCategoriesTable()
        awsCategoriesTable.scanCategories(completionHandler)
    }
    
    // MARK: Locations
    
    func scanLocationsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?){
        let awsLocationsTable = AWSLocationsTable()
        awsLocationsTable.scanLocations(completionHandler)
    }
    
    // MARK: ProfessionLocations
    
    func queryLocationProfessions(_ locationId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?){
        let awsProfessionLocationsLocationIndex = AWSProfessionLocationsLocationIndex()
        awsProfessionLocationsLocationIndex.queryLocationProfessions(locationId, completionHandler: completionHandler)
    }
    
    // MARK: Messages
    
    func createMessageDynamoDB(_ conversationId: String, recipientId: String, messageText: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createMessageDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        let messageId = NSUUID().uuidString.lowercased()
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsMessagesTable = AWSMessagesTable()
        let awsMessage = AWSMessage(_conversationId: conversationId, _messageId: messageId, _created: created, _messageText: messageText, _senderId: identityId, _recipientId: recipientId)
        awsMessagesTable.createMessage(awsMessage, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                AWSTask(error: error).continue(completionHandler)
            } else {
                AWSTask(result: awsMessage).continue(completionHandler)
            }
            return nil
        })
    }
    
    func removeMessageDynamoDB(_ conversationId: String, messageId: String, completionHandler: @escaping AWSContinuationBlock) {
        let awsMessagesTable = AWSMessagesTable()
        let awsMessage = AWSMessage(_conversationId: conversationId, _messageId: messageId)
        awsMessagesTable.removeMessage(awsMessage, completionHandler: completionHandler)
    }
    
    func queryConversationMessagesDateSortedDynamoDB(_ conversationId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?){
        let awsMessagesDateSortedIndex = AWSMessagesDateSortedIndex()
        awsMessagesDateSortedIndex.queryConversationMessagesDateSorted(conversationId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    // MARK: Conversations
    
    /*
     IMPORTANT!
     Create and remove are called (in background) only when first/last message is created between users.
     */
    
    func createConversationDynamoDB(_ messageText: String, participantId: String, participantFirstName: String?, participantLastName: String?, participantPreferredUsername: String?, participantProfessionName: String?, participantProfilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createConversationDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsConversationsTable = AWSConversationsTable()
        let conversationId = [identityId, participantId].joined(separator: "+conversation+")
        let awsConversation = AWSConversation(_userId: identityId, _conversationId: conversationId, _created: created, _lastMessageText: messageText, _lastMessageCreated: created, _participantId: participantId, _participantFirstName: participantFirstName, _participantLastName: participantLastName, _participantPreferredUsername: participantPreferredUsername, _participantProfessionName: participantProfessionName, _participantProfilePicUrl: participantProfilePicUrl)
        awsConversationsTable.createConversation(awsConversation, completionHandler: completionHandler)
    }
    
    func removeConversationDynamoDB(_ conversationId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("removeConversationDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        let awsConversationsTable = AWSConversationsTable()
        let awsConversation = AWSConversation(_userId: identityId, _conversationId: conversationId)
        awsConversationsTable.removeConversation(awsConversation, completionHandler: completionHandler)
    }
    
    func queryUserConversationsDateSortedDynamoDB(_ lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?){
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("queryUserConversationsDateSortedDynamoDB no identityId!")
            return
        }
        let awsConversationsDateSortedIndex = AWSConversationsDateSortedIndex()
        awsConversationsDateSortedIndex.queryUserConversationsDateSorted(identityId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
}
