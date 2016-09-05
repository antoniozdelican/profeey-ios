//
//  AWSFeaturedCategoriesTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 05/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSFeaturedCategoriesTable: NSObject, Table {
    
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
        
        return "FeaturedCategories"
    }
    
    override init() {
        
        model = AWSFeaturedCategory()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            
            AWSUserRelationshipsPrimaryIndex(),
            
            AWSUserRelationshipsFollowersIndex(),
            
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        sortKeyType = "String"
        super.init()
    }
    
    func tableAttributeName(dataObjectAttributeName: String) -> String {
        return AWSFeaturedCategory.JSONKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    // Scan all (10 at most) featured categories.
    func scanFeaturedCategories(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 10
        
        objectMapper.scan(AWSFeaturedCategory.self, expression: scanExpression, completionHandler: completionHandler)
    }
}