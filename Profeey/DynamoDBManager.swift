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
    func updateUserProfessionsDynamoDB(professions: [String]?, completionHandler: AWSContinuationBlock)
    func updateProfilePicDynamoDB(profilePicUrl: String?, completionHandler: AWSContinuationBlock)
    
    // MARK: Posts
    
    func getUserPostsDynamoDB(userId: String, completionHandler: AWSContinuationBlock)
    func getCurrentUserPostsDynamoDB(completionHandler: AWSContinuationBlock)
    func createPostDynamoDB(imageUrl: String?, title: String?, description: String?, completionHandler: AWSContinuationBlock)
}