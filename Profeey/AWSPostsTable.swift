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
            
            AWSPostsDateSortedIndex(),
            
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

class AWSPostsDateSortedIndex: NSObject, Index {
    
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

class AWSPostsCategoryNameIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "CategoryNameIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKeyAndSortKey,
        ]
    }
    
    // MARK: QueryWithPartitionKeyAndSortKey
    
    // Find all (upto 10) posts with categoryName and creationDate <= currentDate.
    func queryCategoryPostsDateSorted(categoryName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "CategoryNameIndex"
        queryExpression.keyConditionExpression = "#categoryName = :categoryName AND #creationDate <= :creationDate"
        queryExpression.expressionAttributeNames = [
            "#categoryName": "categoryName",
            "#creationDate": "creationDate",
        ]
        
        let currentDateNumber = NSNumber(double: NSDate().timeIntervalSince1970)
        
        queryExpression.expressionAttributeValues = [
            ":categoryName": categoryName,
            ":creationDate": currentDateNumber,
        ]
        
        // Set desc ordering.
        queryExpression.scanIndexForward = false
        
        queryExpression.limit = 10
        
        objectMapper.query(AWSPost.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
