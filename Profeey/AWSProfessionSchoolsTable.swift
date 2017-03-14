//
//  AWSProfessionSchoolsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 04/03/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSProfessionSchoolsTable: NSObject, Table {
    
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
        
        return "ProfessionSchools"
    }
    
    override init() {
        
        model = AWSProfessionSchool()
        
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
        return AWSProfessionSchool.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
}

// Query professions from a school.
class AWSProfessionSchoolsSchoolIdIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "SchoolIdIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // MARK: QueryWithPartitionKey
    
    // Query all professions with schoolId.
    func querySchoolProfessions(_ schoolId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "SchoolIdIndex"
        queryExpression.keyConditionExpression = "#schoolId = :schoolId"
        queryExpression.expressionAttributeNames = [
            "#schoolId": "schoolId",
        ]
        queryExpression.expressionAttributeValues = [
            ":schoolId": schoolId,
        ]
        objectMapper.query(AWSProfessionSchool.self, expression: queryExpression, completionHandler: completionHandler)
    }
}
