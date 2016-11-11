//
//  AWSComment.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class AWSComment: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _commentId: String?
    var _postId: String?
    var _creationDate: NSNumber?
    var _commentText: String?
    // Need to update Post numberOfComments upon Comment create/delete
    var _postUserId: String?
    
    // Commenter data.
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    convenience init(_userId: String?, _commentId: String?, _creationDate: NSNumber?, _postId: String?, _postUserId: String?, _commentText: String?, _firstName: String?, _lastName: String?, _preferredUsername: String?, _professionName: String?, _profilePicUrl: String?) {
        self.init()
        self._userId = _userId
        self._commentId = _commentId
        self._creationDate = _creationDate
        self._postId = _postId
        self._postUserId = _postUserId
        self._commentText = _commentText
        self._firstName = _firstName
        self._lastName = _lastName
        self._preferredUsername = _preferredUsername
        self._professionName = _professionName
        self._profilePicUrl = _profilePicUrl
    }
    
    // AWSCommentUpdate
    convenience init(_userId: String?, _commentId: String?, _commentText: String?) {
        self.init()
        self._userId = _userId
        self._commentId = _commentId
        self._commentText = _commentText
    }
    
    // To remove Comment.
    convenience init(_userId: String?, _commentId: String?) {
        self.init()
        self._userId = _userId
        self._commentId = _commentId
    }
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Comments"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_commentId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_commentId" : "commentId",
            "_postId" : "postId",
            "_postUserId" : "postUserId",
            "_creationDate" : "creationDate",
            "_commentText" : "commentText",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_preferredUsername" : "preferredUsername",
            "_professionName" : "professionName",
            "_profilePicUrl" : "profilePicUrl",
        ]
    }
}
