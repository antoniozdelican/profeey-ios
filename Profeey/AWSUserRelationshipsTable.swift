//
//  AWSUserRelationshipsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSUserRelationshipsTable: NSObject, Table {
    
    var tableName: String
    var partitionKeyName: String
    var partitionKeyType: String
    var sortKeyName: String?
    var sortKeyType: String?
    var model: AWSDynamoDBObjectModel
    var indexes: [Index]
    var orderedAttributeKeys: [String] {
        return produceOrderedAttributeKeys(model)
    }
    var tableDisplayName: String {
        
        return "UserRelationships"
    }
    
    override init() {
        
        model = AWSPost()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            
            AWSUserRelationshipsPrimaryIndex(),
            
            AWSUserRelationshipsFollowersIndex(),
            
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(dataObjectAttributeName: String) -> String {
        return AWSUserRelationship.JSONKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    // Find if user with userId is following user with followingId.
    func getUserRelationship(userId: String, followingId: String, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.load(AWSUserRelationship.self, hashKey: userId, rangeKey: followingId).continueWithBlock(completionHandler)
        
    }
    
    func saveUserRelationship(userRelationship: AWSUserRelationship, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.save(userRelationship).continueWithBlock(completionHandler)
    }
    
    func removeUserRelationship(userRelationship: AWSUserRelationship, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.remove(userRelationship).continueWithBlock(completionHandler)
    }
}

// Query followed users by the user.
class AWSUserRelationshipsPrimaryIndex: NSObject, Index {
    
    var indexName: String? {
        return nil
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
            QueryWithPartitionKeyAndSortKey,
        ]
    }
    
    // Mark: QueryWithPartitionKey
    
    // Find all following users.
    func queryUserFollowing(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId": userId,]
        
        objectMapper.query(AWSUserRelationship.self, expression: queryExpression, completionHandler: completionHandler)
    }
}

// Query followers of the user.
class AWSUserRelationshipsFollowersIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "FollowersIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // MARK: QueryWithPartitionKey
    
    // Find all items with followingId.
    func queryUserFollowers(followingId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "FollowersIndex"
        queryExpression.keyConditionExpression = "#followingId = :followingId"
        queryExpression.expressionAttributeNames = ["#followingId": "followingId",]
        queryExpression.expressionAttributeValues = [":followingId": followingId,]
        
        objectMapper.query(AWSUserRelationship.self, expression: queryExpression, completionHandler: completionHandler)
    }    
}
