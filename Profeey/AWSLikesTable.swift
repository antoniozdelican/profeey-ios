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
            
            AWSLikesPrimaryIndex(),
            
            AWSLikesPostIndex(),
        ]
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(dataObjectAttributeName: String) -> String {
        return AWSUserRelationship.JSONKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    // Find Like with userId and postId.
    func getLike(userId: String, postId: String, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.load(AWSLike.self, hashKey: userId, rangeKey: postId).continueWithBlock(completionHandler)
        
    }
    
    // Save Like.
    func saveLike(like: AWSLike, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.save(like).continueWithBlock(completionHandler)
    }
    
    // Remove Like.
    func removeLike(like: AWSLike, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.remove(like).continueWithBlock(completionHandler)
    }
}

class AWSLikesPrimaryIndex: NSObject, Index {
    
    var indexName: String? {
        return nil
    }
    
    func supportedOperations() -> [String] {
        return [
        ]
    }
}

// Query likers of a post.
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
    
    // Find all likes with postId.
    func queryPostLikers(postId: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "LikesIndex"
        queryExpression.keyConditionExpression = "#postId = :postId"
        queryExpression.expressionAttributeNames = ["#postId": "postId",]
        queryExpression.expressionAttributeValues = [":postId": postId,]
        
        objectMapper.query(AWSLike.self, expression: queryExpression, completionHandler: completionHandler)
    }
}