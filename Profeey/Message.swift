//
//  Message.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation

class Message: NSObject {
    
    // Properties.
    var conversationId: String?
    var messageId: String?
    var created: NSNumber?
    var messageText: String?
    var senderId: String?
    var recipientId: String?
    
    // Generated.
    var createdString: String? {
        guard let created = self.created else {
            return nil
        }
        let currentDate = Date()
        return currentDate.offsetFromShort(Date(timeIntervalSince1970: TimeInterval(created)))
    }
    
    override init() {
        super.init()
    }
    
    convenience init(conversationId: String?, messageId: String?, created: NSNumber?, messageText: String?, senderId: String?, recipientId: String?) {
        self.init()
        self.conversationId = conversationId
        self.messageId = messageId
        self.created = created
        self.messageText = messageText
        self.senderId = senderId
        self.recipientId = recipientId
    }
    
    // MARK: Custom copying
    
    func copyMessage() -> Message {
        let message = Message(conversationId: conversationId, messageId: messageId, created: created, messageText: messageText, senderId: senderId, recipientId: recipientId)
        return message
    }
}
