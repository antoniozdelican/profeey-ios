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
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSUserRelationship.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    // Find if user with userId is following user with followingId.
    func getUserRelationship(_ userId: String, followingId: String, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.load(AWSUserRelationship.self, hashKey: userId, rangeKey: followingId).continue(completionHandler)
        
    }
    
    func saveUserRelationship(_ userRelationship: AWSUserRelationship?, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(userRelationship!).continue(completionHandler)
    }
    
    func removeUserRelationship(_ userRelationship: AWSUserRelationship?, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(userRelationship!).continue(completionHandler)
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
    func queryUserFollowing(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
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
    func queryUserFollowers(_ followingId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "FollowersIndex"
        queryExpression.keyConditionExpression = "#followingId = :followingId"
        queryExpression.expressionAttributeNames = ["#followingId": "followingId",]
        queryExpression.expressionAttributeValues = [":followingId": followingId,]
        
        objectMapper.query(AWSUserRelationship.self, expression: queryExpression, completionHandler: completionHandler)
    }    
}
