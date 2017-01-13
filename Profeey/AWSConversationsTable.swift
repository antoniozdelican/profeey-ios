//
//  AWSConversationsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSConversationsTable: NSObject, Table {
    
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
        
        return "Conversations"
    }
    
    override init() {
        
        model = AWSConversation()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            AWSConversationsDateSortedIndex(),
        ]
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSConversation.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    /*
     IMPORTANT!
     Get/create/remove are called only when first/last message is created between users.
    */
    
    func getConversation(_ userId: String, conversationId: String, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.load(AWSConversation.self, hashKey: userId, rangeKey: conversationId).continue(completionHandler)
    }
    
    func createConversation(_ awsConversation: AWSConversation, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsConversation).continue(completionHandler)
    }
    
    func removeConversation(_ awsConversation: AWSConversation, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(awsConversation).continue(completionHandler)
    }
}

class AWSConversationsDateSortedIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "DateSortedIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKeyAndSortKey,
        ]
    }
    
    // MARK: QueryWithPartitionKeyAndSortKey
    
    // Query paginated conversations with userId and lastMessageCreated <= currentDate.
    func queryUserConversationsDateSorted(_ userId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "DateSortedIndex"
        queryExpression.keyConditionExpression = "#userId = :userId AND #lastMessageCreated <= :lastMessageCreated"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
            "#lastMessageCreated": "lastMessageCreated",
        ]
        queryExpression.expressionAttributeValues = [
            ":userId": userId,
            ":lastMessageCreated": NSNumber(value: Date().timeIntervalSince1970 as Double),
        ]
        queryExpression.scanIndexForward = false
        queryExpression.limit = 10
        queryExpression.exclusiveStartKey = lastEvaluatedKey
        
        objectMapper.query(AWSConversation.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
