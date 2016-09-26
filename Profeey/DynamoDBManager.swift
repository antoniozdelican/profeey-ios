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

protocol DynamoDBManager {
    
    // MARK: Users
    
    func getCurrentUserDynamoDB(completionHandler: AWSContinuationBlock)
    func getUserDynamoDB(userId: String, completionHandler: AWSContinuationBlock)
    
    func createUserDynamoDB(email: String, firstName: String, lastName: String, completionHandler: AWSContinuationBlock)
    func saveUserPreferredUsernameAndProfilePicDynamoDB(preferredUsername: String, profilePicUrl: String?, completionHandler: AWSContinuationBlock)
    func saveUserProfessionDynamoDB(professionName: String, completionHandler: AWSContinuationBlock)
    
    func saveUserDynamoDB(user: User?, completionHandler: AWSContinuationBlock)
    
    func scanUsersDynamoDB(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    func scanUsersByFirstLastNameDynamoDB(searchFirstName: String, searchLastName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    // MARK: UserRelationships
    
    func getUserRelationshipDynamoDB(followingId: String, completionHandler: AWSContinuationBlock)
    func saveUserRelationshipDynamoDB(followingId: String, follower: User?, completionHandler: AWSContinuationBlock)
    func removeUserRelationshipDynamoDB(followingId: String, completionHandler: AWSContinuationBlock)
    func queryUserFollowersDynamoDB(followingId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    // MARK: Likes
    
    func getLikeDynamoDB(postId: String, completionHandler: AWSContinuationBlock)
    func saveLikeDynamoDB(postId: String, postUserId: String, liker: User?, completionHandler: AWSContinuationBlock)
    func removeLikeDynamoDB(postId: String, postUserId: String, completionHandler: AWSContinuationBlock)
    func queryPostLikersDynamoDB(postId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    // MARK: Posts
    
    func queryUserPostsDateSortedDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    func queryCategoryPostsDateSortedDynamoDB(categoryName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    func savePostDynamoDB(imageUrl: String?, title: String?, description: String?, categoryName: String?, user: User?, completionHandler: AWSContinuationBlock)
    
    // MARK: FeaturedCategories
    
    func scanFeaturedCategoriesDynamoDB(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    // MARK: Categories
    
    func scanCategoriesDynamoDB(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    func scanCategoriesByCategoryNameDynamoDB(searchCategoryName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    // MARK: Professions
    
    func scanProfessionsDynamoDB(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    func scanProfessionsByProfessionNameDynamoDB(searchProfessionName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    // MARK: Activities
    
    func queryUserActivitiesDateSortedDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    // MARK: UserCategories
    
    func queryUserCategoriesNumberOfPostsSortedDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    // MARK: UserExperiences
    
    func queryUserExperiencesDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    func saveUserExperienceDynamoDB(experienceId: String?, position: String?, organization: String?, fromDate: NSNumber?, toDate: NSNumber?, experienceType: NSNumber?, completionHandler: AWSContinuationBlock)
    func removeUserExperienceDynamoDB(experienceId: String, completionHandler: AWSContinuationBlock)
}