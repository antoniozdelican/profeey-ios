//
//  AWSUserCategoriesTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 16/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSUserCategoriesTable: NSObject, Table {
    
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
        
        return "UserCategories"
    }
    
    override init() {
        
        model = AWSUserCategory()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            
            AWSUserCategoriesPrimaryIndex(),
            
            AWSUserCategoriesNumberOfPostsIndex(),
            
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(dataObjectAttributeName: String) -> String {
        return AWSUserCategory.JSONKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
}

class AWSUserCategoriesPrimaryIndex: NSObject, Index {
    
    var indexName: String? {
        return nil
    }
    
    func supportedOperations() -> [String] {
        return [
        ]
    }
}

// Query all user categories order by numberOfPosts.
class AWSUserCategoriesNumberOfPostsIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "NumberOfPostsIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // MARK: QueryWithPartitionKey
    
    // Query all user categories (skills) with userId and ordered by numberOfPosts.
    func queryUserCategoriesNumberOfPostsSorted(userId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "NumberOfPostsIndex"
        queryExpression.keyConditionExpression = "#userId = :userId AND #numberOfPosts > :numberOfPosts"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
            "#numberOfPosts": "numberOfPosts",
        ]
        
        let numberOfPosts: NSNumber = 0
        
        queryExpression.expressionAttributeValues = [
            ":userId": userId,
            ":numberOfPosts": numberOfPosts,
        ]
        
        // Set desc ordering.
        queryExpression.scanIndexForward = false
        
        queryExpression.limit = 10
        
        objectMapper.query(AWSUserCategory.self, expression: queryExpression, completionHandler: completionHandler)
    }
}