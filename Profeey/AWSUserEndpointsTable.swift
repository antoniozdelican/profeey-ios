//
//  AWSUserEndpointsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 01/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class AWSUserEndpointsTable: NSObject, Table {
    
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
        
        return "UserEndpoints"
    }
    
    override init() {
        
        model = AWSUserEndpoint()
        
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
        return AWSUserEndpoint.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func saveUserEndpoint(_ awsUserEndpoint: AWSUserEndpoint, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsUserEndpoint).continue(completionHandler)
    }
}

