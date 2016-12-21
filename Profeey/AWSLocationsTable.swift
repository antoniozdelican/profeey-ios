//
//  AWSLocationsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSLocationsTable: NSObject, Table {
    
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
        
        return "Locations"
    }
    
    override init() {
        
        model = AWSLocation()
        
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
        return AWSLocation.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func scanLocations(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        objectMapper.scan(AWSLocation.self, expression: scanExpression, completionHandler: completionHandler)
    }
}
