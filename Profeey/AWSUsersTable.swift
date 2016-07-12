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
        return AWSUser.JSONKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func getUser(completionHandler: (response: AWSDynamoDBObjectModel?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.load(AWSUser.self, hashKey: AWSRemoteService.defaultRemoteService().identityId, rangeKey: nil, completionHandler: {
            (response: AWSDynamoDBObjectModel?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(response: response, error: error)
            })
        })
    }
    
    func saveUser(user: AWSDynamoDBObjectModel, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        // Set config to skip null attributes.
        let updateMapperConfig = AWSDynamoDBObjectMapperConfiguration()
        updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehavior.UpdateSkipNullAttributes
        
        let userToUpdate: AWSUser = user as! AWSUser
        
        objectMapper.save(userToUpdate, configuration: updateMapperConfig).continueWithBlock(completionHandler)
    }
    
    func saveUserAbout(user: AWSDynamoDBObjectModel, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let userAboutToUpdate: AWSUserAbout = user as! AWSUserAbout
        objectMapper.save(userAboutToUpdate).continueWithBlock(completionHandler)
    }
    
    func saveUserFullName(user: AWSDynamoDBObjectModel, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let userFullNameToUpdate: AWSUserFullName = user as! AWSUserFullName
        objectMapper.save(userFullNameToUpdate).continueWithBlock(completionHandler)
    }
    
    func saveUserPreferredUsername(user: AWSDynamoDBObjectModel, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let userPreferredUsernameToUpdate: AWSUserPreferredUsername = user as! AWSUserPreferredUsername
        objectMapper.save(userPreferredUsernameToUpdate).continueWithBlock(completionHandler)
    }
    
    func saveUserProfessions(user: AWSDynamoDBObjectModel, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let userProfessionsToUpdate: AWSUserProfessions = user as! AWSUserProfessions
        objectMapper.save(userProfessionsToUpdate).continueWithBlock(completionHandler)
    }
    
    func saveUserProfilePic(user: AWSDynamoDBObjectModel, completionHandler: AWSContinuationBlock) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let userProfilePicToUpdate: AWSUserProfilePic = user as! AWSUserProfilePic
        objectMapper.save(userProfilePicToUpdate).continueWithBlock(completionHandler)
    }
}
