//
//  AWSUserRelationshipsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
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
    
    // Find Item with userId and followedId.
    func getUserRelationship(userId: String, followedId: String, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.load(AWSUserRelationship.self, hashKey: userId, rangeKey: followedId).continueWithBlock(completionHandler)
        
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

// Used to get followed.
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
    
    // Find all items with userId.
    func queryUserFollowed(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId": userId,]
        
        objectMapper.query(AWSUserRelationship.self, expression: queryExpression, completionHandler: completionHandler)
    }
    
    // Mark: QueryWithPartitionKeyAndSortKey
    
//    func queryUserFollowed(userId: String, followedId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
//        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
//        let queryExpression = AWSDynamoDBQueryExpression()
//        
//        queryExpression.keyConditionExpression = "#userId = :userId AND #followedId = :followedId"
//        queryExpression.expressionAttributeNames = [
//            "#userId": "userId",
//            "#followedId": "followedId",
//        ]
//        queryExpression.expressionAttributeValues = [":userId": userId,]
//        queryExpression.expressionAttributeValues = [
//            ":userId": userId,
//            ":followedId": followedId,
//        ]
//        
//        objectMapper.query(AWSUserRelationship.self, expression: queryExpression, completionHandler: completionHandler)
//    }
}

// Used to get followers.
class AWSUserRelationshipsFollowersIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "FollowersIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
            QueryWithPartitionKeyAndSortKey,
        ]
    }
    
    // Find all items with followedId.
    func queryUserFollowers(followedId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "FollowersIndex"
        queryExpression.keyConditionExpression = "#followedId = :followedId"
        queryExpression.expressionAttributeNames = ["#followedId": "followedId",]
        queryExpression.expressionAttributeValues = [":followedId": followedId,]
        
        objectMapper.query(AWSUserRelationship.self, expression: queryExpression, completionHandler: completionHandler)
    }    
}
