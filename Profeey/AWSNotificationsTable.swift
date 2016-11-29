//
//  AWSNotificationsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class AWSNotificationsTable: NSObject, Table {
    
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
        
        return "Notifications"
    }
    
    override init() {
        
        model = AWSNotification()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            
            //            AWSNotificationsPrimaryIndex(),
            
            AWSNotificationsDateSortedIndex(),
            
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSNotification.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
}

class AWSNotificationsDateSortedIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "DateSortedIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKeyAndSortKey,
        ]
    }
    
    // MARK: QueryWithPartitionKeyAndSortKey
    
    // Query all notifications with userId and creationDate <= currentDate.
    func queryUserNotificationsDateSorted(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
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
        queryExpression.scanIndexForward = false
        
        objectMapper.query(AWSNotification.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
