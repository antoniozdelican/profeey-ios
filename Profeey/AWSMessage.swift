//
//  AWSMessage.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSMessage: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _conversationId: String?
    var _messageId: String?
    var _created: NSNumber?
    var _messageText: String?
    var _senderId: String?
    var _recipientId: String?
    
    convenience init(_conversationId: String?, _messageId: String?, _created: NSNumber?, _messageText: String?, _senderId: String?, _recipientId: String?) {
        self.init()
        self._conversationId = _conversationId
        self._messageId = _messageId
        self._created = _created
        self._messageText = _messageText
        self._senderId = _senderId
        self._recipientId = _recipientId
    }
    
    // To remove Message.
    convenience init(_conversationId: String?, _messageId: String?) {
        self.init()
        self._conversationId = _conversationId
        self._messageId = _messageId
    }
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Messages"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_conversationId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_messageId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_conversationId" : "conversationId",
            "_messageId" : "messageId",
            "_created" : "created",
            "_messageText" : "messageText",
            "_senderId" : "senderId",
            "_recipientId" : "recipientId",
        ]
    }
}
