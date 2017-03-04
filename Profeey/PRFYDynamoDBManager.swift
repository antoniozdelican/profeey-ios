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
    
    func updateCurrentUserLocal(_ firstName: String?, lastName: String?, preferredUsername: String?, professionName: String?, profilePicUrl: String?, schoolId: String?, schoolName: String?, profilePic: UIImage?) {
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
        self.currentUserDynamoDB?.schoolId = schoolId
        self.currentUserDynamoDB?.schoolName = schoolName
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
    
    // Get numberOfPosts for enabling posting recommendations.
    func getUserNumberOfPostsDynamoDB(_ completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("getUserNumberOfPostsDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("getUserNumberOfPostsDynamoDB:")
        let usersTable = AWSUsersTable()
        usersTable.getUserNumberOfPosts(identityId, completionHandler: completionHandler)
    }
    
    // Creates user on landing.
    func createUserDynamoDB(_ email: String, firstName: String, lastName: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createUserDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("createUserDynamoDB:")
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let emailVerified = NSNumber(value: 0)
        let isFacebookUser = NSNumber(value: 0)
        let awsUsersTable = AWSUsersTable()
        let awsUser = AWSUser(_userId: identityId, _created: created, _firstName: firstName, _lastName: lastName, _email: email, _emailVerified: emailVerified, _isFacebookUser: isFacebookUser)
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
    
    // Creates facebookUser on landing.
    func createFacebookUserDynamoDB(_ email: String?, firstName: String?, lastName: String?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createFacebookUserDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("createFacebookUserDynamoDB:")
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        // Email is verified by Facebook if provided.
        let emailVerified = email != nil ? NSNumber(value: 1) : nil
        let isFacebookUser = NSNumber(value: 1)
        let awsUsersTable = AWSUsersTable()
        let awsUser = AWSUser(_userId: identityId, _created: created, _firstName: firstName, _lastName: lastName, _email: email, _emailVerified: emailVerified, _isFacebookUser: isFacebookUser)
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
        print("updateUserPreferredUsernameAndProfilePicDynamoDB:")
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
        print("updateUserProfessionDynamoDB:")
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
    
    // Updates user on edit email.
    func updateUserEmailDynamoDB(_ email: String, emailVerified: NSNumber, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("updateUserEmailDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("saveUserProfessionDynamoDB:")
        let awsUsersTable = AWSUsersTable()
        let awsUser = AWSUser(_userId: identityId, _email: email, _emailVerified: emailVerified)
        awsUsersTable.saveUserSkipNull(awsUser, completionHandler: completionHandler)
    }
    
    func updateUserDynamoDB(_ firstName: String?, lastName: String?, professionName: String?, profilePicUrl: String?, about: String?, schoolId: String?, schoolName: String?, website: String?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("updateUserDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        print("updateUserDynamoDB:")
        let awsUsersTable = AWSUsersTable()
        let awsUserUpdate = AWSUserUpdate(_userId: identityId, _firstName: firstName, _lastName: lastName, _professionName: professionName, _profilePicUrl: profilePicUrl, _about: about, _schoolId: schoolId, _schoolName: schoolName, _website: website)
        awsUsersTable.saveUser(awsUserUpdate, completionHandler: completionHandler)
    }
    
    func scanUsersDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let awsUsersTable = AWSUsersTable()
        awsUsersTable.scanUsers(completionHandler)
    }
    
    func querySchoolUsers(_ schoolId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let awsUsersSchoolIdIndex = AWSUsersSchoolIdIndex()
        awsUsersSchoolIdIndex.querySchoolUsers(schoolId, completionHandler: completionHandler)
    }
    
    func queryProfessionUsers(_ professionName: String, schoolId: String?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let awsUsersProfessionIndex = AWSUsersProfessionIndex()
        awsUsersProfessionIndex.queryProfessionUsers(professionName, schoolId: schoolId, completionHandler: completionHandler)
    }
    
    // Check if preferredUsername already exists in DynamoDB.
    func queryPreferredUsernamesDynamoDB(_ preferredUsername: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryPreferredUsernamesDynamoDB:")
        let awsUsersPreferredUsernameIndex = AWSUsersPreferredUsernameIndex()
        awsUsersPreferredUsernameIndex.queryPreferredUsernames(preferredUsername, completionHandler: completionHandler)
    }
    
    // Check if email already exists in DynamoDB.
    func queryEmailsDynamoDB(_ email: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryEmailsDynamoDB:")
        let awsUsersEmailIndex = AWSUsersEmailIndex()
        awsUsersEmailIndex.queryEmails(email, completionHandler: completionHandler)
    }
    
    // MARK: Relationships
    
    func getRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("getRelationshipDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        let awsRelationshipsTable = AWSRelationshipsTable()
        awsRelationshipsTable.getRelationship(identityId, followingId: followingId, completionHandler: completionHandler)
    }
    
    func createRelationshipDynamoDB(_ followingId: String, followingFirstName: String?, followingLastName: String?, followingPreferredUsername: String?, followingProfessionName: String?, followingProfilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createRelationshipDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
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
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsRecommendationsTable = AWSRecommendationsTable()
        let awsRecommendation = AWSRecommendation(_userId: identityId, _recommendingId: recommendingId, _created: created, _recommendationText: recommendationText, _firstName: self.currentUserDynamoDB?.firstName, _lastName: self.currentUserDynamoDB?.lastName, _preferredUsername: self.currentUserDynamoDB?.preferredUsername, _professionName: self.currentUserDynamoDB?.professionName, _profilePicUrl: self.currentUserDynamoDB?.profilePicUrl)
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
    
    func queryRecommendationsDateSortedDynamoDB(_ recommendingId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryRecommendationsDateSortedDynamoDB:")
        let awsRecommendationsDateSortedIndex = AWSRecommendationsDateSortedIndex()
        awsRecommendationsDateSortedIndex.queryRecommendationsDateSorted(recommendingId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
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
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsLikesTable = AWSLikesTable()
        let awsLike = AWSLike(_userId: identityId, _postId: postId, _created: created, _postUserId: postUserId, _firstName: self.currentUserDynamoDB?.firstName, _lastName: self.currentUserDynamoDB?.lastName, _preferredUsername: self.currentUserDynamoDB?.preferredUsername, _professionName: self.currentUserDynamoDB?.professionName, _profilePicUrl: self.currentUserDynamoDB?.profilePicUrl)
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
    
    func queryLikesDynamoDB(_ postId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryLikesDynamoDB:")
        let awsLikesPostIndex = AWSLikesPostIndex()
        awsLikesPostIndex.queryLikes(postId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    // MARK: Comments
    
    func createCommentDynamoDB(_ commentId: String, created: NSNumber, commentText: String, postId: String, postUserId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createCommentDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
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
    
    func queryCommentsDateSortedDynamoDB(_ postId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let awsCommentsPostIndex = AWSCommentsPostIndex()
        awsCommentsPostIndex.queryCommentsDateSorted(postId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    
    // MARK: Posts
    
    func queryPostsDateSortedDynamoDB(_ userId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryPostsDateSortedDynamoDB:")
        let awsPostsDateSortedIndex = AWSPostsDateSortedIndex()
        awsPostsDateSortedIndex.queryPostsDateSorted(userId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    func queryPostsDateSortedWithCategoryNameDynamoDB(_ userId: String, categoryName: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        print("queryPostsDateSortedWithCategoryNameDynamoDB:")
        let awsPostsDateSortedIndex = AWSPostsDateSortedIndex()
        awsPostsDateSortedIndex.queryPostsDateSortedWithCategoryName(userId, categoryName: categoryName, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
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
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsPostsTable = AWSPostsTable()
        let awsPost = AWSPost(_userId: identityId, _postId: postId, _created: created, _caption: caption, _categoryName: categoryName, _imageUrl: imageUrl, _imageWidth: imageWidth, _imageHeight: imageHeight, _firstName: self.currentUserDynamoDB?.firstName, _lastName: self.currentUserDynamoDB?.lastName, _preferredUsername: self.currentUserDynamoDB?.preferredUsername, _professionName: self.currentUserDynamoDB?.professionName, _profilePicUrl: self.currentUserDynamoDB?.profilePicUrl)
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
    
    func queryNotificationsDateSortedDynamoDB(_ lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("queryNotificationsDateSortedDynamoDB no identityId!")
            return
        }
        let awsNotificationsDateSortedIndex = AWSNotificationsDateSortedIndex()
        awsNotificationsDateSortedIndex.queryNotificationsDateSorted(identityId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    // MARK: NotificationsCounters
    
    func getNotificationsCounterDynamoDB(_ completionHandler: @escaping AWSContinuationBlock){
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("getNotificationsCounterDynamoDB no identityId!")
            return
        }
        let awsNotificationsCountersTable = AWSNotificationsCountersTable()
        awsNotificationsCountersTable.getNotificationsCounter(identityId, completionHandler: completionHandler)
    }
    
    func updateNotificationsCounterDynamoDB(_ completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("updateNotificationsCounterDynamoDB no identityId!")
            return
        }
        let awsNotificationsCountersTable = AWSNotificationsCountersTable()
        let numberOfNewNotifications = NSNumber(value: 0)
        let lastSeenDate = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsNotificationsCounter = AWSNotificationsCounter(_userId: identityId, _numberOfNewNotifications: numberOfNewNotifications, _lastSeenDate: lastSeenDate)
        awsNotificationsCountersTable.updateNotificationsCounter(awsNotificationsCounter, completionHandler: completionHandler)
    }
    
    // MARK: EndpointUsers
    
    func createEndpointUserDynamoDB(_ endpointARN: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createEndpointUserDynamoDB no identityId!")
            return
        }
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsEndpointUsersTable = AWSEndpointUsersTable()
        let awsEndpointUser = AWSEndpointUser(_endpointARN: endpointARN, _userId: identityId, _created: created)
        awsEndpointUsersTable.createEndpointUser(awsEndpointUser, completionHandler: completionHandler)
    }
    
    func removeEndpointUserDynamoDB(_ endpointARN: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("removeEndpointUserDynamoDB no identityId!")
            return
        }
        let awsEndpointUsersTable = AWSEndpointUsersTable()
        let awsEndpointUser = AWSEndpointUser(_endpointARN: endpointARN, _userId: identityId)
        awsEndpointUsersTable.removeEndpointUser(awsEndpointUser, completionHandler: completionHandler)
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
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsWorkExperiencesTable = AWSWorkExperiencesTable()
        let awsWorkExperience = AWSWorkExperience(_userId: identityId, _workExperienceId: workExperienceId, _created: created, _title: title, _organization: organization, _workDescription: workDescription, _fromMonth: fromMonth, _fromYear: fromYear, _toMonth: toMonth, _toYear: toYear)
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
        let awsWorkExperienceUpdate = AWSWorkExperienceUpdate(_userId: identityId, _workExperienceId: workExperienceId, _created: nil, _title: title, _organization: organization, _workDescription: workDescription, _fromMonth: fromMonth, _fromYear: fromYear, _toMonth: toMonth, _toYear: toYear)
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
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsEducationsTable = AWSEducationsTable()
        let awsEducation = AWSEducation(_userId: identityId, _educationId: educationId, _created: created, _school: school, _fieldOfStudy: fieldOfStudy, _educationDescription: educationDescription, _fromMonth: fromMonth, _fromYear: fromYear, _toMonth: toMonth, _toYear: toYear)
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
        let awsEducationUpdate = AWSEducationUpdate(_userId: identityId, _educationId: educationId, _created: nil, _school: school, _fieldOfStudy: fieldOfStudy, _educationDescription: educationDescription, _fromMonth: fromMonth, _fromYear: fromYear, _toMonth: toMonth, _toYear: toYear)
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
    
    // MARK: Schools
    
    func scanSchoolsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let awsSchoolsTable = AWSSchoolsTable()
        awsSchoolsTable.scanSchools(completionHandler)
    }
    
    // MARK: ProfessionSchools
    
    func querySchoolProfessions(_ schoolId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let awsProfessionSchoolsSchoolIdIndex = AWSProfessionSchoolsSchoolIdIndex()
        awsProfessionSchoolsSchoolIdIndex.querySchoolProfessions(schoolId, completionHandler: completionHandler)
    }
    
    // MARK: Messages
    
    func getMessageDynamoDB(_ conversationId: String, messageId: String, completionHandler: @escaping AWSContinuationBlock) {
        let awsMessagesTable = AWSMessagesTable()
        awsMessagesTable.getMessage(conversationId, messageId: messageId, completionHandler: completionHandler)
    }
    
    func createMessageDynamoDB(_ conversationId: String, recipientId: String, messageText: String, messageId: String, created: NSNumber, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createMessageDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        // messageId and created attributes are initialized before creation to simulate real-time.
        let awsMessagesTable = AWSMessagesTable()
        let awsMessage = AWSMessage(_conversationId: conversationId, _messageId: messageId, _created: created, _messageText: messageText, _senderId: identityId, _recipientId: recipientId, _senderPreferredUsername: self.currentUserDynamoDB?.preferredUsername)
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
    
    func queryMessagesDateSortedDynamoDB(_ conversationId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?){
        let awsMessagesDateSortedIndex = AWSMessagesDateSortedIndex()
        awsMessagesDateSortedIndex.queryConversationMessagesDateSorted(conversationId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    // MARK: Conversations
    
    /*
     Create and remove are called (in background) only when first/last message is created between users.
    */
    
    func getConversationDynamoDB(_ conversationId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("getConversationDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        let awsConversationsTable = AWSConversationsTable()
        awsConversationsTable.getConversation(identityId, conversationId: conversationId, completionHandler: completionHandler)
    }
    
    func createConversationDynamoDB(_ messageText: String, conversationId: String, participantId: String, participantFirstName: String?, participantLastName: String?, participantPreferredUsername: String?, participantProfessionName: String?, participantProfilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createConversationDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        // Set lastMessageSeen to true (1) for own new conversation.
        let lastMessageSeen = NSNumber(value: 1)
        let awsConversationsTable = AWSConversationsTable()
        let awsConversation = AWSConversation(_userId: identityId, _conversationId: conversationId, _created: created, _lastMessageText: messageText, _lastMessageCreated: created, _lastMessageSeen: lastMessageSeen, _participantId: participantId, _participantFirstName: participantFirstName, _participantLastName: participantLastName, _participantPreferredUsername: participantPreferredUsername, _participantProfessionName: participantProfessionName, _participantProfilePicUrl: participantProfilePicUrl)
        awsConversationsTable.createConversation(awsConversation, completionHandler: completionHandler)
    }
    
    func updateSeenConversationDynamoDB(_ conversationId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("updateSeenConversationDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        let awsConversationsTable = AWSConversationsTable()
        // Set lastMessageSeen to true (1) for own conversation.
        let lastMessageSeen = NSNumber(value: 1)
        let awsConversation = AWSConversation(_userId: identityId, _conversationId: conversationId, _lastMessageSeen: lastMessageSeen)
        awsConversationsTable.updateConversationSkipNull(awsConversation, completionHandler: completionHandler)
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
    
    func queryConversationsDateSortedDynamoDB(_ lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?){
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("queryUserConversationsDateSortedDynamoDB no identityId!")
            return
        }
        let awsConversationsDateSortedIndex = AWSConversationsDateSortedIndex()
        awsConversationsDateSortedIndex.queryConversationsDateSorted(identityId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: completionHandler)
    }
    
    func queryUnseenConversationsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("queryUnseenConversationsDynamoDB no identityId!")
            return
        }
        let awsConversationsUnseenIndex = AWSConversationsUnseenIndex()
        awsConversationsUnseenIndex.queryUnseenConversations(identityId, completionHandler: completionHandler)
    }
    
    // MARK: Reports
    
    func createReportDynamoDB(_ reportedUserId: String, reportedPostId: String?, reportType: ReportType, reportDetailType: ReportDetailType, completionHandler: @escaping AWSContinuationBlock){
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createReportDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        // Put reportId depending on reportedType aka if it has reportedPostId put it as reportId (so there's no duplicate reports).
        let reportId = reportedPostId != nil ? reportedPostId : reportedUserId
        let awsReportsTable = AWSReportsTable()
        let awsReport = AWSReport(_userId: identityId, _reportId: reportId, _created: created, _reportedUserId: reportedUserId, _reportedPostId: reportedPostId, _reportType: reportType.rawValue, _reportDetailType: reportDetailType.rawValue)
        awsReportsTable.createReport(awsReport, completionHandler: completionHandler)
    }
    
    // MARK: Blocks
    
    func getBlockDynamoDB(_ blockingId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("getBlockDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        let awsBlocksTable = AWSBlocksTable()
        awsBlocksTable.getBlock(identityId, blockingId: blockingId, completionHandler: completionHandler)
    }
    
    func createBlockDynamoDB(_ blockingId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("createBlockDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        let created = NSNumber(value: Date().timeIntervalSince1970 as Double)
        let awsBlocksTable = AWSBlocksTable()
        let awsBlock = AWSBlock(_userId: identityId, _blockingId: blockingId, _created: created)
        awsBlocksTable.createBlock(awsBlock, completionHandler: completionHandler)
    }
    
    func removeBlockDynamoDB(_ blockingId: String, completionHandler: @escaping AWSContinuationBlock) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("removeBlockDynamoDB no identityId!")
            AWSTask().continue(completionHandler)
            return
        }
        let awsBlocksTable = AWSBlocksTable()
        let awsBlock = AWSBlock(_userId: identityId, _blockingId: blockingId)
        awsBlocksTable.removeBlock(awsBlock, completionHandler: completionHandler)
    }
    
    func getAmIBlockedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("getAmIBlockedDynamoDB no identityId!")
            return
        }
        let awsBlocksBlockingIdIndex = AWSBlocksBlockingIdIndex()
        awsBlocksBlockingIdIndex.getAmIBlocked(identityId, userId: userId, completionHandler: completionHandler)
    }
}
