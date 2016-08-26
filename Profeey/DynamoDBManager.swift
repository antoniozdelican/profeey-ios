//
//  DynamoDBManager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 03/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper

protocol DynamoDBManager {
    
    // MARK: Users
    
    func getUserDynamoDB(userId: String, completionHandler: AWSContinuationBlock)
    func getCurrentUserDynamoDB(completionHandler: AWSContinuationBlock)
    
    func updateFirstLastNameDynamoDB(firstName: String?, lastName: String?, completionHandler: AWSContinuationBlock)
    func updatePreferredUsernameDynamoDB(preferredUsername: String?, completionHandler: AWSContinuationBlock)
    func updateUserProfessionDynamoDB(profession: String?, completionHandler: AWSContinuationBlock)
    func updateUserLocationDynamoDB(location: String?, completionHandler: AWSContinuationBlock)
    func updateUserAboutDynamoDB(about: String?, completionHandler: AWSContinuationBlock)
    func updateProfilePicDynamoDB(profilePicUrl: String?, completionHandler: AWSContinuationBlock)
    
    func scanUsersDynamoDB(completionHandler: AWSContinuationBlock)
    func getUserRelationshipDynamoDB(followedId: String, completionHandler: AWSContinuationBlock)
    func saveUserRelationshipDynamoDB(followedId: String, completionHandler: AWSContinuationBlock)
    func removeUserRelationshipDynamoDB(followedId: String, completionHandler: AWSContinuationBlock)
    
    // MARK: Posts
    
    func queryUserPostsDynamoDB(userId: String, completionHandler: AWSContinuationBlock)
    func savePostDynamoDB(imageUrl: String?, title: String?, description: String?, category: String?, completionHandler: AWSContinuationBlock)
}