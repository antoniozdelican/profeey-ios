//
//  AWSRelationshipsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 06/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSRelationshipsTable: NSObject, Table {
    
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
        
        return "Relationships"
    }
    
    override init() {
        
        model = AWSRelationship()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            
            AWSRelationshipsPrimaryIndex(),
            
            AWSRelationshipsFollowingIdIndex(),
            
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSRelationship.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    // Find if user with userId is following user with followingId.
    func getRelationship(_ userId: String, followingId: String, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.load(AWSRelationship.self, hashKey: userId, rangeKey: followingId).continue(completionHandler)
        
    }
    
    func createRelationship(_ awsRelationship: AWSRelationship, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsRelationship).continue(completionHandler)
    }
    
    func removeRelationship(_ awsRelationship: AWSRelationship, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(awsRelationship).continue(completionHandler)
    }
}

// Query following users from the user.
class AWSRelationshipsPrimaryIndex: NSObject, Index {
    
    var indexName: String? {
        return nil
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // Mark: QueryWithPartitionKey
    
    // Find all following users.
    func queryFollowing(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId": userId,]
        
        objectMapper.query(AWSRelationship.self, expression: queryExpression, completionHandler: completionHandler)
    }
}

// Query followers of the user.
class AWSRelationshipsFollowingIdIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "FollowingIdIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // MARK: QueryWithPartitionKey
    
    // Find all items with followingId.
    func queryFollowers(_ followingId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "FollowingIdIndex"
        queryExpression.keyConditionExpression = "#followingId = :followingId"
        queryExpression.expressionAttributeNames = ["#followingId": "followingId",]
        queryExpression.expressionAttributeValues = [":followingId": followingId,]
        
        objectMapper.query(AWSRelationship.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
