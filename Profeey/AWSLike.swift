//
//  AWSLike.swift
//  Profeey
//
//  Created by Antonio Zdelican on 27/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class AWSLike: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _postId: String?
    var _created: NSNumber?
    // Need to update Post numberOfLikes upon Like create/delete
    var _postUserId: String?
    
    // Liker data.
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    convenience init(_userId: String?, _postId: String?, _created: NSNumber?, _postUserId: String?, _firstName: String?, _lastName: String?, _preferredUsername: String?, _professionName: String?, _profilePicUrl: String?) {
        self.init()
        self._userId = _userId
        self._postId = _postId
        self._created = _created
        self._postUserId = _postUserId
        self._firstName = _firstName
        self._lastName = _lastName
        self._preferredUsername = _preferredUsername
        self._professionName = _professionName
        self._profilePicUrl = _profilePicUrl
    }
    
    // To remove Like.
    convenience init(_userId: String?, _postId: String?) {
        self.init()
        self._userId = _userId
        self._postId = _postId
    }
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Likes"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_postId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_postId" : "postId",
            "_created" : "created",
            "_postUserId" : "postUserId",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_preferredUsername" : "preferredUsername",
            "_professionName" : "professionName",
            "_profilePicUrl" : "profilePicUrl",
        ]
    }
}
