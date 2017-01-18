//
//  Conversation.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation

class Conversation: NSObject {
    
    // Properties.
    var userId: String?
    var conversationId: String?
    var lastMessageText: String?
    var lastMessageCreated: NSNumber?
    var lastMessageSeen: NSNumber? // 0 or 1 because Bool isn't supported.
    
    // Generated.
    var participant: User? // Participant data.
    var lastMessagerCeatedString: String? {
        guard let lastMessageCreated = self.lastMessageCreated else {
            return nil
        }
        let currentDate = Date()
        return currentDate.offsetFromShort(Date(timeIntervalSince1970: TimeInterval(lastMessageCreated)))
    }
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, conversationId: String?, lastMessageText: String?, lastMessageCreated: NSNumber?, lastMessageSeen: NSNumber?, participant: User?) {
        self.init()
        self.userId = userId
        self.conversationId = conversationId
        self.lastMessageText = lastMessageText
        self.lastMessageCreated = lastMessageCreated
        self.lastMessageSeen = lastMessageSeen
        self.participant = participant
    }
    
    // MARK: Custom copying
    
    func copyConversation() -> Conversation {
        let conversation = Conversation(userId: userId, conversationId: conversationId, lastMessageText: lastMessageText, lastMessageCreated: lastMessageCreated, lastMessageSeen: lastMessageSeen, participant: participant)
        return conversation
    }
}
