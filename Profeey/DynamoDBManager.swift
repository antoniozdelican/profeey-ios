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
    
    func getUserDynamoDB(userId: String, completionHandler: AWSContinuationBlock)
    func getCurrentUserDynamoDB(completionHandler: AWSContinuationBlock)
    
    func saveUserDynamoDB(user: User?, completionHandler: AWSContinuationBlock)
    
    func updateFirstLastNameDynamoDB(firstName: String?, lastName: String?, completionHandler: AWSContinuationBlock)
    func updatePreferredUsernameDynamoDB(preferredUsername: String?, completionHandler: AWSContinuationBlock)
    func updateProfessionDynamoDB(profession: String?, completionHandler: AWSContinuationBlock)
    func updateLocationDynamoDB(location: String?, completionHandler: AWSContinuationBlock)
    func updateAboutDynamoDB(about: String?, completionHandler: AWSContinuationBlock)
    func updateProfilePicDynamoDB(profilePicUrl: String?, completionHandler: AWSContinuationBlock)
    
    func scanUsersDynamoDB(completionHandler: AWSContinuationBlock)
    func scanUsersByFirstLastNameDynamoDB(searchFirstName: String, searchLastName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    // MARK: UserRelationships
    
    func getUserRelationshipDynamoDB(followingId: String, completionHandler: AWSContinuationBlock)
    func saveUserRelationshipDynamoDB(followingId: String, following: User?, numberOfNewPosts: NSNumber?, completionHandler: AWSContinuationBlock)
    func removeUserRelationshipDynamoDB(followingId: String, completionHandler: AWSContinuationBlock)
    func queryUserFollowingDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
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
    
    func scanCategoriesByCategoryNameDynamoDB(searchCategoryName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
}