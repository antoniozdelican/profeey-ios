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
        objectMapper.scan(AWSUser.self, expression: scanExpression, completionHandler: completionHandler)
    }

    func getUser(_ userId: String, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.load(AWSUser.self, hashKey: userId, rangeKey: nil).continue(completionHandler)
    }
    
    func saveUser(_ awsUserUpdate: AWSUserUpdate, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsUserUpdate).continue(completionHandler)
    }
    
    // Skip null attributes (landing flow)
    func saveUserSkipNull(_ awsUser: AWSUser, completionHandler: @escaping AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let updateMapperConfig = AWSDynamoDBObjectMapperConfiguration()
        updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehavior.updateSkipNullAttributes
        objectMapper.save(awsUser, configuration: updateMapperConfig).continue(completionHandler)
    }
}

class AWSUsersPreferredUsernameIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "PreferredUsernameIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // MARK: QueryWithPartitionKeyAndSortKey
    
    // Get preferredUsername(s). This is used to check if preferredUsername is available.
    func queryPreferredUsernames(_ preferredUsername: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "PreferredUsernameIndex"
        queryExpression.keyConditionExpression = "#preferredUsername = :preferredUsername"
        queryExpression.expressionAttributeNames = ["#preferredUsername": "preferredUsername",]
        queryExpression.expressionAttributeValues = [":preferredUsername": preferredUsername,]
        queryExpression.projectionExpression = "#preferredUsername"
        objectMapper.query(AWSUser.self, expression: queryExpression, completionHandler: completionHandler)
    }

}

class AWSUsersLocationIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "LocationIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
        ]
    }
    
    // MARK: QueryWithPartitionKey
    
    // Query all users with locationId.
    func queryLocationUsers(_ locationId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "LocationIndex"
        queryExpression.keyConditionExpression = "#locationId = :locationId"
        queryExpression.expressionAttributeNames = ["#locationId": "locationId",]
        queryExpression.expressionAttributeValues = [":locationId": locationId,]
        objectMapper.query(AWSUser.self, expression: queryExpression, completionHandler: completionHandler)
    }
}

class AWSUsersProfessionIndex: NSObject, Index {
    
    var indexName: String? {
        
        return "ProfessionIndex"
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
            QueryWithPartitionKeyAndFilter
        ]
    }
    
    // MARK: QueryWithPartitionKey and QueryWithPartitionKeyAndFilter
    
    // Query all users with professionName (and locationId if provided).
    func queryProfessionUsers(_ professionName: String, locationId: String?, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "ProfessionIndex"
        queryExpression.keyConditionExpression = "#professionName = :professionName"
        queryExpression.expressionAttributeNames = ["#professionName": "professionName"]
        queryExpression.expressionAttributeValues = [":professionName": professionName]
        
        if let locationId = locationId {
            queryExpression.filterExpression = "#locationId = :locationId"
            queryExpression.expressionAttributeNames?["#locationId"] = "locationId"
            queryExpression.expressionAttributeValues?[":locationId"] = locationId
        }
        
        objectMapper.query(AWSUser.self, expression: queryExpression, completionHandler: completionHandler)
    }
    
    
}
