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
    
    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
        return AWSUser.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func scanUsers(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
//        scanExpression.limit = 10
        objectMapper.scan(AWSUser.self, expression: scanExpression, completionHandler: completionHandler)
    }
    
    func scanUsersByProfessionName(_ searchProfessionName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "begins_with(#searchProfessionName, :searchProfessionName)"
        scanExpression.expressionAttributeNames = [
            "#searchProfessionName": "searchProfessionName",
        ]
        scanExpression.expressionAttributeValues = [
            ":searchProfessionName": searchProfessionName,
        ]
        objectMapper.scan(AWSUser.self, expression: scanExpression, completionHandler: completionHandler)
    }

    func getUser(_ userId: String, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.load(AWSUser.self, hashKey: userId, rangeKey: nil).continue(completionHandler)
    }
    
    func saveUser(_ user: AWSUser?, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(user!).continue(completionHandler)
    }
    
    // Skip null attributes (landing flow)
    func saveUserSkipNull(_ user: AWSUser?, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        let updateMapperConfig = AWSDynamoDBObjectMapperConfiguration()
        updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehavior.updateSkipNullAttributes
        
        objectMapper.save(user!, configuration: updateMapperConfig).continue(completionHandler)
    }
}
