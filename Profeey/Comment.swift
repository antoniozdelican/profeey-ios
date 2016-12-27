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
    var created: NSNumber?
    var commentText: String?
    var postId: String?
    var postUserId: String?
    
    // Generated.
    var user: User?
    var createdString: String? {
        guard let created = self.created else {
            return nil
        }
        let currentDate = Date()
        return currentDate.offsetFromShort(Date(timeIntervalSince1970: TimeInterval(created)))
    }
    
    var isExpandedCommentText: Bool = false
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, commentId: String?, created: NSNumber?, commentText: String?, postId: String?, postUserId: String?, user: User?) {
        self.init()
        self.userId = userId
        self.commentId = commentId
        self.created = created
        self.commentText = commentText
        self.postId = postId
        self.postUserId = postUserId
        self.user = user
    }
    
    // MARK: Custom copying.
    
    func copyComment() -> Comment {
        let comment = Comment(userId: userId, commentId: commentId, created: created, commentText: commentText, postId: postId, postUserId: postUserId, user: user)
        return comment
    }
}
