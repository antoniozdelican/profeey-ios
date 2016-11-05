//
//  Comment.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class Comment: NSObject {
    
    // Properties.
    var userId: String?
    var commentId: String?
    var commentText: String?
    var creationDate: NSNumber?
    
    // Generated.
    var user: User?
    var creationDateString: String? {
        guard let creationDate = self.creationDate else {
            return nil
        }
        let currentDate = Date()
        return currentDate.offsetFrom(Date(timeIntervalSince1970: TimeInterval(creationDate)))
    }
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, commentId: String?, commentText: String?, creationDate: NSNumber?, user: User?) {
        self.init()
        self.userId = userId
        self.commentId = commentId
        self.commentText = commentText
        self.creationDate = creationDate
        self.user = user
    }
}
