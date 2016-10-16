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
    
    func getCurrentUserDynamoDB(_ completionHandler: @escaping AWSContinuationBlock)
    func getUserDynamoDB(_ userId: String, completionHandler: @escaping AWSContinuationBlock)
    
    func createUserDynamoDB(_ email: String, firstName: String, lastName: String, completionHandler: @escaping AWSContinuationBlock)
    func saveUserPreferredUsernameAndProfilePicDynamoDB(_ preferredUsername: String, profilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock)
    func saveUserProfessionDynamoDB(_ professionName: String, completionHandler: @escaping AWSContinuationBlock)
    
    func saveUserDynamoDB(_ user: User?, completionHandler: @escaping AWSContinuationBlock)
    
    func scanUsersDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func scanUsersByNameDynamoDB(_ searchFirstName: String, searchLastName: String, searchPreferredUsername: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: UserRelationships
    
    func getUserRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock)
    func saveUserRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock)
    func removeUserRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryUserFollowersDynamoDB(_ followingId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Likes
    
    func getLikeDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock)
    func saveLikeDynamoDB(_ postId: String, postUserId: String, completionHandler: @escaping AWSContinuationBlock)
    func removeLikeDynamoDB(_ postId: String, postUserId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryPostLikersDynamoDB(_ postId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Posts
    
    func queryUserPostsDateSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryCategoryPostsDateSortedDynamoDB(_ categoryName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func createPostDynamoDB(_ imageUrl: String?, caption: String?, categoryName: String?, completionHandler: @escaping AWSContinuationBlock)
    func updatePostDynamoDB(_ post: Post?, completionHandler: @escaping AWSContinuationBlock)
    func removePostDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock)
    
    // MARK: Categories
    
    func scanCategoriesDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func scanCategoriesByCategoryNameDynamoDB(_ searchCategoryName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Professions
    
    func scanProfessionsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func scanProfessionsByProfessionNameDynamoDB(_ searchProfessionName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Activities
    
    func queryUserActivitiesDateSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: UserCategories
    
    func queryUserCategoriesNumberOfPostsSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: UserExperiences
    
    func queryUserExperiencesDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func saveUserExperienceDynamoDB(_ experienceId: String?, position: String?, organization: String?, fromDate: NSNumber?, toDate: NSNumber?, experienceType: NSNumber?, completionHandler: @escaping AWSContinuationBlock)
    func removeUserExperienceDynamoDB(_ experienceId: String, completionHandler: @escaping AWSContinuationBlock)
}
