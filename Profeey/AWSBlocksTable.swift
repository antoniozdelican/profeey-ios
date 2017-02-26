//
//  AWSBlocksTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSBlocksTable: NSObject, Table {
    
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
        
        return "Blocks"
    }
    
    override init() {
        
        model = AWSBlock()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            
            AWSBlocksBlockingIdIndex(),
            
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSBlock.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    // Find if user with userId is blocking user with blockingId.
    func getBlock(_ userId: String, blockingId: String, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.load(AWSBlock.self, hashKey: userId, rangeKey: blockingId).continue(completionHandler)
        
    }
    
    func createBlock(_ awsBlock: AWSBlock, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsBlock).continue(completionHandler)
    }
    
    func removeBlock(_ awsBlock: AWSBlock, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(awsBlock).continue(completionHandler)
    }
}

class AWSBlocksBlockingIdIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "BlockingIdIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKeyAndSortKey,
        ]
    }
    
    // MARK: QueryWithPartitionKeyAndSortKey
    
    // Find if user with blockingId (identityId) has been blocked by user with userId.
    func getAmIBlocked(_ blockingId: String, userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "BlockingIdIndex"
        queryExpression.keyConditionExpression = "#blockingId = :blockingId AND #userId = :userId"
        queryExpression.expressionAttributeNames = [
            "#blockingId": "blockingId",
            "#userId": "userId",
        ]
        queryExpression.expressionAttributeValues = [
            ":blockingId": blockingId,
            ":userId": userId,
        ]
        queryExpression.projectionExpression = "blockingId, userId"
        objectMapper.query(AWSBlock.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
