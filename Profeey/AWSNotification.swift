//
//  AWSNotification.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSNotification: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _notificationId: String?
    var _creationDate: NSNumber?
    var _notificationType: NSNumber?
    
    // Optional if notification is Like or Comment.
    var _postId: String?
    
    var _notifierUserId: String?
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Notifications"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_notificationId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_notificationId" : "notificationId",
            "_creationDate" : "creationDate",
            "_notificationType" : "notificationType",
            "_postId" : "postId",
            "_notifierUserId" : "notifierUserId",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_preferredUsername" : "preferredUsername",
            "_professionName" : "professionName",
            "_profilePicUrl" : "profilePicUrl",
        ]
    }
}
