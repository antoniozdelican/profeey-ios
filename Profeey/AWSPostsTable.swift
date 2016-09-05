//
//  AWSPostsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class AWSPostsTable: NSObject, Table {
    
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
        
        return "Posts"
    }
    
    override init() {
        
        model = AWSPost()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            
            AWSPostsPrimaryIndex(),
            
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(dataObjectAttributeName: String) -> String {
        return AWSPost.JSONKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func savePost(post: AWSPost, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.save(post).continueWithBlock(completionHandler)
    }
    
    // Find 10 posts from followed users.
    func scanFollowedPosts(followedIds: [String], completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let scanExpression = AWSDynamoDBScanExpression()
        
//        scanExpression.filterExpression = "#userId IN (:followedIds)"
//        scanExpression.expressionAttributeNames = ["#userId": "userId",]
//        scanExpression.expressionAttributeValues = [":followedIds": "us-east-1:d513bfe7-e05a-4006-95fd-d90649aec20c" ,]
        
        scanExpression.limit = 10
        
        objectMapper.scan(AWSPost.self, expression: scanExpression, completionHandler: completionHandler)
        
    }
}

class AWSPostsPrimaryIndex: NSObject, Index {
    
    var indexName: String? {
        return nil
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // Mark: QueryWithPartitionKey
    
    // Find all posts with userId.
    func queryUserPosts(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId": userId,]
        
        objectMapper.query(AWSPost.self, expression: queryExpression, completionHandler: completionHandler)
    }
}

class AWsPostsDateSortedIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "DateSortedIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKeyAndSortKey,
        ]
    }
    
    // MARK: QueryWithPartitionKeyAndSortKey
    
    // Find all posts with userId and creationDate <= currentDate.
    func queryUserPostsDateSorted(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "DateSortedIndex"
        queryExpression.keyConditionExpression = "#userId = :userId AND #creationDate <= :creationDate"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
            "#creationDate": "creationDate",
        ]
        
        let currentDateNumber = NSNumber(double: NSDate().timeIntervalSince1970)
        
        queryExpression.expressionAttributeValues = [
            ":userId": userId,
            ":creationDate": currentDateNumber,
        ]
        
        // Set desc ordering.
        queryExpression.scanIndexForward = false
        
        objectMapper.query(AWSPost.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
