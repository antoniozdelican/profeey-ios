//
//  PRFYNotification.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class PRFYNotification: NSObject {
    
    // Properties.
    var userId: String? // currentUser.id
    var notificationId: String?
    var created: NSNumber?
    var notificationType: NSNumber?
    // Optional if notification is Like or Comment.
    var postId: String?
    
    // Generated.
    var user: User? // Notifier data.
    
    var createdString: String? {
        guard let created = self.created else {
            return nil
        }
        let currentDate = Date()
        return currentDate.offsetFrom(Date(timeIntervalSince1970: TimeInterval(created)))
    }
    
    var notificationMessage: String? {
        guard let notificationType = self.notificationType else {
            return nil
        }
        switch notificationType.intValue {
        case NotificationType.like.rawValue:
            return " liked your post. "
        case NotificationType.comment.rawValue:
            return " commented on your post. "
        case NotificationType.following.rawValue:
            return " started following you. "
        case NotificationType.recommendation.rawValue:
            return " recommended you. "
        default:
            return nil
        }
    }
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, notificationId: String?, created: NSNumber?, notificationType: NSNumber?, postId: String?, user: User?) {
        self.init()
        self.userId = userId
        self.notificationId = notificationId
        self.created = created
        self.notificationType = notificationType
        self.postId = postId
        self.user = user
    }
}
