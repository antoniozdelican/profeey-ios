//
//  AWSProfessionsTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
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
        if (model.classForCoder.respondsToSelector("rangeKeyAttribute")) {
            sortKeyName = model.classForCoder.rangeKeyAttribute!()
        }
        super.init()
    }
    
    /**
     * Converts the attribute name from data object format to table format.
     *
     * - parameter dataObjectAttributeName: data object attribute name
     * - returns: table attribute name
     */
    
    func tableAttributeName(dataObjectAttributeName: String) -> String {
        return AWSProfession.JSONKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    /**
     * Used for dynamic search of professions.
     *
     */
    
    func scanProfessions(professionsName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 5
        
        scanExpression.filterExpression = "begins_with(#professionName, :professionName)"
        scanExpression.expressionAttributeNames = ["#professionName": "professionName"]
        scanExpression.expressionAttributeValues = [":professionName": "\(professionsName)"]
        
        objectMapper.scan(AWSProfession.self, expression: scanExpression, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(response: response, error: error)
                print("MY RESPONSE: \(response)")
            })
        })
    }
}
