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
    
    // Other user (participant).
    var participantId: String?
    var participantFirstName: String?
    var participantLastName: String?
    var participantPreferredUsername: String?
    var participantProfessionName: String?
    var participantProfilePicUrl: String?
    
    // Generated.
    var lastMessagereatedString: String? {
        guard let lastMessageCreated = self.lastMessageCreated else {
            return nil
        }
        let currentDate = Date()
        return currentDate.offsetFromShort(Date(timeIntervalSince1970: TimeInterval(lastMessageCreated)))
    }
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, conversationId: String?, lastMessageText: String?, lastMessageCreated: NSNumber?, participantId: String?, participantFirstName: String?, participantLastName: String?, participantPreferredUsername: String?, participantProfessionName: String?, participantProfilePicUrl: String?) {
        self.init()
        self.userId = userId
        self.conversationId = conversationId
        self.lastMessageText = lastMessageText
        self.lastMessageCreated = lastMessageCreated
        self.participantId = participantId
        self.participantFirstName = participantFirstName
        self.participantLastName = participantLastName
        self.participantPreferredUsername = participantPreferredUsername
        self.participantProfessionName = participantProfessionName
        self.participantProfilePicUrl = participantProfilePicUrl
    }
    
    // MARK: Custom copying
    
    func copyConversation() -> Conversation {
        let conversation = Conversation(userId: userId, conversationId: conversationId, lastMessageText: lastMessageText, lastMessageCreated: lastMessageCreated, participantId: participantId, participantFirstName: participantFirstName, participantLastName: participantLastName, participantPreferredUsername: participantPreferredUsername, participantProfessionName: participantProfessionName, participantProfilePicUrl: participantProfilePicUrl)
        return conversation
    }
}
