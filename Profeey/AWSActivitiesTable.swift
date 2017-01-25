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
    
    // Query paginated activities with userId and created <= currentDate.
    func queryUserActivitiesDateSorted(_ userId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "DateSortedIndex"
        queryExpression.keyConditionExpression = "#userId = :userId AND #created <= :created"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
            "#created": "created",
        ]
        queryExpression.expressionAttributeValues = [
            ":userId": userId,
            ":created": NSNumber(value: Date().timeIntervalSince1970 as Double),
        ]
        queryExpression.scanIndexForward = false
        queryExpression.limit = 5
        queryExpression.exclusiveStartKey = lastEvaluatedKey
        
        objectMapper.query(AWSActivity.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
