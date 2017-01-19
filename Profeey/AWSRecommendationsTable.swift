//
//  AWSRecommendationsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSRecommendationsTable: NSObject, Table {
    
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
        
        return "Recommendations"
    }
    
    override init() {
        
        model = AWSRecommendation()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            
            AWSRecommendationsDateSortedIndex(),
            
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSRecommendation.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    // Find if user with userId is recommendint user with recommendingId.
    func getRecommendation(_ userId: String, recommendingId: String, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.load(AWSRecommendation.self, hashKey: userId, rangeKey: recommendingId).continue(completionHandler)
    }
    
    func createRecommendation(_ awsRecommendation: AWSRecommendation, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsRecommendation).continue(completionHandler)
    }
    
    func removeRecommendation(_ awsRecommendation: AWSRecommendation, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(awsRecommendation).continue(completionHandler)
    }
}

class AWSRecommendationsDateSortedIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "DateSortedIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // MARK: QueryWithPartitionKey
    
    // Query paginated recommendations with postId and created <= currentDate.
    func queryRecommendationsDateSorted(_ recommendingId: String, lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "DateSortedIndex"
        queryExpression.keyConditionExpression = "#recommendingId = :recommendingId AND #created <= :created"
        queryExpression.expressionAttributeNames = [
            "#recommendingId": "recommendingId",
            "#created": "created",
        ]
        queryExpression.expressionAttributeValues = [
            ":recommendingId": recommendingId,
            ":created": NSNumber(value: Date().timeIntervalSince1970 as Double),
        ]
        queryExpression.limit = 10
        queryExpression.scanIndexForward = false
        queryExpression.exclusiveStartKey = lastEvaluatedKey
        
        objectMapper.query(AWSRecommendation.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
