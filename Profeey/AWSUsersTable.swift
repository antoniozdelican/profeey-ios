//
//  AWSUsersTable.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class AWSUsersTable: NSObject, Table {
    
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
        
        return "Users"
    }
    
    override init() {
        
        self.model = AWSUser()
        
        self.tableName = model.classForCoder.dynamoDBTableName()
        self.partitionKeyName = model.classForCoder.hashKeyAttribute()
        self.partitionKeyType = "String"
        self.indexes = [
        ]
        //sortKeyName = model.classForCoder.rangeKeyAttribute!()
        super.init()
    }
    
    func tableAttributeName(dataObjectAttributeName: String) -> String {
        return AWSUser.JSONKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    // Scan all (upto 10) users in the Users table.
    func scanUsers(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 10
        objectMapper.scan(AWSUser.self, expression: scanExpression, completionHandler: completionHandler)
    }
    
    func scanUsersByFirstLastName(searchFirstName: String, searchLastName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "begins_with(#searchFirstName, :searchFirstName) OR begins_with(#searchLastName, :searchLastName)"
        scanExpression.expressionAttributeNames = [
            "#searchFirstName": "searchFirstName",
            "#searchLastName": "searchLastName",
        ]
        scanExpression.expressionAttributeValues = [
            ":searchFirstName": searchFirstName,
            ":searchLastName": searchLastName,
        ]
        scanExpression.limit = 10
        objectMapper.scan(AWSUser.self, expression: scanExpression, completionHandler: completionHandler)
    }
    
    // Find a user with userId.
    func getUser(userId: String, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.load(AWSUser.self, hashKey: userId, rangeKey: nil).continueWithBlock(completionHandler)
    }
    
    func saveUser(user: AWSUser, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.save(user).continueWithBlock(completionHandler)
    }
    
    // Skip null attributes (landing flow)
    func saveUserSkipNull(user: AWSUser, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        let updateMapperConfig = AWSDynamoDBObjectMapperConfiguration()
        updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehavior.UpdateSkipNullAttributes
        
        objectMapper.save(user, configuration: updateMapperConfig).continueWithBlock(completionHandler)
    }
}
