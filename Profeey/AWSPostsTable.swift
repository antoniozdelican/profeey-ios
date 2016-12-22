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
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSPost.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func getPost(_ userId: String, postId: String, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.load(AWSPost.self, hashKey: userId, rangeKey: postId).continue(completionHandler)
    }
    
    func savePost(_ awsPost: AWSPost, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsPost).continue(completionHandler)
    }
    
    func removePost(_ awsPost: AWSPost, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(awsPost).continue(completionHandler)
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
    func queryUserPosts(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId": userId,]
        
        objectMapper.query(AWSPost.self, expression: queryExpression, completionHandler: completionHandler)
    }
}

// TODO: refactor
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
    func queryUserPostsDateSorted(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "DateSortedIndex"
        queryExpression.keyConditionExpression = "#userId = :userId AND #creationDate <= :creationDate"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
            "#creationDate": "creationDate",
        ]
        
        let currentDateNumber = NSNumber(value: Date().timeIntervalSince1970 as Double)
        
        queryExpression.expressionAttributeValues = [
            ":userId": userId,
            ":creationDate": currentDateNumber,
        ]
        // Set desc ordering.
        queryExpression.scanIndexForward = false
        
        objectMapper.query(AWSPost.self, expression: queryExpression, completionHandler: completionHandler)
    }
    
    func queryUserPostsDateSortedWithCategoryName(_ userId: String, categoryName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "DateSortedIndex"
        queryExpression.keyConditionExpression = "#userId = :userId AND #creationDate <= :creationDate"
        queryExpression.filterExpression = "#categoryName = :categoryName"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
            "#creationDate": "creationDate",
            "#categoryName": "categoryName",
        ]
        let currentDateNumber = NSNumber(value: Date().timeIntervalSince1970 as Double)
        queryExpression.expressionAttributeValues = [
            ":userId": userId,
            ":creationDate": currentDateNumber,
            ":categoryName": categoryName,
        ]
        queryExpression.scanIndexForward = false
        
        objectMapper.query(AWSPost.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
