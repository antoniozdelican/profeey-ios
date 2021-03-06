//
//  DynamoDBManager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 03/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSDynamoDB

typealias AWSContinuationBlock = (AWSTask<AnyObject>) -> Any?
typealias AWSDynamoDBContinuationBlock = (AWSTask<AWSDynamoDBPaginatedOutput>) -> Any?

protocol DynamoDBManager {
    
    // MARK: CurrentUser
    
    // Special one getting from NSUserDefaults
    func setCurrentUserLocal()
    // Update with fresh DynamoDB data.
    func updateCurrentUserLocal(_ firstName: String?, lastName: String?, preferredUsername: String?, professionName: String?, profilePicUrl: String?, schoolId: String?, schoolName: String?, profilePic: UIImage?)
    
    // MARK: Users
    
    func getCurrentUserDynamoDB(_ completionHandler: @escaping AWSContinuationBlock)
    func getUserDynamoDB(_ userId: String, completionHandler: @escaping AWSContinuationBlock)
    func getUserNumberOfPostsDynamoDB(_ completionHandler: @escaping AWSContinuationBlock)
    
    func createUserDynamoDB(_ email: String, firstName: String, lastName: String, completionHandler: @escaping AWSContinuationBlock)
    func createFacebookUserDynamoDB(_ email: String?, firstName: String?, lastName: String?, completionHandler: @escaping AWSContinuationBlock)
    func updateUserPreferredUsernameAndProfilePicDynamoDB(_ preferredUsername: String, profilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock)
    func updateUserProfessionDynamoDB(_ professionName: String, completionHandler: @escaping AWSContinuationBlock)
    func updateUserSchoolDynamoDB(_ schoolId: String, schoolName: String, completionHandler: @escaping AWSContinuationBlock)
    func updateUserEmailDynamoDB(_ email: String, emailVerified: NSNumber, completionHandler: @escaping AWSContinuationBlock)
    func updateUserDynamoDB(_ firstName: String?, lastName: String?, professionName: String?, profilePicUrl: String?, about: String?, schoolId: String?, schoolName: String?, website: String?, completionHandler: @escaping AWSContinuationBlock)
    
    func scanUsersDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func querySchoolUsers(_ schoolId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryProfessionUsers(_ professionName: String, schoolId: String?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    func queryPreferredUsernamesDynamoDB(_ preferredUsername: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryEmailsDynamoDB(_ email: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Relationships
    
    func getRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock)
    func createRelationshipDynamoDB(_ followingId: String, followingFirstName: String?, followingLastName: String?, followingPreferredUsername: String?, followingProfessionName: String?, followingProfilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock)
    func removeRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryFollowersDynamoDB(_ followingId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryFollowingDynamoDB(_ userId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryFollowingIdsDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Likes
    
    func getLikeDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock)
    func createLikeDynamoDB(_ postId: String, postUserId: String, completionHandler: @escaping AWSContinuationBlock)
    func removeLikeDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryLikesDynamoDB(_ postId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Comments
    
    func createCommentDynamoDB(_ commentId: String, created: NSNumber, commentText: String, postId: String, postUserId: String, completionHandler: @escaping AWSContinuationBlock)
    func removeCommentDynamoDB(_ commentId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryCommentsDateSortedDynamoDB(_ postId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Posts
    
    func queryPostsDateSortedDynamoDB(_ userId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryPostsDateSortedWithCategoryNameDynamoDB(_ userId: String, categoryName: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func getPostDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock)
    func createPostDynamoDB(_ imageUrl: String?, imageWidth: NSNumber?, imageHeight: NSNumber?, caption: String?, categoryName: String?, completionHandler: @escaping AWSContinuationBlock)
    func updatePostDynamoDB(_ postId: String, caption: String?, categoryName: String?, completionHandler: @escaping AWSContinuationBlock)
    func removePostDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock)
    
    // MARK: Activities
    
    func queryUserActivitiesDateSortedDynamoDB(_ lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Notifications
    
    func queryNotificationsDateSortedDynamoDB(_ lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: NotificationsCounters
    
    func getNotificationsCounterDynamoDB(_ completionHandler: @escaping AWSContinuationBlock)
    func updateNotificationsCounterDynamoDB(_ completionHandler: @escaping AWSContinuationBlock)
    
    // MARK: EndpointUsers
    
    func createEndpointUserDynamoDB(_ endpointARN: String, completionHandler: @escaping AWSContinuationBlock)
    func removeEndpointUserDynamoDB(_ endpointARN: String, completionHandler: @escaping AWSContinuationBlock)
    
    // MARK: UserCategories
    
    func queryUserCategoriesNumberOfPostsSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Professions
    
    func scanProfessionsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Categories
    
    func scanCategoriesDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Schools
    
    func scanSchoolsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: ProfessionSchools
    
    func querySchoolProfessions(_ schoolId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Messages
    
    func getMessageDynamoDB(_ conversationId: String, messageId: String, completionHandler: @escaping AWSContinuationBlock)
    func createMessageDynamoDB(_ conversationId: String, recipientId: String, messageText: String, messageId: String, created: NSNumber, completionHandler: @escaping AWSContinuationBlock)
    func removeMessageDynamoDB(_ conversationId: String, messageId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryMessagesDateSortedDynamoDB(_ conversationId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Conversations
    
    func getConversationDynamoDB(_ conversationId: String, completionHandler: @escaping AWSContinuationBlock)
    func createConversationDynamoDB(_ messageText: String, conversationId: String, participantId: String, participantFirstName: String?, participantLastName: String?, participantPreferredUsername: String?, participantProfessionName: String?, participantProfilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock)
    func updateSeenConversationDynamoDB(_ conversationId: String, completionHandler: @escaping AWSContinuationBlock)
    //func removeConversationDynamoDB(_ conversationId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryConversationsDateSortedDynamoDB(_ lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryUnseenConversationsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Reports
    
    func createReportDynamoDB(_ reportedUserId: String, reportedPostId: String?, reportType: ReportType, reportDetailType: ReportDetailType, completionHandler: @escaping AWSContinuationBlock)
    
    // MARK: Blocks
    
    func getBlockDynamoDB(_ blockingId: String, completionHandler: @escaping AWSContinuationBlock)
    func createBlockDynamoDB(_ blockingId: String, completionHandler: @escaping AWSContinuationBlock)
    func removeBlockDynamoDB(_ blockingId: String, completionHandler: @escaping AWSContinuationBlock)
    func getAmIBlockedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
}
