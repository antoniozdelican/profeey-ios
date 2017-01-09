//
//  AWSConversation.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSConversation: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _conversationId: String?
    var _created: NSNumber?
    
    var _lastMessageText: String?
    var _lastMessageCreated: NSNumber?
    
    var _participantId: String?
    var _participantFirstName: String?
    var _participantLastName: String?
    var _participantPreferredUsername: String?
    var _participantProfessionName: String?
    var _participantProfilePicUrl: String?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Conversations"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_conversationId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_conversationId" : "conversationId",
            "_created" : "created",
            "_lastMessageText" : "lastMessageText",
            "_lastMessageCreated" : "lastMessageCreated",
            "_participantId" : "participantId",
            "_participantFirstName" : "participantFirstName",
            "_participantLastName" : "participantLastName",
            "_participantPreferredUsername" : "participantPreferredUsername",
            "_participantProfessionName" : "participantProfessionName",
            "_participantProfilePicUrl" : "participantProfilePicUrl",
        ]
    }
    
    // Only interested in lastMessageCreated.
    class func ignoreAttributes() -> [String] {
        return ["created"]
    }
}
