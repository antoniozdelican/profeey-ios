//
//  AWSCommentsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 02/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class AWSCommentsTable: NSObject, Table {
    
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
        
        return "Comments"
    }
    
    override init() {
        
        model = AWSComment()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            AWSCommentsPostIndex(),
        ]
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSComment.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func createComment(_ awsComment: AWSComment, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsComment).continue(completionHandler)
    }
    
    func updateComment(_ awsCommentUpdate: AWSCommentUpdate, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsCommentUpdate).continue(completionHandler)
    }
    
    func removeComment(_ awsComment: AWSComment, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(awsComment).continue(completionHandler)
    }
}

class AWSCommentsPostIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "PostIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // MARK: QueryWithPartitionKey
    
    // Query paginated comments with postId and created <= currentDate.
    func queryCommentsDateSorted(_ postId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "PostIndex"
        queryExpression.keyConditionExpression = "#postId = :postId AND #created <= :created"
        queryExpression.expressionAttributeNames = [
            "#postId": "postId",
            "#created": "created",
        ]
        queryExpression.expressionAttributeValues = [
            ":postId": postId,
            ":created": NSNumber(value: Date().timeIntervalSince1970 as Double),
        ]
        queryExpression.limit = 10
        queryExpression.exclusiveStartKey = lastEvaluatedKey
        
        objectMapper.query(AWSComment.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
