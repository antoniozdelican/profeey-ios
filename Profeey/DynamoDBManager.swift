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
    
    func updateCurrentUserLocal(_ firstName: String?, lastName: String?, preferredUsername: String?, professionName: String?, profilePicUrl: String?, locationId: String?, locationName: String?, profilePic: UIImage?)
    
    // MARK: Users
    
    func getCurrentUserDynamoDB(_ completionHandler: @escaping AWSContinuationBlock)
    func getUserDynamoDB(_ userId: String, completionHandler: @escaping AWSContinuationBlock)
    
    func createUserDynamoDB(_ email: String, firstName: String, lastName: String, completionHandler: @escaping AWSContinuationBlock)
    func updateUserPreferredUsernameAndProfilePicDynamoDB(_ preferredUsername: String, profilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock)
    func updateUserProfessionDynamoDB(_ professionName: String, completionHandler: @escaping AWSContinuationBlock)
    func updateUserDynamoDB(_ firstName: String?, lastName: String?, professionName: String?, profilePicUrl: String?, about: String?, locationId: String?, locationName: String?, website: String?, completionHandler: @escaping AWSContinuationBlock)
    
    func scanUsersDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryLocationUsers(_ locationId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryProfessionUsers(_ professionName: String, locationId: String?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    func queryPreferredUsernamesDynamoDB(_ preferredUsername: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Relationships
    
    func getRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock)
    func createRelationshipDynamoDB(_ followingId: String, followingFirstName: String?, followingLastName: String?, followingPreferredUsername: String?, followingProfessionName: String?, followingProfilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock)
    func removeRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryFollowersDynamoDB(_ followingId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryFollowingDynamoDB(_ userId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryFollowingIdsDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Recommendations
    
    func getRecommendationDynamoDB(_ recommendingId: String, completionHandler: @escaping AWSContinuationBlock)
    func createRecommendationDynamoDB(_ recommendingId: String, recommendationText: String, completionHandler: @escaping AWSContinuationBlock)
    func removeRecommendationDynamoDB(_ recommendingId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryRecommendationsDateSortedDynamoDB(_ recommendingId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Likes
    
    func getLikeDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock)
    func createLikeDynamoDB(_ postId: String, postUserId: String, completionHandler: @escaping AWSContinuationBlock)
    func removeLikeDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryPostLikesDynamoDB(_ postId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Comments
    
    // TODO: pagination
    func createCommentDynamoDB(_ postId: String, postUserId: String, commentText: String, completionHandler: @escaping AWSContinuationBlock)
    func removeCommentDynamoDB(_ commentId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryPostCommentsDateSortedDynamoDB(_ postId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Posts
    
    func queryUserPostsDateSortedDynamoDB(_ userId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryUserPostsDateSortedWithCategoryNameDynamoDB(_ userId: String, categoryName: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
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
    
    // MARK: UserEndpoints
    
    func saveUserEndpointDynamoDB(_ endpointARN: String, completionHandler: @escaping AWSContinuationBlock)
    
    // MARK: UserCategories
    
    func queryUserCategoriesNumberOfPostsSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: WorkExperiences
    
    func createWorkExperienceDynamoDB(_ title: String?, organization: String?, workDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock)
    func updateWorkExperienceDynamoDB(_ workExperienceId: String, title: String?, organization: String?, workDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock)
    func removeWorkExperienceDynamoDB(_ workExperienceId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryWorkExperiencesDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Educations
    
    func createEducationDynamoDB(_ school: String?, fieldOfStudy: String?, educationDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock)
    func updateEducationDynamoDB(_ educationId: String, school: String?, fieldOfStudy: String?, educationDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock)
    func removeEducationDynamoDB(_ educationId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryEducationsDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Professions
    
    func scanProfessionsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Categories
    
    func scanCategoriesDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Locations
    
    func scanLocationsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: ProfessionLocations
    
    func queryLocationProfessions(_ locationId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Messages
    
    func createMessageDynamoDB(_ conversationId: String, recipientId: String, messageText: String, messageId: String, created: NSNumber, completionHandler: @escaping AWSContinuationBlock)
    func removeMessageDynamoDB(_ conversationId: String, messageId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryMessagesDateSortedDynamoDB(_ conversationId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func getMessageDynamoDB(_ conversationId: String, messageId: String, completionHandler: @escaping AWSContinuationBlock)
    
    // MARK: Conversations
    
    func createConversationDynamoDB(_ messageText: String, conversationId: String, participantId: String, participantFirstName: String?, participantLastName: String?, participantPreferredUsername: String?, participantProfessionName: String?, participantProfilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock)
    func removeConversationDynamoDB(_ conversationId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryConversationsDateSortedDynamoDB(_ lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func getConversationDynamoDB(_ conversationId: String, completionHandler: @escaping AWSContinuationBlock)
}
