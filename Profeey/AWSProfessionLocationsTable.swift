//
//  AWSProfessionLocationsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSProfessionLocationsTable: NSObject, Table {
    
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
        
        return "ProfessionLocations"
    }
    
    override init() {
        
        model = AWSProfessionLocation()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSProfessionLocation.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
}

// Query professions from a location.
class AWSProfessionLocationsLocationIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "LocationIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // MARK: QueryWithPartitionKey
    
    // Query all professions with locationId and numberOfUsers > 0.
    func queryLocationProfessions(_ locationId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "LocationIndex"
        queryExpression.keyConditionExpression = "#locationId = :locationId"
        queryExpression.filterExpression = "#numberOfUsers > :numberOfUsers"
        queryExpression.expressionAttributeNames = [
            "#locationId": "locationId",
            "#numberOfUsers": "numberOfUsers",
        ]
        queryExpression.expressionAttributeValues = [
            ":locationId": locationId,
            ":numberOfUsers": 0,
        ]
        objectMapper.query(AWSProfessionLocation.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
