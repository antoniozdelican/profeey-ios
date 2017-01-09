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
    
    convenience init(_userId: String?, _conversationId: String?, _created: NSNumber?, _lastMessageText: String?, _lastMessageCreated: NSNumber?, _participantId: String?, _participantFirstName: String?, _participantLastName: String?, _participantPreferredUsername: String?, _participantProfessionName: String?, _participantProfilePicUrl: String?) {
        self.init()
        self._userId = _userId
        self._conversationId = _conversationId
        self._created = _created
        self._lastMessageText = _lastMessageText
        self._lastMessageCreated = _lastMessageCreated
        self._participantId = _participantId
        self._participantFirstName = _participantFirstName
        self._participantLastName = _participantLastName
        self._participantPreferredUsername = _participantPreferredUsername
        self._participantProfessionName = _participantProfessionName
        self._participantProfilePicUrl = _participantProfilePicUrl
    }
    
    // To remove Conversation.
    convenience init(_userId: String?, _conversationId: String?) {
        self.init()
        self._userId = _userId
        self._conversationId = _conversationId
    }
    
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
//    class func ignoreAttributes() -> [String] {
//        return ["created"]
//    }
}
