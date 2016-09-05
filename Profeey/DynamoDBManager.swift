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
    
    func updateFirstLastNameDynamoDB(firstName: String?, lastName: String?, completionHandler: AWSContinuationBlock)
    func updatePreferredUsernameDynamoDB(preferredUsername: String?, completionHandler: AWSContinuationBlock)
    func updateProfessionDynamoDB(profession: String?, completionHandler: AWSContinuationBlock)
    func updateLocationDynamoDB(location: String?, completionHandler: AWSContinuationBlock)
    func updateAboutDynamoDB(about: String?, completionHandler: AWSContinuationBlock)
    func updateProfilePicDynamoDB(profilePicUrl: String?, completionHandler: AWSContinuationBlock)
    
    func scanUsersDynamoDB(completionHandler: AWSContinuationBlock)
    
    // MARK: UserRelationships
    
    func getUserRelationshipDynamoDB(followingId: String, completionHandler: AWSContinuationBlock)
    func saveUserRelationshipDynamoDB(followingId: String, followingFirstName: String?, followingLastName: String?, followingPreferredUsername: String?, followingProfession: String?, followingProfilePicUrl: String?, numberOfNewPosts: NSNumber?, completionHandler: AWSContinuationBlock)
    func removeUserRelationshipDynamoDB(followingId: String, completionHandler: AWSContinuationBlock)
    func queryUserFollowingDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    // MARK: Likes
    func getLikeDynamoDB(postId: String, completionHandler: AWSContinuationBlock)
    func saveLikeDynamoDB(postId: String, completionHandler: AWSContinuationBlock)
    func removeLikeDynamoDB(postId: String, completionHandler: AWSContinuationBlock)
    func queryPostLikersDynamoDB(postId: String, completionHandler: AWSContinuationBlock)
    
    // MARK: Posts
    
    func queryUserPostsDateSortedDynamoDB(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    func savePostDynamoDB(imageUrl: String?, title: String?, description: String?, category: String?, user: User?, completionHandler: AWSContinuationBlock)
    
    func scanFollowedPosts(followedIds: [String], completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
}