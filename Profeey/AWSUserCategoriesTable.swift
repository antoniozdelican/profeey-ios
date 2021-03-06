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
            AWSUserCategoriesNumberOfPostsSortedIndex(),
            
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSUserCategory.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
}

class AWSUserCategoriesNumberOfPostsSortedIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "NumberOfPostsSortedIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // MARK: QueryWithPartitionKey
    
    // Query all user categories (skills) with userId and ordered by numberOfPosts.
    func queryUserCategoriesNumberOfPostsSorted(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "NumberOfPostsSortedIndex"
        queryExpression.keyConditionExpression = "#userId = :userId AND #numberOfPosts > :numberOfPosts"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
            "#numberOfPosts": "numberOfPosts",
        ]
        queryExpression.expressionAttributeValues = [
            ":userId": userId,
            ":numberOfPosts": NSNumber(value: 0),
        ]
        queryExpression.scanIndexForward = false
        objectMapper.query(AWSUserCategory.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
