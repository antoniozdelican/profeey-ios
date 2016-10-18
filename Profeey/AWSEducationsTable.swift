//
//  AWSEducationsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSEducationsTable: NSObject, Table {
    
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
        
        return "Educations"
    }
    
    override init() {
        
        model = AWSEducation()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            AWSEducationsPrimaryIndex(),
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSEducation.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func saveEducation(_ awsEducation: AWSEducation, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsEducation).continue(completionHandler)
    }
    
    func removeEducation(_ awsEducation: AWSEducation, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(awsEducation).continue(completionHandler)
    }
}

class AWSEducationsPrimaryIndex: NSObject, Index {
    
    var indexName: String? {
        return nil
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // Mark: QueryWithPartitionKey
    
    // Query all educations from user.
    func queryEducations(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId": userId,]
        
        objectMapper.query(AWSEducation.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
