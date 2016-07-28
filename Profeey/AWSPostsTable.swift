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
            
            AWSPostsDateSorted(),
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    /**
     * Converts the attribute name from data object format to table format.
     *
     * - parameter dataObjectAttributeName: data object attribute name
     * - returns: table attribute name
     */
    
    func tableAttributeName(dataObjectAttributeName: String) -> String {
        return AWSPost.JSONKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func savePost(post: AWSDynamoDBObjectModel, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let post = post as! AWSPost
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
            QueryWithPartitionKeyAndFilter,
            QueryWithPartitionKeyAndSortKey,
            QueryWithPartitionKeyAndSortKeyAndFilter,
        ]
    }
    
    // Mark: QueryWithPartitionKey
    
    func queryPostsWithPartitionKeyDescription() -> String {
        return "Find all items with userId = \(AWSIdentityManager.defaultIdentityManager().identityId!)."
    }
    
    func queryAllUserPosts(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId": userId,]
        
        objectMapper.query(AWSPost.self, expression: queryExpression, completionHandler: completionHandler)
    }
}

class AWSPostsDateSorted: NSObject, Index {
    
    var indexName: String? {
        
        return "DateSorted"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
            QueryWithPartitionKeyAndFilter,
            QueryWithPartitionKeyAndSortKey,
            QueryWithPartitionKeyAndSortKeyAndFilter,
        ]
    }
    
    func queryWithPartitionKeyDescription() -> String {
        return "Find all items with userId = \(AWSIdentityManager.defaultIdentityManager().identityId!)."
    }
}
