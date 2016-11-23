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

// Query comments of a post.
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
    
    // Query all comments with postId.
    func queryPostCommentsDateSorted(_ postId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        let currentDateNumber = NSNumber(value: Date().timeIntervalSince1970 as Double)
        
        queryExpression.indexName = "PostIndex"
        queryExpression.keyConditionExpression = "#postId = :postId AND #creationDate <= :creationDate"
        queryExpression.expressionAttributeNames = [
            "#postId": "postId",
            "#creationDate": "creationDate",
        ]
        queryExpression.expressionAttributeValues = [
            ":postId": postId,
            ":creationDate": currentDateNumber
        ]
        
        objectMapper.query(AWSComment.self, expression: queryExpression, completionHandler: completionHandler)
    }
}