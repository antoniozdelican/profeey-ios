//
//  AWSEndpointUsersTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSEndpointUsersTable: NSObject, Table {
    
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
        
        return "EndpointUsers"
    }
    
    override init() {
        
        model = AWSEndpointUser()
        
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
        return AWSEndpointUser.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func createEndpointUser(_ awsEndpointUser: AWSEndpointUser, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsEndpointUser).continue(completionHandler)
    }
    
    func removeEndpointUser(_ awsEndpointUser: AWSEndpointUser, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(awsEndpointUser).continue(completionHandler)
    }
}
