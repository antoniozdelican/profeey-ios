//
//  AWSRelationship.swift
//  Profeey
//
//  Created by Antonio Zdelican on 06/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSRelationship: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _followingId: String?
    var _creationDate: NSNumber?
    
    // Following data.
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    convenience init(_userId: String?, _followingId: String?, _creationDate: NSNumber?, _firstName: String?, _lastName: String?, _preferredUsername: String?, _professionName: String?, _profilePicUrl: String?) {
        self.init()
        self._userId = _userId
        self._followingId = _followingId
        self._creationDate = _creationDate
        self._firstName = _firstName
        self._lastName = _lastName
        self._preferredUsername = _preferredUsername
        self._professionName = _professionName
        self._profilePicUrl = _profilePicUrl
    }
    
    // To remove Like.
    convenience init(_userId: String?, _followingId: String?) {
        self.init()
        self._userId = _userId
        self._followingId = _followingId
    }
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Relationships"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_followingId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_creationDate" : "creationDate",
            "_followingId" : "followingId",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_preferredUsername" : "preferredUsername",
            "_professionName" : "professionName",
            "_profilePicUrl" : "profilePicUrl",
        ]
    }
}
