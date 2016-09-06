//
//  AWSCategoriesTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 06/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSCategoriesTable: NSObject, Table {
    
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
        
        return "Categories"
    }
    
    override init() {
        
        model = AWSCategory()
        
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
        return AWSCategory.JSONKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func scanCategoriesByCategoryName(searchCategoryName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "begins_with(#searchCategoryName, :searchCategoryName)"
        scanExpression.expressionAttributeNames = [
            "#searchCategoryName": "searchCategoryName",
        ]
        scanExpression.expressionAttributeValues = [
            ":searchCategoryName": searchCategoryName,
        ]
        scanExpression.limit = 10
        objectMapper.scan(AWSCategory.self, expression: scanExpression, completionHandler: completionHandler)
    }
}