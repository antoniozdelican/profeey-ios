//
//  AWSProfessionsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSProfessionsTable: NSObject, Table {
    
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
        
        return "Professions"
    }
    
    override init() {
        
        model = AWSProfession()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(dataObjectAttributeName: String) -> String {
        return AWSProfession.JSONKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func scanProfessions(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 10
        objectMapper.scan(AWSProfession.self, expression: scanExpression, completionHandler: completionHandler)
    }
    
    func scanProfessionsByProfessionName(searchProfessionName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "begins_with(#searchProfessionName, :searchProfessionName)"
        scanExpression.expressionAttributeNames = [
            "#searchProfessionName": "searchProfessionName",
        ]
        scanExpression.expressionAttributeValues = [
            ":searchProfessionName": searchProfessionName,
        ]
        scanExpression.limit = 10
        objectMapper.scan(AWSProfession.self, expression: scanExpression, completionHandler: completionHandler)
    }
}
