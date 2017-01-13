//
//  AWSMessagesTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSMessagesTable: NSObject, Table {
    
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
        
        return "Messages"
    }
    
    override init() {
        
        model = AWSMessage()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            AWSMessagesDateSortedIndex(),
        ]
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSMessage.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func getMessage(_ conversationId: String, messageId: String, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.load(AWSMessage.self, hashKey: conversationId, rangeKey: messageId).continue(completionHandler)
    }
    
    func createMessage(_ awsMessage: AWSMessage, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsMessage).continue(completionHandler)
    }
    
    func removeMessage(_ awsMessage: AWSMessage, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(awsMessage).continue(completionHandler)
    }
    
}

class AWSMessagesDateSortedIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "DateSortedIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKeyAndSortKey,
        ]
    }
    
    // MARK: QueryWithPartitionKeyAndSortKey
    
    // Query paginated messages with conversationId and created <= currentDate.
    func queryConversationMessagesDateSorted(_ conversationId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "DateSortedIndex"
        queryExpression.keyConditionExpression = "#conversationId = :conversationId AND #created <= :created"
        queryExpression.expressionAttributeNames = [
            "#conversationId": "conversationId",
            "#created": "created",
        ]
        queryExpression.expressionAttributeValues = [
            ":conversationId": conversationId,
            ":created": NSNumber(value: Date().timeIntervalSince1970 as Double),
        ]
        queryExpression.scanIndexForward = false
        queryExpression.limit = 10
        queryExpression.exclusiveStartKey = lastEvaluatedKey
        
        objectMapper.query(AWSMessage.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
