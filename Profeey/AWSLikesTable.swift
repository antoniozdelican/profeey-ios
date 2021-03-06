//
//  AWSLikesTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 27/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class AWSLikesTable: NSObject, Table {
    
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
        
        return "Likes"
    }
    
    override init() {
        
        model = AWSLike()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            AWSLikesPostIndex(),
        ]
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSLike.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func getLike(_ userId: String, postId: String, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.load(AWSLike.self, hashKey: userId, rangeKey: postId).continue(completionHandler)
    }
    
    func createLike(_ awsLike: AWSLike, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsLike).continue(completionHandler)
    }
    
    func removeLike(_ awsLike: AWSLike, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(awsLike).continue(completionHandler)
    }
}

class AWSLikesPostIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "PostIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // MARK: QueryWithPartitionKey
    
    // Query paginated likes with postId.
    func queryLikes(_ postId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "PostIndex"
        queryExpression.keyConditionExpression = "#postId = :postId"
        queryExpression.expressionAttributeNames = ["#postId": "postId",]
        queryExpression.expressionAttributeValues = [":postId": postId,]
        queryExpression.limit = 10
        queryExpression.exclusiveStartKey = lastEvaluatedKey
        
        objectMapper.query(AWSLike.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
