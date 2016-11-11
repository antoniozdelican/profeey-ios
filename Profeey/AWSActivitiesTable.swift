//
//  AWSActivitiesTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 13/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

// Main table for the feed!
class AWSActivitiesTable: NSObject, Table {
    
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
        
        return "Activities"
    }
    
    override init() {
        
        model = AWSActivity()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            
//            AWSActivitiesPrimaryIndex(),
            
            AWSActivitiesDateSortedIndex(),
            
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSActivity.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
}

//class AWSActivitiesPrimaryIndex: NSObject, Index {
//    
//    var indexName: String? {
//        return nil
//    }
//    
//    func supportedOperations() -> [String] {
//        return [
//            QueryWithPartitionKey,
//        ]
//    }
//    
//    // Mark: QueryWithPartitionKey
//    
//    // Query all activities with userId.
//    func queryUserActivities(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
//        let objectMapper = AWSDynamoDBObjectMapper.default()
//        let queryExpression = AWSDynamoDBQueryExpression()
//        queryExpression.keyConditionExpression = "#userId = :userId"
//        queryExpression.expressionAttributeNames = ["#userId": "userId",]
//        queryExpression.expressionAttributeValues = [":userId": userId,]
//    
//        objectMapper.query(AWSActivity.self, expression: queryExpression, completionHandler: completionHandler)
//    }
//}

class AWSActivitiesDateSortedIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "DateSortedIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKeyAndSortKey,
        ]
    }
    
    // MARK: QueryWithPartitionKeyAndSortKey
    
    // Query all activities with userId and creationDate <= currentDate.
    func queryUserActivitiesDateSorted(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
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
        
        objectMapper.query(AWSActivity.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
